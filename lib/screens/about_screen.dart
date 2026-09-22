import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const _members = [
    ('พิสิษฐ์ แก้วรัศมี', '6721602539'),
    ('นนทชา อินนุพัฒน์', '6721602466'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Project Info')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.account_balance_wallet,
                          color: AppColors.seed, size: 28),
                      const SizedBox(width: 10),
                      Text('Expense Tracker',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'แอปพลิเคชันบันทึกรายรับ-รายจ่ายส่วนบุคคล '
                    'พัฒนาด้วย Flutter และ Firebase '
                    'มีระบบสมัครสมาชิกและเข้าสู่ระบบด้วย Firebase Authentication ',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('ผู้สร้างแอปพลิเคชัน',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                for (var i = 0; i < _members.length; i++) ...[
                  if (i > 0) const Divider(height: 1),
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.incomeLight,
                      child: Text('${i + 1}',
                          style: const TextStyle(
                              color: AppColors.income,
                              fontWeight: FontWeight.bold)),
                    ),
                    title: Text(_members[i].$1),
                    subtitle: Text('รหัสนิสิต: ${_members[i].$2}'),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('เทคโนโลยีที่ใช้',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  SizedBox(height: 8),
                  _TechRow(label: 'Flutter (Dart)'),
                  _TechRow(label: 'Firebase Auth : ระบบล็อกอิน'),
                  _TechRow(label: 'Cloud Firestore : ฐานข้อมูล'),
                  _TechRow(label: 'Provider : จัดการ State'),
                  _TechRow(label: 'Chart : กราฟสถิติ'),
                  _TechRow(label: 'REST API : อัตราแลกเปลี่ยนเงินตรา'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TechRow extends StatelessWidget {
  final String label;
  const _TechRow({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          const Icon(Icons.check_circle, size: 16, color: AppColors.income),
          const SizedBox(width: 8),
          Expanded(child: Text(label)),
        ],
      ),
    );
  }
}