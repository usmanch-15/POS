// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../providers/sale_provider.dart';
import '../../models/sale_model.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_overlay.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  final _searchCtrl = TextEditingController();
  String    _query     = '';
  DateTime? _fromDate;
  DateTime? _toDate;
  bool      _filtering = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDateRange() async {
    final range = await showDateRangePicker(
      context:      context,
      firstDate:    DateTime(2020),
      lastDate:     DateTime.now(),
      initialDateRange: _fromDate != null && _toDate != null
          ? DateTimeRange(start: _fromDate!, end: _toDate!)
          : null,
    );
    if (range != null) {
      setState(() {
        _fromDate  = range.start;
        _toDate    = range.end;
        _filtering = true;
      });
      if (mounted) {
        await context.read<SaleProvider>().loadInRange(range.start, range.end);
      }
    }
  }

  void _clearFilter() {
    setState(() {
      _fromDate  = null;
      _toDate    = null;
      _filtering = false;
      _query     = '';
      _searchCtrl.clear();
    });
    context.read<SaleProvider>().resetToStream();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sp     = context.watch<SaleProvider>();

    final sales = _query.isEmpty
        ? sp.sales
        : sp.sales
        .where((s) => s.billNumber
        .toLowerCase()
        .contains(_query.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkScaffold : AppColors.lightScaffold,
      appBar: AppBar(
        title: const Text('Sales History',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon:      Icon(Icons.date_range,
                color: _filtering ? AppColors.primary : null),
            tooltip:   'Date Filter',
            onPressed: _pickDateRange,
          ),
          if (_filtering)
            IconButton(
              icon:      const Icon(Icons.clear, color: AppColors.danger),
              tooltip:   'Filter Clear',
              onPressed: _clearFilter,
            ),
        ],
      ),
      body: Column(children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
          child: TextField(
            controller: _searchCtrl,
            onChanged:  (v) => setState(() => _query = v),
            decoration: InputDecoration(
              hintText:   'Bill number se search karein...',
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                icon:      const Icon(Icons.clear, size: 18),
                onPressed: () {
                  _searchCtrl.clear();
                  setState(() => _query = '');
                },
              )
                  : null,
              filled:     true,
              fillColor:  isDark ? AppColors.darkCard : Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:   BorderSide.none,
              ),
            ),
          ),
        ),

        // Date filter chip
        if (_filtering && _fromDate != null && _toDate != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(children: [
              Chip(
                label: Text(
                  '${DateFormatter.dateShort(_fromDate!)} — ${DateFormatter.dateShort(_toDate!)}',
                  style: const TextStyle(fontSize: 12),
                ),
                deleteIcon:      const Icon(Icons.close, size: 16),
                onDeleted:       _clearFilter,
                backgroundColor: AppColors.primary.withOpacity(0.1),
              ),
            ]),
          ),

        // Sales list
        Expanded(
          child: sp.isLoading
              ? const InlineLoader()
              : sales.isEmpty
              ? const EmptyState.sales()
              : ListView.separated(
            padding:          const EdgeInsets.all(12),
            itemCount:        sales.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder:      (_, i) => _SaleTile(sale: sales[i]),
          ),
        ),
      ]),
    );
  }
}

// ═════════════════════════════════════════════════════════════
// _SaleTile — individual sale card
// ═════════════════════════════════════════════════════════════
class _SaleTile extends StatelessWidget {
  final SaleModel sale;
  const _SaleTile({required this.sale});

  @override
  Widget build(BuildContext context) {
    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final isRefund  = sale.status == SaleStatus.refunded;
    final isPartial = sale.status == SaleStatus.partial;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:        isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: isRefund
            ? Border.all(color: AppColors.danger.withOpacity(0.4))
            : isPartial
            ? Border.all(color: Colors.orange.withOpacity(0.4))
            : null,
      ),
      child: Row(children: [
        // Left: bill info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Text(sale.billNumber,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(width: 8),
                if (isRefund)
                  _StatusChip('Refunded', AppColors.danger)
                else if (isPartial)
                  _StatusChip('Partial', Colors.orange),
              ]),
              const SizedBox(height: 4),
              Text(DateFormatter.dateTime(sale.createdAt),
                  style: TextStyle(
                      color: Colors.grey.shade500, fontSize: 12)),
              if (sale.customerName != null)
                Text(sale.customerName!,
                    style: TextStyle(
                        color: Colors.grey.shade500, fontSize: 12)),
            ],
          ),
        ),
        // Right: amount + item count
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(CurrencyFormatter.format(sale.total),
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize:   15,
                    color: isRefund
                        ? AppColors.danger
                        : AppColors.primary)),
            Text('${sale.items.length} items',
                style: TextStyle(
                    color: Colors.grey.shade500, fontSize: 11)),
          ],
        ),
      ]),
    );
  }
}

// ═════════════════════════════════════════════════════════════
// _StatusChip
// ═════════════════════════════════════════════════════════════
class _StatusChip extends StatelessWidget {
  final String label;
  final Color  color;
  const _StatusChip(this.label, this.color);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color:        color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(99),
    ),
    child: Text(label,
        style: TextStyle(
            color:      color,
            fontSize:   10,
            fontWeight: FontWeight.w500)),
  );
}