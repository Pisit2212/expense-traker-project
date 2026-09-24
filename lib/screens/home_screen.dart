import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/transaction_model.dart';
import '../providers/transaction_provider.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../theme/theme_controller.dart';
import 'add_transaction_screen.dart';
import 'stats_screen.dart';

import 'about_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = AuthService().currentUser!.uid;
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

  Future<bool> _confirmDelete(BuildContext context, TransactionModel t) async {
    final money = NumberFormat('#,##0.00');
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.delete_outline, color: AppColors.expense),
        title: const Text('ลบรายการนี้?'),
        content: Text(
          '${t.category}  ${t.isIncome ? '+' : '-'}${money.format(t.amount)} บาท\n'
          'ต้องการลบรายการนี้ใช่ไหม',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('ยกเลิก'),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.expense,
              minimumSize: const Size(88, 44),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('ลบ'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.logout),
        title: const Text('ออกจากระบบ?'),
        content: const Text(
          'ข้อมูลของคุณยังถูกเก็บไว้ และกลับมาดูได้เมื่อเข้าสู่ระบบอีกครั้ง',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('ยกเลิก'),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.expense,
              minimumSize: const Size(88, 44),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('ออกจากระบบ'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await AuthService().logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<TransactionProvider>();
    final money = NumberFormat('#,##0.00');
    final items = p.filteredItems;

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 96,
        leading: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.info_outline),
              tooltip: 'เกี่ยวกับโปรเจกต์',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutScreen()),
              ),
            ),
            Builder(
              builder: (context) {
                final tc = context.watch<ThemeController>();
                return IconButton(
                  icon: Icon(tc.isDark ? Icons.light_mode : Icons.dark_mode),
                  tooltip: tc.isDark ? 'โหมดสว่าง' : 'โหมดมืด',
                  onPressed: () => context.read<ThemeController>().toggle(),
                );
              },
            ),
          ],
        ),
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
            onPressed: () => _confirmLogout(context),
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
          // ช่องค้นหา
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              onChanged: p.setQuery,
              decoration: const InputDecoration(
                hintText: 'ค้นหาจากโน้ตหรือหมวดหมู่',
                prefixIcon: Icon(Icons.search),
                isDense: true,
              ),
            ),
          ),
          
          if (p.monthCategories.isNotEmpty)
            SizedBox(
              height: 52,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: const Text('ทั้งหมด'),
                      selected: p.categoryFilter == null,
                      onSelected: (_) => p.setCategoryFilter(null),
                    ),
                  ),
                  for (final c in p.monthCategories)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(c),
                        selected: p.categoryFilter == c,
                        onSelected: (_) => p.setCategoryFilter(
                            p.categoryFilter == c ? null : c),
                      ),
                    ),
                ],
              ),
            ),
          Expanded(
            child: p.error != null
                ? Center(child: Text('เกิดข้อผิดพลาด: ${p.error}'))
                : p.loading
                    ? const Center(child: CircularProgressIndicator())
                    : items.isEmpty
                        ? Center(
                            child: Text(p.monthItems.isEmpty
                                ? 'ยังไม่มีรายการในเดือนนี้'
                                : 'ไม่พบรายการที่ตรงกับการค้นหา'))
                        : ListView.builder(
                            padding: const EdgeInsets.only(bottom: 88),
                            itemCount: items.length,
                            itemBuilder: (context, i) {
                              final t = items[i];
                              return Dismissible(
                                key: ValueKey(t.id),
                                direction: DismissDirection.endToStart,
                                confirmDismiss: (_) =>
                                    _confirmDelete(context, t),
                                background: Container(
                                  color: Colors.red,
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  child: const Icon(Icons.delete,
                                      color: Colors.white),
                                ),
                                onDismissed: (_) {
                                  final removed = t;
                                  p.delete(t.id!);
                                  final messenger =
                                      ScaffoldMessenger.of(context);
                                  final controller =
                                      messenger.showSnackBar(SnackBar(
                                    content: const Text('ลบรายการแล้ว'),
                                    duration: const Duration(seconds: 30),
                                    action: SnackBarAction(
                                      label: 'เลิกทำ',
                                      onPressed: () => p.add(removed),
                                    ),
                                  ));
                                  Future.delayed(
                                      const Duration(seconds: 5), () {
                                    controller.close();
                                  });
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
                                      fontSize: 14,
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
            style: TextStyle(fontWeight: FontWeight.bold,
            color: color,
            fontSize: 16)),
      ],
    );
  }
}