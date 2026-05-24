// lib/features/auth/login_screen.dart
// StockPro — Premium Login Screen (Dark glass morphism)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/premium_widgets.dart';
import '../../providers/auth_provider.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey   = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();

  late final AnimationController _ctrl;
  late final Animation<double>   _fade;
  late final Animation<Offset>   _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.14), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    await auth.login(_emailCtrl.text.trim(), _passCtrl.text);
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
      body: Stack(
        children: [
          // ── Gradient background orbs ───────────────────
          Positioned(
            top: -80, left: -60,
            child: _Orb(color: AppColors.primary, size: 260),
          ),
          Positioned(
            bottom: -60, right: -80,
            child: _Orb(color: const Color(0xFF9D6FFF), size: 220),
          ),

          // ── Content ───────────────────────────────────
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isWide ? size.width * 0.3 : 24,
                  vertical: 32,
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
                          // Logo
                          Center(
                            child: Container(
                              width: 64, height: 64,
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.4),
                                    blurRadius: 24,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.storefront_rounded,
                                  color: Colors.white, size: 32),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Center(
                            child: Text('StockPro',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                )),
                          ),
                          const SizedBox(height: 6),
                          Center(
                            child: Text('Smart Inventory & POS System',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white.withOpacity(0.5),
                                )),
                          ),
                          const SizedBox(height: 40),

                          // Glass form card
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.08)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 30,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Text('Welcome Back',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: -0.3,
                                    )),
                                const SizedBox(height: 4),
                                Text('Sign in to your account',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.white.withOpacity(0.5),
                                    )),
                                const SizedBox(height: 24),

                                AppTextField(
                                  label: 'Email Address',
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
                                const SizedBox(height: 16),

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
                                const SizedBox(height: 24),

                                GradientButton(
                                  label: 'Sign In',
                                  onPressed: _submit,
                                  loading: auth.isLoading,
                                  icon: Icons.login_rounded,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Don't have an account? ",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white.withOpacity(0.5),
                                  )),
                              GestureDetector(
                                onTap: () => Navigator.push(context,
                                    MaterialPageRoute(builder: (_) => const SignupScreen())),
                                child: const Text('Create one',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                    )),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
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
          colors: [color.withOpacity(0.25), color.withOpacity(0)],
        ),
      ),
    );
  }
}