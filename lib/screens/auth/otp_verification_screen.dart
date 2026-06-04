import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;
  const OtpVerificationScreen({super.key, required this.email});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _otpCtl = TextEditingController();
  bool _loading = false;
  String? _error;
  bool _resending = false;

  @override
  void initState() {
    super.initState();
    _sendOtp();
  }

  Future<void> _sendOtp() async {
    setState(() => _error = null);
    final ok = await context.read<AuthProvider>().sendOtp(widget.email);
    if (!mounted) return;
    if (!ok) setState(() => _error = 'Failed to send OTP. Try again.');
  }

  Future<void> _verify() async {
    final otp = _otpCtl.text.trim();
    if (otp.length != 6) {
      setState(() => _error = 'Enter a valid 6-digit OTP');
      return;
    }
    setState(() { _loading = true; _error = null; });
    final ok = await context.read<AuthProvider>().verifyOtp(widget.email, otp);
    if (!mounted) return;
    if (ok) {
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    } else {
      setState(() { _loading = false; _error = context.read<AuthProvider>().error ?? 'Invalid OTP'; });
    }
  }

  Future<void> _resend() async {
    setState(() { _resending = true; _error = null; _otpCtl.clear(); });
    final ok = await context.read<AuthProvider>().sendOtp(widget.email);
    if (!mounted) return;
    setState(() => _resending = false);
    if (!ok) setState(() => _error = 'Failed to resend OTP.');
  }

  @override
  void dispose() {
    _otpCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: const Text('Verify Email', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.bgDark,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Container(
              width: 90, height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent.withValues(alpha: 0.1),
                border: Border.all(color: AppColors.accent.withValues(alpha: 0.3), width: 2),
              ),
              child: const Icon(Icons.mail_outline_rounded, color: AppColors.accent, size: 40),
            ),
            const SizedBox(height: 24),
            const Text('Check Your Email',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white, fontFamily: 'Poppins')),
            const SizedBox(height: 8),
            Text('We sent a 6-digit OTP to',
                style: TextStyle(color: AppColors.textMuted, fontSize: 14, fontFamily: 'Poppins')),
            Text(widget.email,
                style: const TextStyle(color: AppColors.accent, fontSize: 14, fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
            const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                controller: _otpCtl,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: const TextStyle(fontFamily: 'Poppins', color: Colors.white, fontSize: 28, letterSpacing: 12),
                decoration: const InputDecoration(
                  counterText: '',
                  hintText: '000000',
                  hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 28, letterSpacing: 12),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 18),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_error != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                ),
                child: Text(_error!, textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.accent, fontSize: 13, fontFamily: 'Poppins')),
              ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton(
                onPressed: _loading ? null : _verify,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _loading
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.black))
                    : const Text('Verify OTP', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Didn't receive?", style: TextStyle(color: AppColors.textMuted, fontSize: 13, fontFamily: 'Poppins')),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: _resending ? null : _resend,
                  child: Text(_resending ? 'Resending...' : 'Resend OTP',
                      style: TextStyle(
                        color: _resending ? AppColors.textMuted : AppColors.accent,
                        fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
