import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/transaction_model.dart';
import '../providers/transaction_provider.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'add_transaction_screen.dart';
import 'stats_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = AuthService().currentUser!.uid;
    // สร้าง Provider หลังล็อกอิน และถูกทำลายเมื่อล็อกเอาต์ (ข้อมูลไม่ปนกันระหว่างบัญชี)
    return ChangeNotifierProvider(
      create: (_) => TransactionProvider(uid),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  void _openForm(BuildContext context, {TransactionModel? item}) {
    final p = context.read<TransactionProvider>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: p,
          child: AddTransactionScreen(existing: item),
        ),
      ),
    );
  }

  void _openStats(BuildContext context) {
    final p = context.read<TransactionProvider>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: p,
          child: const StatsScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<TransactionProvider>();
    final money = NumberFormat('#,##0.00');
    final items = p.monthItems;

    return Scaffold(
      appBar: AppBar(
        title: const Text('รายรับ-รายจ่าย'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: 'สถิติ',
            onPressed: () => _openStats(context),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'ออกจากระบบ',
            onPressed: () => AuthService().logout(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context),
        icon: const Icon(Icons.add),
        label: const Text('เพิ่มรายการ'),
      ),
      body: Column(
        children: [
          // ตัวเลือกเดือน
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () => p.changeMonth(-1)),
                Text(DateFormat('MMMM yyyy').format(p.month),
                    style: Theme.of(context).textTheme.titleMedium),
                IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () => p.changeMonth(1)),
              ],
            ),
          ),
          // การ์ดสรุป
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text('คงเหลือ'),
                  Text(
                    '฿${money.format(p.balance)}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: p.balance >= 0
                              ? AppColors.income
                              : AppColors.expense,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                          child: _SummaryTile(
                              label: 'รายรับ',
                              value: money.format(p.income),
                              color: AppColors.income)),
                      Expanded(
                          child: _SummaryTile(
                              label: 'รายจ่าย',
                              value: money.format(p.expense),
                              color: AppColors.expense)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: p.error != null
                ? Center(child: Text('เกิดข้อผิดพลาด: ${p.error}'))
                : p.loading
                    ? const Center(child: CircularProgressIndicator())
                    : items.isEmpty
                        ? const Center(child: Text('ยังไม่มีรายการในเดือนนี้'))
                        : ListView.builder(
                            padding: const EdgeInsets.only(bottom: 88),
                            itemCount: items.length,
                            itemBuilder: (context, i) {
                              final t = items[i];
                              return Dismissible(
                                key: ValueKey(t.id),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  color: Colors.red,
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  child: const Icon(Icons.delete,
                                      color: Colors.white),
                                ),
                                onDismissed: (_) {
                                  p.delete(t.id!);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('ลบรายการแล้ว')));
                                },
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: t.isIncome
                                        ? AppColors.incomeLight
                                        : AppColors.expenseLight,
                                    child: Icon(
                                      t.isIncome
                                          ? Icons.arrow_upward
                                          : Icons.arrow_downward,
                                      color: t.isIncome
                                          ? AppColors.income
                                          : AppColors.expense,
                                    ),
                                  ),
                                  title: Text(t.category),
                                  subtitle: Text(
                                    '${DateFormat('d MMM').format(t.date)}'
                                    '${t.note.isEmpty ? '' : ' • ${t.note}'}',
                                  ),
                                  trailing: Text(
                                    '${t.isIncome ? '+' : '-'}${money.format(t.amount)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: t.isIncome
                                          ? AppColors.income
                                          : AppColors.expense,
                                    ),
                                  ),
                                  onTap: () => _openForm(context, item: t),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _SummaryTile(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label),
        Text(value,
            style: TextStyle(fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}