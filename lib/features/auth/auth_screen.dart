import 'package:flutter/material.dart';
import '../../app/app_theme.dart';
import '../home/home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool obscure = true;

  void enter() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 38, 22, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PlantMark(),
              const SizedBox(height: 32),
              const Text(
                'Welcome back',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Sign in to keep your plant records, care plans and scan history together.',
                style: TextStyle(color: PlantPulseColors.muted, height: 1.5),
              ),
              const SizedBox(height: 28),
              const Text('Email', style: TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              const TextField(
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'you@example.com',
                  prefixIcon: Icon(Icons.mail_outline_rounded),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Password', style: TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              TextField(
                obscureText: obscure,
                decoration: InputDecoration(
                  hintText: 'Enter your password',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => obscure = !obscure),
                    icon: Icon(
                      obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text('Forgot password?'),
                ),
              ),
              FilledButton(
                onPressed: enter,
                child: const Text('Sign In'),
              ),
              const SizedBox(height: 22),
              const _OrDivider(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: enter,
                      icon: const Icon(Icons.g_mobiledata_rounded),
                      label: const Text('Google'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: enter,
                      icon: const Icon(Icons.apple_rounded),
                      label: const Text('Apple'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: enter,
                icon: const Icon(Icons.fingerprint_rounded),
                label: const Text('Continue with biometrics'),
              ),
              const SizedBox(height: 18),
              Center(
                child: TextButton(
                  onPressed: enter,
                  child: const Text('Continue as Guest'),
                ),
              ),
              Center(
                child: TextButton(
                  onPressed: () {},
                  child: const Text('New here? Create account'),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'Your password is never displayed or stored by this UI.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: PlantPulseColors.muted, fontSize: 10),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PlantMark extends StatelessWidget {
  const PlantMark({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: PlantPulseColors.mint,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Icon(Icons.eco_rounded, color: PlantPulseColors.green, size: 30),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'OR',
            style: TextStyle(
              color: PlantPulseColors.muted,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}
