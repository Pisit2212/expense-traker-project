import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../theme/app_theme.dart';

import '../services/exchange_rate_service.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  static const _palette = [
    Color(0xFF00897B),
    Color(0xFFF9A825),
    Color(0xFF5C6BC0),
    Color(0xFFEF6C00),
    Color(0xFFD81B60),
    Color(0xFF8D6E63),
    Color(0xFF26A69A),
  ];

  bool _showIncome = false;
  int _touched = -1;

  late Future<double> _rateFuture;

  @override
  void initState() {
    super.initState();
    _rateFuture = ExchangeRateService().getUsdToThb();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<TransactionProvider>();
    final money = NumberFormat('#,##0.00');

    final totals = p.categoryTotals(income: _showIncome);
    final entries = totals.entries.toList();
    final total = entries.fold<double>(0, (s, e) => s + e.value);
    final months = p.lastMonths(6);

    double maxY = 0;
    for (final m in months) {
      if (m.income > maxY) maxY = m.income;
      if (m.expense > maxY) maxY = m.expense;
    }
    if (maxY == 0) maxY = 100;

    return Scaffold(
      appBar: AppBar(title: const Text('สถิติ')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: FutureBuilder<double>(
                future: _rateFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Row(
                      children: [
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 12),
                        Text('กำลังโหลดอัตราแลกเปลี่ยน...'),
                      ],
                    );
                  }
                  if (snapshot.hasError) {
                    return Row(
                      children: [
                        const Icon(Icons.wifi_off, size: 18),
                        const SizedBox(width: 12),
                        const Expanded(child: Text('ไม่สามารถโหลดอัตราแลกเปลี่ยนได้')),
                        TextButton(
                          onPressed: () => setState(() {
                            _rateFuture = ExchangeRateService().getUsdToThb();
                          }),
                          child: const Text('ลองใหม่'),
                        ),
                      ],
                    );
                  }
                  final rate = snapshot.data!;
                  return Row(
                    children: [
                      const Icon(Icons.currency_exchange, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '1 USD = ${rate.toStringAsFixed(2)} บาท',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      const Text('วันนี้', style: TextStyle(fontSize: 12)),
                    ],
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          // ตัวเลือกเดือน
          Row(
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
          const SizedBox(height: 8),

          // ---------- กราฟวงกลม ----------
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(value: false, label: Text('รายจ่าย')),
                        ButtonSegment(value: true, label: Text('รายรับ')),
                      ],
                      selected: {_showIncome},
                      onSelectionChanged: (s) => setState(() {
                        _showIncome = s.first;
                        _touched = -1;
                      }),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (entries.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 48),
                      child: Text('ไม่มีข้อมูลในเดือนนี้'),
                    )
                  else ...[
                    SizedBox(
                      height: 220,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          PieChart(
                            PieChartData(
                              sectionsSpace: 2,
                              centerSpaceRadius: 55,
                              pieTouchData: PieTouchData(
                                touchCallback: (event, response) {
                                  setState(() {
                                    if (!event.isInterestedForInteractions ||
                                        response == null ||
                                        response.touchedSection == null) {
                                      _touched = -1;
                                      return;
                                    }
                                    _touched = response.touchedSection!
                                        .touchedSectionIndex;
                                  });
                                },
                              ),
                              sections: List.generate(entries.length, (i) {
                                final e = entries[i];
                                return PieChartSectionData(
                                  value: e.value,
                                  color: _palette[i % _palette.length],
                                  radius: i == _touched ? 70 : 60,
                                  title:
                                      '${(e.value / total * 100).toStringAsFixed(0)}%',
                                  titleStyle: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                );
                              }),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(_showIncome ? 'รายรับรวม' : 'รายจ่ายรวม',
                                  style: Theme.of(context).textTheme.bodySmall),
                              Text(
                                money.format(total),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // รายการหมวดหมู่ (legend)
                    ...List.generate(entries.length, (i) {
                      final e = entries[i];
                      return ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          radius: 8,
                          backgroundColor: _palette[i % _palette.length],
                        ),
                        title: Text(e.key),
                        trailing: Text(
                          '${money.format(e.value)}  '
                          '(${(e.value / total * 100).toStringAsFixed(1)}%)',
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ---------- กราฟแท่ง ----------
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('เปรียบเทียบ 6 เดือนล่าสุด',
                      style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  const Row(
                    children: [
                      _LegendDot(color: AppColors.income, label: 'รายรับ'),
                      SizedBox(width: 16),
                      _LegendDot(color: AppColors.expense, label: 'รายจ่าย'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 220,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: maxY * 1.2,
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          leftTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final i = value.toInt();
                                if (i < 0 || i >= months.length) {
                                  return const SizedBox.shrink();
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    DateFormat('MMM').format(months[i].month),
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        barGroups: List.generate(months.length, (i) {
                          final m = months[i];
                          return BarChartGroupData(
                            x: i,
                            barsSpace: 4,
                            barRods: [
                              BarChartRodData(
                                toY: m.income,
                                color: AppColors.income,
                                width: 10,
                                borderRadius: BorderRadius.circular(3),
                              ),
                              BarChartRodData(
                                toY: m.expense,
                                color: AppColors.expense,
                                width: 10,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(radius: 6, backgroundColor: color),
        const SizedBox(width: 6),
        Text(label),
      ],
    );
  }
}