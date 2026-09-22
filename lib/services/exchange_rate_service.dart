import 'dart:convert';
import 'package:http/http.dart' as http;

class ExchangeRateService {
  /// คืนค่า 1 USD = กี่บาท, โยน Exception ถ้าดึงไม่สำเร็จ
  Future<double> getUsdToThb() async {
    final uri = Uri.parse('https://open.er-api.com/v6/latest/USD');
    final res = await http.get(uri).timeout(const Duration(seconds: 10));

    if (res.statusCode != 200) {
      throw Exception('เชื่อมต่อ API ไม่สำเร็จ (${res.statusCode})');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (data['result'] != 'success') {
      throw Exception('API ตอบกลับผิดพลาด');
    }

    final rates = data['rates'] as Map<String, dynamic>;
    final thb = rates['THB'];
    if (thb == null) throw Exception('ไม่พบอัตราแลกเปลี่ยน THB');

    return (thb as num).toDouble();
  }
}