// lib/features/auth/signup_screen.dart
// ─────────────────────────────────────────────────────────────
//  StockPro — Premium Sign Up Screen
//  Design: Dark glass morphism — matches login_screen.dart style
//  Note:   POS mein sirf Admin signup kar sakta hai — baaki
//          staff ko admin createStaffAccount() se banata hai.
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final _formKey       = GlobalKey<FormState>();
  final _nameCtrl      = TextEditingController();
  final _emailCtrl     = TextEditingController();
  final _passCtrl      = TextEditingController();
  final _confirmCtrl   = TextEditingController();
  final _businessCtrl  = TextEditingController();

  bool _obscurePass    = true;
  bool _obscureConfirm = true;
  bool _agreed         = false;

  // Focus glow states
  bool _nameFocus     = false;
  bool _emailFocus    = false;
  bool _passFocus     = false;
  bool _confirmFocus  = false;
  bool _bizFocus      = false;

  late final AnimationController _ctrl;
  late final Animation<Offset>   _slide;
  late final Animation<double>   _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.16),
      end:   Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    _businessCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreed) {
      _showSnack('Terms & Conditions accept karein', isError: true);
      return;
    }

    final auth = context.read<AuthProvider>();
    await auth.registerAdmin(
      name:         _nameCtrl.text.trim(),
      email:        _emailCtrl.text.trim(),
      password:     _passCtrl.text,
      businessName: _businessCtrl.text.trim(),
    );

    if (mounted && auth.error != null) {
      _showSnack(auth.error!, isError: true);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError
            ? const Color(0xFFE24B4A)
            : const Color(0xFF1D9E75),
        behavior:  SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // Password strength
  _PasswordStrength _strength(String p) {
    if (p.isEmpty)  return _PasswordStrength.none;
    if (p.length < 6) return _PasswordStrength.weak;
    int score = 0;
    if (p.length >= 8)                                  score++;
    if (RegExp(r'[A-Z]').hasMatch(p))                  score++;
    if (RegExp(r'[0-9]').hasMatch(p))                  score++;
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(p)) score++;
    if (score <= 1) return _PasswordStrength.weak;
    if (score == 2) return _PasswordStrength.fair;
    if (score == 3) return _PasswordStrength.good;
    return _PasswordStrength.strong;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth   = context.watch<AuthProvider>();
    final strength = _strength(_passCtrl.text);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF060D1A) : const Color(0xFFF0F4FA),
      body: Stack(
        children: [
          _Background(isDark: isDark),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Back button ──────────────────────────────
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(0.06)
                            : Colors.black.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withOpacity(0.08)
                              : Colors.black.withOpacity(0.08),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 13,
                            color: isDark
                                ? Colors.white.withOpacity(0.55)
                                : Colors.black.withOpacity(0.45),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Back to login',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? Colors.white.withOpacity(0.55)
                                  : Colors.black.withOpacity(0.45),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Header ───────────────────────────────────
                  SlideTransition(
                    position: _slide,
                    child: FadeTransition(
                      opacity: _fade,
                      child: _Header(isDark: isDark),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Form ─────────────────────────────────────
                  SlideTransition(
                    position: _slide,
                    child: FadeTransition(
                      opacity: _fade,
                      child: _buildFormCard(isDark, auth, strength),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Footer ───────────────────────────────────
                  SlideTransition(
                    position: _slide,
                    child: FadeTransition(
                      opacity: _fade,
                      child: _buildFooter(isDark),
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

  Widget _buildFormCard(
      bool isDark, AuthProvider auth, _PasswordStrength strength) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: isDark
            ? const Color(0xFF0D1B2A).withOpacity(0.85)
            : Colors.white.withOpacity(0.88),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.07)
              : Colors.black.withOpacity(0.06),
        ),
        boxShadow: [
          BoxShadow(
            color:      Colors.black.withOpacity(isDark ? 0.35 : 0.10),
            blurRadius: 40,
            offset:     const Offset(0, 12),
          ),
        ],
      ),
      padding: const EdgeInsets.all(26),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Section: Account Info ─────────────────────────
            _SectionBadge(label: 'Account Info', isDark: isDark),
            const SizedBox(height: 16),

            // Full name
            _FieldLabel(label: 'Full name', isDark: isDark),
            const SizedBox(height: 7),
            _GlowField(
              controller:    _nameCtrl,
              isFocused:     _nameFocus,
              isDark:        isDark,
              hintText:      'Muhammad Ali',
              prefixIcon:    Icons.person_outline_rounded,
              onFocusChange: (v) => setState(() => _nameFocus = v),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Naam likhein';
                if (v.trim().length < 3) return 'Poora naam likhein';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Email
            _FieldLabel(label: 'Email address', isDark: isDark),
            const SizedBox(height: 7),
            _GlowField(
              controller:    _emailCtrl,
              isFocused:     _emailFocus,
              isDark:        isDark,
              hintText:      'admin@mybusiness.com',
              prefixIcon:    Icons.alternate_email_rounded,
              keyboardType:  TextInputType.emailAddress,
              onFocusChange: (v) => setState(() => _emailFocus = v),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Email likhein';
                if (!v.contains('@') || !v.contains('.'))
                  return 'Valid email likhein';
                return null;
              },
            ),
            const SizedBox(height: 20),

            // ── Section: Business ─────────────────────────────
            _SectionBadge(label: 'Business', isDark: isDark),
            const SizedBox(height: 16),

            // Business name
            _FieldLabel(label: 'Business name', isDark: isDark),
            const SizedBox(height: 7),
            _GlowField(
              controller:    _businessCtrl,
              isFocused:     _bizFocus,
              isDark:        isDark,
              hintText:      'Ali General Store',
              prefixIcon:    Icons.store_outlined,
              onFocusChange: (v) => setState(() => _bizFocus = v),
              validator: (v) {
                if (v == null || v.trim().isEmpty)
                  return 'Business ka naam likhein';
                return null;
              },
            ),
            const SizedBox(height: 20),

            // ── Section: Security ─────────────────────────────
            _SectionBadge(label: 'Security', isDark: isDark),
            const SizedBox(height: 16),

            // Password
            _FieldLabel(label: 'Password', isDark: isDark),
            const SizedBox(height: 7),
            _GlowField(
              controller:    _passCtrl,
              isFocused:     _passFocus,
              isDark:        isDark,
              hintText:      'Min 8 characters',
              prefixIcon:    Icons.lock_outline_rounded,
              obscureText:   _obscurePass,
              onFocusChange: (v) => setState(() => _passFocus = v),
              onChanged:     (_) => setState(() {}),
              suffixIcon: GestureDetector(
                onTap: () => setState(() => _obscurePass = !_obscurePass),
                child: Icon(
                  _obscurePass
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 18,
                  color: isDark
                      ? Colors.white.withOpacity(0.30)
                      : Colors.black.withOpacity(0.30),
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Password likhein';
                if (v.length < 6) return 'Kam az kam 6 characters chahiye';
                return null;
              },
            ),

            // Password strength bar
            if (_passCtrl.text.isNotEmpty) ...[
              const SizedBox(height: 10),
              _PasswordStrengthBar(strength: strength, isDark: isDark),
            ],
            const SizedBox(height: 16),

            // Confirm password
            _FieldLabel(label: 'Confirm password', isDark: isDark),
            const SizedBox(height: 7),
            _GlowField(
              controller:    _confirmCtrl,
              isFocused:     _confirmFocus,
              isDark:        isDark,
              hintText:      'Password dobara likhein',
              prefixIcon:    Icons.lock_outline_rounded,
              obscureText:   _obscureConfirm,
              onFocusChange: (v) => setState(() => _confirmFocus = v),
              suffixIcon: GestureDetector(
                onTap: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
                child: Icon(
                  _obscureConfirm
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 18,
                  color: isDark
                      ? Colors.white.withOpacity(0.30)
                      : Colors.black.withOpacity(0.30),
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty)
                  return 'Password dobara likhein';
                if (v != _passCtrl.text)
                  return 'Passwords match nahi kar rahe';
                return null;
              },
            ),
            const SizedBox(height: 22),

            // ── Terms checkbox ────────────────────────────────
            GestureDetector(
              onTap: () => setState(() => _agreed = !_agreed),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: _agreed
                          ? AppColors.primary
                          : Colors.transparent,
                      border: Border.all(
                        color: _agreed
                            ? AppColors.primary
                            : isDark
                            ? Colors.white.withOpacity(0.20)
                            : Colors.black.withOpacity(0.20),
                        width: 1.5,
                      ),
                    ),
                    child: _agreed
                        ? const Icon(Icons.check_rounded,
                        size: 13, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 12.5,
                          color: isDark
                              ? Colors.white.withOpacity(0.42)
                              : Colors.black.withOpacity(0.45),
                          height: 1.5,
                        ),
                        children: [
                          const TextSpan(text: 'Main '),
                          TextSpan(
                            text: 'Terms & Conditions',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const TextSpan(text: ' aur '),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const TextSpan(text: ' se agree karta hun'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),

            // ── Submit button ─────────────────────────────────
            _SignupButton(isLoading: auth.isLoading, onTap: _submit),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(bool isDark) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Pehle se account hai? ',
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? Colors.white.withOpacity(0.35)
                    : Colors.black.withOpacity(0.40),
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Text(
                'Sign in karein',
                style: TextStyle(
                  fontSize:   13,
                  fontWeight: FontWeight.w600,
                  color:      AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 28, height: 1,
              color: isDark
                  ? Colors.white.withOpacity(0.10)
                  : Colors.black.withOpacity(0.10),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                'Secured with Firebase Auth',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark
                      ? Colors.white.withOpacity(0.20)
                      : Colors.black.withOpacity(0.22),
                  letterSpacing: 0.2,
                ),
              ),
            ),
            Container(
              width: 28, height: 1,
              color: isDark
                  ? Colors.white.withOpacity(0.10)
                  : Colors.black.withOpacity(0.10),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          '© 2025 StockPro — All rights reserved',
          style: TextStyle(
            fontSize: 10.5,
            color: isDark
                ? Colors.white.withOpacity(0.14)
                : Colors.black.withOpacity(0.17),
          ),
        ),
      ],
    );
  }
}

// ── Background blobs ────────────────────────────────────────────
class _Background extends StatelessWidget {
  final bool isDark;
  const _Background({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned(
        top: -80, right: -80,
        child: Container(
          width: 260, height: 260,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [
              (isDark
                  ? const Color(0xFF1E3A5F)
                  : const Color(0xFFBBD4F5)).withOpacity(0.55),
              Colors.transparent,
            ]),
          ),
        ),
      ),
      Positioned(
        bottom: 60, left: -100,
        child: Container(
          width: 300, height: 300,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [
              (isDark
                  ? const Color(0xFF0F3460)
                  : const Color(0xFFD0E8FF)).withOpacity(0.40),
              Colors.transparent,
            ]),
          ),
        ),
      ),
    ]);
  }
}

// ── Header ──────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final bool isDark;
  const _Header({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color:  accent.withOpacity(0.12),
            border: Border.all(color: accent.withOpacity(0.25)),
          ),
          child: Icon(Icons.store_outlined, color: accent, size: 22),
        ),
        const SizedBox(height: 16),
        Text(
          'Create your account',
          style: TextStyle(
            fontFamily:    'Georgia',
            fontSize:      28,
            fontWeight:    FontWeight.w700,
            letterSpacing: -0.4,
            color: isDark ? Colors.white : const Color(0xFF0D1B2A),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Apna business setup karein — free mein shuru karein',
          style: TextStyle(
            fontSize: 13,
            color: isDark
                ? Colors.white.withOpacity(0.38)
                : const Color(0xFF0D1B2A).withOpacity(0.42),
          ),
        ),
      ],
    );
  }
}

// ── Section badge ───────────────────────────────────────────────
class _SectionBadge extends StatelessWidget {
  final String label;
  final bool   isDark;
  const _SectionBadge({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color:        AppColors.primary.withOpacity(0.10),
            borderRadius: BorderRadius.circular(6),
            border:       Border.all(color: AppColors.primary.withOpacity(0.22)),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize:      11,
              fontWeight:    FontWeight.w600,
              letterSpacing: 0.5,
              color:         AppColors.primary.withOpacity(0.85),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 1,
            color: isDark
                ? Colors.white.withOpacity(0.07)
                : Colors.black.withOpacity(0.07),
          ),
        ),
      ],
    );
  }
}

// ── Field label ─────────────────────────────────────────────────
class _FieldLabel extends StatelessWidget {
  final String label;
  final bool   isDark;
  const _FieldLabel({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) => Text(
    label,
    style: TextStyle(
      fontSize:      12.5,
      fontWeight:    FontWeight.w600,
      letterSpacing: 0.2,
      color: isDark
          ? Colors.white.withOpacity(0.52)
          : const Color(0xFF0D1B2A).withOpacity(0.52),
    ),
  );
}

// ── Glow input field ────────────────────────────────────────────
class _GlowField extends StatelessWidget {
  final TextEditingController      controller;
  final bool                       isFocused;
  final bool                       isDark;
  final String                     hintText;
  final IconData                   prefixIcon;
  final bool                       obscureText;
  final TextInputType?             keyboardType;
  final Widget?                    suffixIcon;
  final ValueChanged<bool>         onFocusChange;
  final ValueChanged<String>?      onChanged;
  final FormFieldValidator<String>? validator;

  const _GlowField({
    required this.controller,
    required this.isFocused,
    required this.isDark,
    required this.hintText,
    required this.prefixIcon,
    this.obscureText   = false,
    this.keyboardType,
    this.suffixIcon,
    required this.onFocusChange,
    this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.primary;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: isFocused
            ? [BoxShadow(
          color:       accent.withOpacity(0.20),
          blurRadius:  14,
          spreadRadius: 1,
        )]
            : [],
      ),
      child: Focus(
        onFocusChange: onFocusChange,
        child: TextFormField(
          controller:   controller,
          obscureText:  obscureText,
          keyboardType: keyboardType,
          validator:    validator,
          onChanged:    onChanged,
          style: TextStyle(
            fontSize: 14.5,
            color: isDark ? Colors.white : const Color(0xFF0D1B2A),
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              fontSize: 14,
              color: isDark
                  ? Colors.white.withOpacity(0.20)
                  : Colors.black.withOpacity(0.23),
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 14, right: 10),
              child: Icon(
                prefixIcon,
                size: 18,
                color: isFocused
                    ? accent
                    : (isDark
                    ? Colors.white.withOpacity(0.28)
                    : Colors.black.withOpacity(0.28)),
              ),
            ),
            prefixIconConstraints:
            const BoxConstraints(minWidth: 46, minHeight: 0),
            suffixIcon: suffixIcon != null
                ? Padding(
              padding: const EdgeInsets.only(right: 14),
              child: suffixIcon,
            )
                : null,
            suffixIconConstraints:
            const BoxConstraints(minWidth: 40, minHeight: 0),
            filled:    true,
            fillColor: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.black.withOpacity(0.04),
            contentPadding:
            const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:   BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: isDark
                    ? Colors.white.withOpacity(0.09)
                    : Colors.black.withOpacity(0.09),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: accent, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
              const BorderSide(color: Color(0xFFE24B4A)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                  color: Color(0xFFE24B4A), width: 1.5),
            ),
            errorStyle: const TextStyle(fontSize: 11.5),
          ),
        ),
      ),
    );
  }
}

// ── Password strength bar ───────────────────────────────────────
enum _PasswordStrength { none, weak, fair, good, strong }

class _PasswordStrengthBar extends StatelessWidget {
  final _PasswordStrength strength;
  final bool              isDark;
  const _PasswordStrengthBar(
      {required this.strength, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final configs = {
      _PasswordStrength.none:   (0,   Colors.transparent,        ''),
      _PasswordStrength.weak:   (1,   const Color(0xFFE24B4A),   'Weak'),
      _PasswordStrength.fair:   (2,   const Color(0xFFEF9F27),   'Fair'),
      _PasswordStrength.good:   (3,   const Color(0xFF5DCAA5),   'Good'),
      _PasswordStrength.strong: (4,   const Color(0xFF1D9E75),   'Strong'),
    };
    final (filled, color, label) = configs[strength]!;

    return Row(
      children: [
        Expanded(
          child: Row(
            children: List.generate(4, (i) {
              return Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
                  height: 3,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: i < filled
                        ? color
                        : (isDark
                        ? Colors.white.withOpacity(0.10)
                        : Colors.black.withOpacity(0.10)),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(width: 10),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            label,
            key: ValueKey(label),
            style: TextStyle(
              fontSize:   11,
              fontWeight: FontWeight.w600,
              color:      color,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Signup button ───────────────────────────────────────────────
class _SignupButton extends StatefulWidget {
  final bool         isLoading;
  final VoidCallback onTap;
  const _SignupButton({required this.isLoading, required this.onTap});

  @override
  State<_SignupButton> createState() => _SignupButtonState();
}

class _SignupButtonState extends State<_SignupButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>   _scale;

  @override
  void initState() {
    super.initState();
    _ctrl  = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween<double>(begin: 1.0, end: 0.97)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown:  (_) => _ctrl.forward(),
      onTapUp:    (_) { _ctrl.reverse(); widget.onTap(); },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(
              colors: widget.isLoading
                  ? [const Color(0xFF1A3A5C), const Color(0xFF1A3A5C)]
                  : [const Color(0xFF1565C0), const Color(0xFF1E88E5)],
              begin: Alignment.topLeft,
              end:   Alignment.bottomRight,
            ),
            boxShadow: widget.isLoading ? [] : [
              BoxShadow(
                color:      const Color(0xFF1565C0).withOpacity(0.38),
                blurRadius: 20,
                offset:     const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
              width:  22, height: 22,
              child:  CircularProgressIndicator(
                strokeWidth: 2.2,
                color:       Colors.white,
              ),
            )
                : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize:      15.5,
                    fontWeight:    FontWeight.w600,
                    color:         Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded,
                    color: Colors.white, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}