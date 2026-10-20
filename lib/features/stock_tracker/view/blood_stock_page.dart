import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../controller/blood_stock_controller.dart';
import '../widget/stock_card.dart';
import '../widget/stock_summary_card.dart';

/// Stok Takibi Sayfası
class BloodStockPage extends StatefulWidget {
  const BloodStockPage({super.key, this.controller});

  final BloodStockController? controller;

  @override
  State<BloodStockPage> createState() => _BloodStockPageState();
}

class _BloodStockPageState extends State<BloodStockPage> {
  late final BloodStockController _controller;
  bool _ownsController = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = BloodStockController();
      _ownsController = true;
    }
  }

  @override
  void dispose() {
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.obsidianBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Kan Grubu Stok Takibi'),
        actions: [
          IconButton(
            tooltip: 'Simülasyon Güncellemesi',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _controller.refreshStocksSimulated,
          ),
        ],
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) => _buildBody(isDark),
        ),
      ),
    );
  }

  Widget _buildBody(bool isDark) {
    final stocks = _controller.filteredStocks;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StockSummaryCard(controller: _controller),
          const SizedBox(height: 16),
          _buildFilterRow(isDark),
          const SizedBox(height: 14),
          for (final stock in stocks) ...[
            StockCard(stock: stock),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildFilterRow(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Kan Grupları (${_controller.filteredStocks.length})',
          style: TextStyle(
            color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        SegmentedButton<StockFilter>(
          segments: const [
            ButtonSegment(value: StockFilter.all, label: Text('Tümü')),
            ButtonSegment(value: StockFilter.criticalOnly, label: Text('Kritik')),
          ],
          selected: {_controller.filter},
          onSelectionChanged: (set) => _controller.setFilter(set.first),
          style: const ButtonStyle(
            visualDensity: VisualDensity.compact,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ],
    );
  }
}
