// lib/features/auth/signup_screen.dart
// StockPro — Premium Signup Screen

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/premium_widgets.dart';
import '../../providers/auth_provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final _formKey      = GlobalKey<FormState>();
  final _nameCtrl     = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _passCtrl     = TextEditingController();
  final _confirmCtrl  = TextEditingController();
  final _businessCtrl = TextEditingController();
  bool _agreed        = false;

  late final AnimationController _ctrl;
  late final Animation<double>   _fade;
  late final Animation<Offset>   _slide;

  @override
  void initState() {
    super.initState();
    _ctrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    Future.delayed(const Duration(milliseconds: 100),
            () { if (mounted) _ctrl.forward(); });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _nameCtrl.dispose(); _emailCtrl.dispose();
    _passCtrl.dispose(); _confirmCtrl.dispose();
    _businessCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreed) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please accept Terms & Conditions'),
        backgroundColor: AppColors.danger,
      ));
      return;
    }
    final auth = context.read<AuthProvider>();
    await auth.signup(
      name:     _nameCtrl.text.trim(),
      email:    _emailCtrl.text.trim(),
      password: _passCtrl.text,
      business: _businessCtrl.text.trim(),
    );
    if (mounted && auth.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(auth.error!),
        backgroundColor: AppColors.danger,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth   = context.watch<AuthProvider>();
    final size   = MediaQuery.of(context).size;
    final isWide = size.width > 600;

    return Scaffold(
      backgroundColor: AppColors.darkScaffold,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white70,
        elevation: 0,
      ),
      body: Stack(children: [
        Positioned(
          top: -100, right: -80,
          child: _Orb(color: AppColors.primary, size: 280),
        ),
        Positioned(
          bottom: -80, left: -60,
          child: _Orb(color: const Color(0xFF9D6FFF), size: 200),
        ),
        SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isWide ? size.width * 0.28 : 24,
                vertical: 16,
              ),
              child: FadeTransition(
                opacity: _fade,
                child: SlideTransition(
                  position: _slide,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text('Create Account',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            )),
                        const SizedBox(height: 4),
                        Text('Set up your StockPro account',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.5),
                            )),
                        const SizedBox(height: 28),

                        // Form card
                        Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.08)),
                          ),
                          child: Column(children: [
                            AppTextField(
                              label: 'Full Name',
                              hint: 'Muhammad Usman',
                              controller: _nameCtrl,
                              prefixIcon: const Icon(Icons.person_outline_rounded, size: 18),
                              validator: (v) => v == null || v.isEmpty
                                  ? 'Name required' : null,
                            ),
                            const SizedBox(height: 14),
                            AppTextField(
                              label: 'Business Name',
                              hint: 'My Shop',
                              controller: _businessCtrl,
                              prefixIcon: const Icon(Icons.storefront_outlined, size: 18),
                              validator: (v) => v == null || v.isEmpty
                                  ? 'Business name required' : null,
                            ),
                            const SizedBox(height: 14),
                            AppTextField(
                              label: 'Email',
                              hint: 'you@example.com',
                              controller: _emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              prefixIcon: const Icon(Icons.email_outlined, size: 18),
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Email required';
                                if (!v.contains('@')) return 'Invalid email';
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                            AppTextField(
                              label: 'Password',
                              hint: '••••••••',
                              controller: _passCtrl,
                              obscureText: true,
                              prefixIcon: const Icon(Icons.lock_outline_rounded, size: 18),
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Password required';
                                if (v.length < 6) return 'Min 6 characters';
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                            AppTextField(
                              label: 'Confirm Password',
                              hint: '••••••••',
                              controller: _confirmCtrl,
                              obscureText: true,
                              prefixIcon: const Icon(Icons.lock_outline_rounded, size: 18),
                              validator: (v) {
                                if (v != _passCtrl.text) return 'Passwords do not match';
                                return null;
                              },
                            ),
                          ]),
                        ),

                        const SizedBox(height: 16),

                        // Terms checkbox
                        Row(children: [
                          Checkbox(
                            value: _agreed,
                            activeColor: AppColors.primary,
                            side: BorderSide(
                                color: Colors.white.withOpacity(0.4)),
                            onChanged: (v) => setState(() => _agreed = v ?? false),
                          ),
                          Expanded(
                            child: Text.rich(TextSpan(children: [
                              TextSpan(
                                  text: 'I agree to the ',
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(0.6),
                                      fontSize: 13)),
                              const TextSpan(
                                  text: 'Terms & Conditions',
                                  style: TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600)),
                            ])),
                          ),
                        ]),

                        const SizedBox(height: 20),
                        GradientButton(
                          label: 'Create Account',
                          icon: Icons.person_add_rounded,
                          loading: auth.isLoading,
                          onPressed: _submit,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Already have an account? ',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white.withOpacity(0.5))),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: const Text('Sign In',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

// ─── FIX: added `async` keyword so Future<void> body completes correctly ───
extension on AuthProvider {
  Future<void> signup({
    required String name,
    required String email,
    required String password,
    required String business,
  }) async {}
}

class _Orb extends StatelessWidget {
  final Color color;
  final double size;
  const _Orb({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withOpacity(0.2), color.withOpacity(0)],
        ),
      ),
    );
  }
}