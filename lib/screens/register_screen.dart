import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _auth = AuthService();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final err = await _auth.register(_emailCtrl.text, _passCtrl.text);
    if (!mounted) return;
    if (err == null) {
      // สมัครสำเร็จ Firebase ล็อกอินให้อัตโนมัติ -> ปิดหน้านี้เพื่อให้เห็น Home
      Navigator.of(context).pop();
    } else {
      setState(() {
        _loading = false;
        _error = err;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('สมัครสมาชิก')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'อีเมล',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (v) => (v == null || !v.contains('@'))
                    ? 'กรุณากรอกอีเมลให้ถูกต้อง'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'รหัสผ่าน',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                validator: (v) => (v == null || v.length < 6)
                    ? 'รหัสผ่านอย่างน้อย 6 ตัวอักษร'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'ยืนยันรหัสผ่าน',
                  prefixIcon: Icon(Icons.lock_reset),
                ),
                validator: (v) =>
                    v != _passCtrl.text ? 'รหัสผ่านไม่ตรงกัน' : null,
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.error)),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('สมัครสมาชิก'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}