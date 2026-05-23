import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/expense_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/expense_service.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  final ExpenseService _service = ExpenseService();

  Future<void> _showAddDialog() async {
    final titleCtrl  = TextEditingController();
    final amountCtrl = TextEditingController();
    final noteCtrl   = TextEditingController();
    ExpenseCategory selectedCategory = ExpenseCategory.other;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Add Expense',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Title *',
                  hintText:  'e.g. Shop Rent',
                  border:    OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller:   amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText:  'Amount *',
                  prefixText: 'PKR ',
                  border:     OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<ExpenseCategory>(
                value: selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border:    OutlineInputBorder(),
                ),
                items: ExpenseCategory.values
                    .map((c) => DropdownMenuItem(
                  value: c,
                  child: Text('${c.icon}  ${c.label}'),
                ))
                    .toList(),
                onChanged: (v) => setS(() => selectedCategory = v!),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteCtrl,
                maxLines:   2,
                decoration: const InputDecoration(
                  labelText: 'Note (optional)',
                  border:    OutlineInputBorder(),
                ),
              ),
            ]),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child:     const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final title  = titleCtrl.text.trim();
                final amount = double.tryParse(amountCtrl.text.trim());
                if (title.isEmpty || amount == null || amount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Title aur valid amount zaroori hai')),
                  );
                  return;
                }
                final auth = context.read<AuthProvider>();

                // ✅ FIX 1: .new( → ExpenseModel(
                // ✅ FIX 2: createdBy parameter hataya (model fix ke baad)
                await _service.addExpense(ExpenseModel(
                  id:          '',
                  title:       title,
                  amount:      amount,
                  category:    selectedCategory,
                  description: noteCtrl.text.trim().isEmpty
                      ? null
                      : noteCtrl.text.trim(),
                  addedBy:     auth.user?.id ?? '',
                  date:        DateTime.now(),
                  createdAt:   DateTime.now(),
                ));

                if (ctx.mounted) Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary),
              // ✅ FIX 3: double comma ", ," hataya
              child: const Text('Save',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkScaffold : AppColors.lightScaffold,
      appBar: AppBar(
        title: const Text('Expenses',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon:      const Icon(Icons.add),
            onPressed: _showAddDialog,
            tooltip:   'Add Expense',
          ),
        ],
      ),
      body: StreamBuilder<List<ExpenseModel>>(
        stream: _service.streamExpenses(),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          final expenses = snap.data ?? [];

          if (expenses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined,
                      size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  Text('Koi expense nahi',
                      style: TextStyle(
                          color: Colors.grey.shade500, fontSize: 16)),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: _showAddDialog,
                    icon:      const Icon(Icons.add),
                    label:     const Text('Add Expense'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary),
                  ),
                ],
              ),
            );
          }

          final now        = DateTime.now();
          final monthTotal = expenses
              .where((e) =>
          e.date.month == now.month && e.date.year == now.year)
              .fold(0.0, (s, e) => s + e.amount);

          return Column(children: [
            // Month summary card
            Container(
              margin:  const EdgeInsets.all(12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05), blurRadius: 8)
                ],
              ),
              child: Row(children: [
                const Icon(Icons.calendar_month, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Is maheene ka kharcha',
                      style: TextStyle(
                          color: isDark
                              ? Colors.white70
                              : Colors.black54)),
                ),
                Text(CurrencyFormatter.format(monthTotal),
                    style: const TextStyle(
                        fontSize:   16,
                        fontWeight: FontWeight.w600,
                        color:      AppColors.danger)),
              ]),
            ),

            // Expense list
            Expanded(
              child: ListView.separated(
                padding:         const EdgeInsets.symmetric(horizontal: 12),
                itemCount:       expenses.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final e = expenses[i];
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color:        isDark ? AppColors.darkCard : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color:        AppColors.danger.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(e.category.icon,
                            style: const TextStyle(fontSize: 18)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(e.title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500, fontSize: 14)),
                            Text(
                              // ✅ FIX: date() → dateShort()
                              '${e.category.label} · ${DateFormatter.dateShort(e.date)}',
                              style: TextStyle(
                                  color: Colors.grey.shade500, fontSize: 12),
                            ),
                            if (e.description != null)
                              Text(e.description!,
                                  style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 11)),
                          ],
                        ),
                      ),
                      Text(CurrencyFormatter.format(e.amount),
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color:      AppColors.danger,
                              fontSize:   14)),
                    ]),
                  );
                },
              ),
            ),
          ]);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:       _showAddDialog,
        backgroundColor: AppColors.primary,
        child:           const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}