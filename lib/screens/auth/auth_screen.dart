import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import 'otp_verification_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;
  final _usernameCtl = TextEditingController();
  final _emailCtl = TextEditingController();
  final _passwordCtl = TextEditingController();
  bool _obscure = true;
  int _passwordStrength = 0;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    _passwordCtl.addListener(_updateStrength);
  }

  void _updateStrength() {
    final p = _passwordCtl.text;
    int score = 0;
    if (p.length >= 8) score++;
    if (p.contains(RegExp(r'[A-Z]'))) score++;
    if (p.contains(RegExp(r'[a-z]'))) score++;
    if (p.contains(RegExp(r'[0-9]'))) score++;
    if (p.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score++;
    setState(() => _passwordStrength = score);
  }

  @override
  void dispose() {
    _usernameCtl.dispose();
    _emailCtl.dispose();
    _passwordCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Consumer<AuthProvider>(
            builder: (context, auth, _) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    _buildHeader(),
                    const SizedBox(height: 32),
                    _buildToggle(),
                    const SizedBox(height: 28),
                    _buildFields(auth),
                    const SizedBox(height: 28),
                    _buildButton(auth),
                    if (auth.error != null) ...[
                      const SizedBox(height: 16),
                      _buildError(auth.error!),
                    ],
                    const SizedBox(height: 24),
                    _buildSwitchMode(),
                    const SizedBox(height: 16),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Icon(Icons.close_rounded,
                    color: AppColors.textMuted, size: 18),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Image.asset('assets/logo.png', height: 48, fit: BoxFit.contain),
        const SizedBox(height: 20),
        Text(
          _isLogin ? 'Welcome back' : 'Create account',
          style: const TextStyle(
            fontFamily: 'Poppins',
            color: Color(0xFFDDDDDD),
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _isLogin
              ? 'Sign in to continue discovering'
              : 'Join the community of film critics',
          style: const TextStyle(
            fontFamily: 'Poppins',
            color: AppColors.textMuted,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isLogin = true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _isLogin ? AppColors.accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Text(
                  'Sign In',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: _isLogin ? Colors.black : AppColors.textMuted,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isLogin = false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !_isLogin ? AppColors.accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Text(
                  'Sign Up',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: !_isLogin ? Colors.black : AppColors.textMuted,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFields(AuthProvider auth) {
    return Column(
      children: [
        _buildField(
          controller: _usernameCtl,
          hint: 'Username',
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 14),
        if (!_isLogin)
          _buildField(
            controller: _emailCtl,
            hint: 'Email',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
        if (!_isLogin) const SizedBox(height: 14),
        _buildField(
          controller: _passwordCtl,
          hint: 'Password',
          icon: Icons.lock_outline,
          obscure: true,
        ),
        if (!_isLogin && _passwordCtl.text.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildStrengthBar(),
        ],
        if (_passwordError != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(_passwordError!, style: const TextStyle(color: Color(0xFFE53935), fontSize: 12, fontFamily: 'Poppins')),
          ),
      ],
    );
  }

  Widget _buildStrengthBar() {
    final labels = ['Weak', 'Fair', 'Good', 'Strong', 'Very Strong'];
    final colors = [const Color(0xFFE53935), const Color(0xFFFB8C00), const Color(0xFFFDD835), const Color(0xFF43A047), const Color(0xFF00C853)];
    final label = labels[_passwordStrength];
    final color = colors[_passwordStrength];
    final segments = List.generate(5, (i) => i < _passwordStrength);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(5, (i) => Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: i < 4 ? 4 : 0),
              decoration: BoxDecoration(
                color: segments[i] ? color : AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          )),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: color, fontSize: 11, fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure && _obscure,
        keyboardType: keyboardType,
        style: const TextStyle(
          fontFamily: 'Poppins',
          color: Colors.white,
          fontSize: 15,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            fontFamily: 'Poppins',
            color: AppColors.textMuted,
            fontSize: 14,
          ),
          prefixIcon: Icon(icon, color: AppColors.textMuted, size: 20),
          suffixIcon: obscure
              ? GestureDetector(
                  onTap: () => setState(() => _obscure = !_obscure),
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    child: Icon(
                      _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: AppColors.textMuted,
                      size: 20,
                    ),
                  ),
                )
              : null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          filled: false,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildButton(AuthProvider auth) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: GestureDetector(
        onTap: auth.loading ? null : () => _handleAuth(auth),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.accent,
                AppColors.accentSecondary,
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: auth.loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.black,
                    ),
                  )
                : Text(
                    _isLogin ? 'Sign In' : 'Create Account',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildError(String error) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.accent, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(error,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  color: AppColors.accent,
                  fontSize: 13,
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchMode() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _isLogin ? "Don't have an account?" : 'Already have an account?',
          style: const TextStyle(
            fontFamily: 'Poppins',
            color: AppColors.textMuted,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: () => setState(() => _isLogin = !_isLogin),
          child: Text(
            _isLogin ? 'Sign Up' : 'Sign In',
            style: const TextStyle(
              fontFamily: 'Poppins',
              color: AppColors.accent,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  String? _validatePassword(String password) {
    if (password.length < 6) return 'At least 6 characters required';
    return null;
  }

  Future<void> _handleAuth(AuthProvider auth) async {
    final username = _usernameCtl.text.trim();
    final password = _passwordCtl.text.trim();
    if (username.isEmpty || password.isEmpty) return;
    if (!_isLogin) {
      final email = _emailCtl.text.trim();
      if (email.isEmpty) return;
      final pwdError = _validatePassword(password);
      if (pwdError != null) {
        setState(() => _passwordError = pwdError);
        return;
      }
      setState(() => _passwordError = null);
      final success = await auth.register(username, email, password);
      if (success && mounted) Navigator.push(context, MaterialPageRoute(builder: (_) => OtpVerificationScreen(email: email)));
    } else {
      final success = await auth.login(username, password);
      if (success && mounted) Navigator.pop(context);
    }
  }
}
