import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import 'widgets/logo_header.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey      = GlobalKey<FormState>();
  final _emailCtrl    = TextEditingController();
  final _passCtrl     = TextEditingController();
  bool  _obscure      = true;
  bool  _emailFocused = false;
  bool  _passFocused  = false;

  late final AnimationController _formCtrl;
  late final Animation<Offset>   _formSlide;
  late final Animation<double>   _formFade;

  @override
  void initState() {
    super.initState();
    _formCtrl = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 750),
    );
    _formSlide = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end:   Offset.zero,
    ).animate(CurvedAnimation(parent: _formCtrl, curve: Curves.easeOutCubic));
    _formFade = CurvedAnimation(parent: _formCtrl, curve: Curves.easeOut);

    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) _formCtrl.forward();
    });
  }

  @override
  void dispose() {
    _formCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    await auth.login(_emailCtrl.text.trim(), _passCtrl.text);
    if (mounted && auth.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:         Text(auth.error!),
          backgroundColor: const Color(0xFFE24B4A),
          behavior:        SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth   = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor:
      isDark ? const Color(0xFF060D1A) : const Color(0xFFF0F4FA),
      body: Stack(children: [
        _Background(isDark: isDark),
        SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const LogoHeader(),
                const SizedBox(height: 40),

                // Form card
                SlideTransition(
                  position: _formSlide,
                  child: FadeTransition(
                    opacity: _formFade,
                    child: _FormCard(
                      formKey:      _formKey,
                      emailCtrl:    _emailCtrl,
                      passCtrl:     _passCtrl,
                      obscure:      _obscure,
                      emailFocused: _emailFocused,
                      passFocused:  _passFocused,
                      isLoading:    auth.isLoading,
                      isDark:       isDark,
                      onEmailFocus: (v) => setState(() => _emailFocused = v),
                      onPassFocus:  (v) => setState(() => _passFocused  = v),
                      onTogglePass: () => setState(() => _obscure = !_obscure),
                      onSubmit:     _submit,
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // ✅ Sign Up link
                SlideTransition(
                  position: _formSlide,
                  child: FadeTransition(
                    opacity: _formFade,
                    child: _Footer(isDark: isDark),
                  ),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}

// ── Background ──────────────────────────────────────────────────
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
                  : const Color(0xFFBBD4F5))
                  .withOpacity(0.55),
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
                  : const Color(0xFFD0E8FF))
                  .withOpacity(0.40),
              Colors.transparent,
            ]),
          ),
        ),
      ),
    ]);
  }
}

// ── Form card ───────────────────────────────────────────────────
class _FormCard extends StatelessWidget {
  final GlobalKey<FormState>  formKey;
  final TextEditingController emailCtrl, passCtrl;
  final bool                  obscure, emailFocused, passFocused,
      isLoading, isDark;
  final ValueChanged<bool>    onEmailFocus, onPassFocus;
  final VoidCallback          onTogglePass, onSubmit;

  const _FormCard({
    required this.formKey,
    required this.emailCtrl,
    required this.passCtrl,
    required this.obscure,
    required this.emailFocused,
    required this.passFocused,
    required this.isLoading,
    required this.isDark,
    required this.onEmailFocus,
    required this.onPassFocus,
    required this.onTogglePass,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
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
      padding: const EdgeInsets.all(28),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back',
              style: TextStyle(
                fontFamily:    'Georgia',
                fontSize:      22,
                fontWeight:    FontWeight.w700,
                letterSpacing: -0.3,
                color: isDark ? Colors.white : const Color(0xFF0D1B2A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Sign in to your account to continue',
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? Colors.white.withOpacity(0.38)
                    : const Color(0xFF0D1B2A).withOpacity(0.42),
              ),
            ),
            const SizedBox(height: 28),

            // Email
            _FieldLabel(label: 'Email address', isDark: isDark),
            const SizedBox(height: 8),
            _GlowField(
              controller:   emailCtrl,
              isFocused:    emailFocused,
              isDark:       isDark,
              hintText:     'you@company.com',
              prefixIcon:   Icons.alternate_email_rounded,
              keyboardType: TextInputType.emailAddress,
              onFocusChange: onEmailFocus,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Email likhein';
                if (!v.contains('@')) return 'Valid email likhein';
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Password
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _FieldLabel(label: 'Password', isDark: isDark),
                Text(
                  'Forgot password?',
                  style: TextStyle(
                    fontSize:   12,
                    color:      AppColors.primary.withOpacity(0.85),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _GlowField(
              controller:    passCtrl,
              isFocused:     passFocused,
              isDark:        isDark,
              hintText:      '••••••••',
              prefixIcon:    Icons.lock_outline_rounded,
              obscureText:   obscure,
              onFocusChange: onPassFocus,
              suffixIcon: GestureDetector(
                onTap: onTogglePass,
                child: Icon(
                  obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 18,
                  color: isDark
                      ? Colors.white.withOpacity(0.35)
                      : Colors.black.withOpacity(0.35),
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Password likhein';
                if (v.length < 6) return 'Kam az kam 6 characters chahiye';
                return null;
              },
            ),
            const SizedBox(height: 28),

            _LoginButton(isLoading: isLoading, onTap: onSubmit),
          ],
        ),
      ),
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
          ? Colors.white.withOpacity(0.55)
          : const Color(0xFF0D1B2A).withOpacity(0.55),
    ),
  );
}

// ── Glow field ──────────────────────────────────────────────────
class _GlowField extends StatefulWidget {
  final TextEditingController      controller;
  final bool                       isFocused;
  final bool                       isDark;
  final String                     hintText;
  final IconData                   prefixIcon;
  final bool                       obscureText;
  final TextInputType?             keyboardType;
  final Widget?                    suffixIcon;
  final ValueChanged<bool>         onFocusChange;
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
    this.validator,
  });

  @override
  State<_GlowField> createState() => _GlowFieldState();
}

class _GlowFieldState extends State<_GlowField> {
  @override
  Widget build(BuildContext context) {
    final accent = AppColors.primary;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: widget.isFocused
            ? [BoxShadow(
          color:       accent.withOpacity(0.22),
          blurRadius:  16,
          spreadRadius: 1,
        )]
            : [],
      ),
      child: Focus(
        onFocusChange: widget.onFocusChange,
        child: TextFormField(
          controller:   widget.controller,
          obscureText:  widget.obscureText,
          keyboardType: widget.keyboardType,
          validator:    widget.validator,
          style: TextStyle(
            fontSize: 14.5,
            color: widget.isDark ? Colors.white : const Color(0xFF0D1B2A),
          ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: TextStyle(
              color: widget.isDark
                  ? Colors.white.withOpacity(0.22)
                  : Colors.black.withOpacity(0.25),
              fontSize: 14,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 14, right: 10),
              child: Icon(widget.prefixIcon,
                  size: 18,
                  color: widget.isFocused
                      ? accent
                      : (widget.isDark
                      ? Colors.white.withOpacity(0.30)
                      : Colors.black.withOpacity(0.30))),
            ),
            prefixIconConstraints:
            const BoxConstraints(minWidth: 46, minHeight: 0),
            suffixIcon: widget.suffixIcon != null
                ? Padding(
              padding: const EdgeInsets.only(right: 14),
              child:   widget.suffixIcon,
            )
                : null,
            suffixIconConstraints:
            const BoxConstraints(minWidth: 40, minHeight: 0),
            filled:    true,
            fillColor: widget.isDark
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
                color: widget.isDark
                    ? Colors.white.withOpacity(0.09)
                    : Colors.black.withOpacity(0.09),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:   BorderSide(color: accent, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
              const BorderSide(color: Color(0xFFE24B4A)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
              const BorderSide(color: Color(0xFFE24B4A), width: 1.5),
            ),
            errorStyle: const TextStyle(fontSize: 11.5),
          ),
        ),
      ),
    );
  }
}

// ── Login button ────────────────────────────────────────────────
class _LoginButton extends StatefulWidget {
  final bool         isLoading;
  final VoidCallback onTap;
  const _LoginButton({required this.isLoading, required this.onTap});

  @override
  State<_LoginButton> createState() => _LoginButtonState();
}

class _LoginButtonState extends State<_LoginButton>
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
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

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
            boxShadow: widget.isLoading
                ? []
                : [
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
              width:  22,
              height: 22,
              child:  CircularProgressIndicator(
                strokeWidth: 2.2,
                color:       Colors.white,
              ),
            )
                : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Sign In',
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

// ── Footer — Sign Up link ───────────────────────────────────────
class _Footer extends StatelessWidget {
  final bool isDark;
  const _Footer({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(children: [

        // ✅ Sign Up link
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Pehli baar aa rahe hain? ',
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? Colors.white.withOpacity(0.38)
                    : Colors.black.withOpacity(0.42),
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const SignupScreen()),
              ),
              child: Text(
                'Account banayein',
                style: TextStyle(
                  fontSize:   13,
                  fontWeight: FontWeight.w600,
                  color:      AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Divider
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                width: 28,
                height: 1,
                color: isDark
                    ? Colors.white.withOpacity(0.10)
                    : Colors.black.withOpacity(0.10)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                'Secured with Firebase Auth',
                style: TextStyle(
                  fontSize:      11,
                  color: isDark
                      ? Colors.white.withOpacity(0.22)
                      : Colors.black.withOpacity(0.25),
                  letterSpacing: 0.2,
                ),
              ),
            ),
            Container(
                width: 28,
                height: 1,
                color: isDark
                    ? Colors.white.withOpacity(0.10)
                    : Colors.black.withOpacity(0.10)),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          '© 2025 StockPro — All rights reserved',
          style: TextStyle(
            fontSize: 10.5,
            color: isDark
                ? Colors.white.withOpacity(0.15)
                : Colors.black.withOpacity(0.18),
          ),
        ),
      ]),
    );
  }
}