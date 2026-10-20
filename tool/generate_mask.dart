// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:typed_data';

void main() {
  final inputFile = File('assets/images/bag_empty.png');
  final outputFile = File('assets/images/bag_mask.png');

  if (!inputFile.existsSync()) {
    print('Hata: assets/images/bag_empty.png bulunamadı!');
    exit(1);
  }

  print('bag_empty.png okunuyor...');
  final inputBytes = inputFile.readAsBytesSync();
  final decoded = decodePngRgba(inputBytes);
  final width = decoded.width;
  final height = decoded.height;
  final rgba = decoded.pixels;

  print('Boyut: $width x $height');

  // 1. Alfa eşikleme ve sınır kesimleri
  // Üst port kesimi: y < height * 0.27
  // Alt ayak kesimi: y > height * 0.83
  // Sol/sağ marjin kesimi: x < width * 0.16 || x > width * 0.84
  final maskGrid = List<bool>.filled(width * height, false);

  final topCut = (height * 0.275).round();
  final bottomCut = (height * 0.835).round();
  final leftCut = (width * 0.165).round();
  final rightCut = (width * 0.835).round();

  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      if (y < topCut || y > bottomCut || x < leftCut || x > rightCut) {
        continue;
      }
      final idx = (y * width + x) * 4;
      final a = rgba[idx + 3];
      // Eğer torbanın gövdesindeyse
      if (a > 60) {
        maskGrid[y * width + x] = true;
      }
    }
  }

  // 2. Delikleri ve iç alanı doldurma (morfolojik closing / cavity flood fill)
  // Yatayda her satırda sol ve sağ kenarlar arasındaki boşlukları doldur
  for (int y = topCut; y <= bottomCut; y++) {
    int firstX = -1;
    int lastX = -1;
    for (int x = leftCut; x <= rightCut; x++) {
      if (maskGrid[y * width + x]) {
        if (firstX == -1) firstX = x;
        lastX = x;
      }
    }
    if (firstX != -1 && lastX != -1 && (lastX - firstX > 20)) {
      for (int x = firstX; x <= lastX; x++) {
        maskGrid[y * width + x] = true;
      }
    }
  }

  // 3. Kenarlardan içeriye daraltma (Erosion: 4 piksel)
  const erosionRadius = 5;
  final erodedGrid = List<bool>.filled(width * height, false);

  for (int y = topCut; y <= bottomCut; y++) {
    for (int x = leftCut; x <= rightCut; x++) {
      if (!maskGrid[y * width + x]) continue;

      var allInside = true;
      for (int dy = -erosionRadius; dy <= erosionRadius; dy++) {
        final ny = y + dy;
        if (ny < 0 || ny >= height) {
          allInside = false;
          break;
        }
        for (int dx = -erosionRadius; dx <= erosionRadius; dx++) {
          final nx = x + dx;
          if (nx < 0 || nx >= width) {
            allInside = false;
            break;
          }
          if (dx * dx + dy * dy <= erosionRadius * erosionRadius) {
            if (!maskGrid[ny * width + nx]) {
              allInside = false;
              break;
            }
          }
        }
        if (!allInside) break;
      }

      if (allInside) {
        erodedGrid[y * width + x] = true;
      }
    }
  }

  // 4. Çıktı RGBA piksellerini hazırla: İç bölme beyaz (255, 255, 255, 255), geri kalan şeffaf (0, 0, 0, 0)
  final outRgba = Uint8List(width * height * 4);
  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      final idx = (y * width + x) * 4;
      if (erodedGrid[y * width + x]) {
        outRgba[idx] = 255; // R
        outRgba[idx + 1] = 255; // G
        outRgba[idx + 2] = 255; // B
        outRgba[idx + 3] = 255; // A
      } else {
        outRgba[idx] = 0;
        outRgba[idx + 1] = 0;
        outRgba[idx + 2] = 0;
        outRgba[idx + 3] = 0;
      }
    }
  }

  // 5. PNG olarak kaydet
  final outPngBytes = encodePngRgba(width, height, outRgba);
  outputFile.writeAsBytesSync(outPngBytes);
  print('Başarılı! Maske üretildi: ${outputFile.path} (${outPngBytes.length} byte)');
}

// ---------------------------------------------------------------------------
// Saf Dart PNG Dekoder ve Enkoder Fonksiyonları
// ---------------------------------------------------------------------------

class PngImage {
  PngImage(this.width, this.height, this.pixels);
  final int width;
  final int height;
  final Uint8List pixels;
}

PngImage decodePngRgba(Uint8List bytes) {
  var offset = 8;
  int width = 0;
  int height = 0;
  final idatChunks = <Uint8List>[];

  while (offset < bytes.length) {
    final length = ByteData.sublistView(bytes, offset, offset + 4).getUint32(0);
    offset += 4;
    final type = String.fromCharCodes(bytes.sublist(offset, offset + 4));
    offset += 4;

    if (type == 'IHDR') {
      final header = ByteData.sublistView(bytes, offset, offset + 13);
      width = header.getUint32(0);
      height = header.getUint32(4);
    } else if (type == 'IDAT') {
      idatChunks.add(bytes.sublist(offset, offset + length));
    } else if (type == 'IEND') {
      break;
    }
    offset += length;
    offset += 4; // CRC
  }

  final totalIdatLen = idatChunks.fold<int>(0, (sum, c) => sum + c.length);
  final allIdat = Uint8List(totalIdatLen);
  var curPos = 0;
  for (final chunk in idatChunks) {
    allIdat.setRange(curPos, curPos + chunk.length, chunk);
    curPos += chunk.length;
  }

  final uncompressed = Uint8List.fromList(zlib.decode(allIdat));
  final rgba = Uint8List(width * height * 4);

  final bytesPerRow = width * 4;
  var srcOffset = 0;

  for (int y = 0; y < height; y++) {
    final filterType = uncompressed[srcOffset++];
    final rowStart = y * bytesPerRow;

    for (int x = 0; x < bytesPerRow; x++) {
      final curr = uncompressed[srcOffset++];
      final left = x >= 4 ? rgba[rowStart + x - 4] : 0;
      final up = y > 0 ? rgba[rowStart - bytesPerRow + x] : 0;
      final upLeft = (y > 0 && x >= 4)
          ? rgba[rowStart - bytesPerRow + x - 4]
          : 0;

      int val;
      switch (filterType) {
        case 0:
          val = curr;
          break;
        case 1:
          val = (curr + left) & 0xFF;
          break;
        case 2:
          val = (curr + up) & 0xFF;
          break;
        case 3:
          val = (curr + ((left + up) >> 1)) & 0xFF;
          break;
        case 4:
          val = (curr + _paeth(left, up, upLeft)) & 0xFF;
          break;
        default:
          val = curr;
      }
      rgba[rowStart + x] = val;
    }
  }

  return PngImage(width, height, rgba);
}

int _paeth(int a, int b, int c) {
  final p = a + b - c;
  final pa = (p - a).abs();
  final pb = (p - b).abs();
  final pc = (p - c).abs();
  if (pa <= pb && pa <= pc) return a;
  if (pb <= pc) return b;
  return c;
}

Uint8List encodePngRgba(int width, int height, Uint8List rgba) {
  final scanlines = BytesBuilder();
  final rowBytes = width * 4;

  for (int y = 0; y < height; y++) {
    scanlines.addByte(0); // Filter 0 (None)
    scanlines.add(rgba.sublist(y * rowBytes, (y + 1) * rowBytes));
  }

  final compressed = zlib.encode(scanlines.toBytes());

  final out = BytesBuilder();
  // PNG signature
  out.add([137, 80, 78, 71, 13, 10, 26, 10]);

  // IHDR
  final ihdr = ByteData(13)
    ..setUint32(0, width)
    ..setUint32(4, height)
    ..setUint8(8, 8) // 8 bit
    ..setUint8(9, 6) // RGBA
    ..setUint8(10, 0)
    ..setUint8(11, 0)
    ..setUint8(12, 0);
  _writeChunk(out, 'IHDR', ihdr.buffer.asUint8List());

  // IDAT
  _writeChunk(out, 'IDAT', Uint8List.fromList(compressed));

  // IEND
  _writeChunk(out, 'IEND', Uint8List(0));

  return out.toBytes();
}

void _writeChunk(BytesBuilder out, String type, Uint8List data) {
  final length = data.length;
  final lenBytes = ByteData(4)..setUint32(0, length);
  out.add(lenBytes.buffer.asUint8List());

  final typeBytes = Uint8List.fromList(type.codeUnits);
  out.add(typeBytes);
  out.add(data);

  final crcData = Uint8List(4 + length);
  crcData.setRange(0, 4, typeBytes);
  crcData.setRange(4, 4 + length, data);
  final crc = _crc32(crcData);

  final crcBytes = ByteData(4)..setUint32(0, crc);
  out.add(crcBytes.buffer.asUint8List());
}

int _crc32(Uint8List data) {
  var crc = 0xFFFFFFFF;
  for (int b in data) {
    crc ^= b;
    for (int j = 0; j < 8; j++) {
      if ((crc & 1) != 0) {
        crc = (crc >> 1) ^ 0xEDB88320;
      } else {
        crc >>= 1;
      }
    }
  }
  return crc ^ 0xFFFFFFFF;
}
