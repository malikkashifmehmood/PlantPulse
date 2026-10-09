import 'package:flutter/material.dart';

import '../../app/app_theme.dart';
import '../../core/security/security_constants.dart';
import '../../core/validation/credential_validator.dart';
import '../home/home_screen.dart';
import 'auth_screen.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmation = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    final name = (value ?? '').trim();

    if (name.isEmpty) {
      return 'Full name is required.';
    }

    if (name.length > SecurityConstants.maxTextInputLength) {
      return 'Full name is too long.';
    }

    if (name.length < 2) {
      return 'Enter at least 2 characters.';
    }

    return null;
  }

  String? _validateConfirmation(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password.';
    }

    if (value != _passwordController.text) {
      return 'Passwords do not match.';
    }

    return null;
  }

  void _submit() {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            'Account registration is not configured yet. '
            'No account has been created.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _continueAsGuest() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  tooltip: 'Go back',
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                const SizedBox(height: 12),
                const PlantMark(),
                const SizedBox(height: 26),
                const Text(
                  'Create account',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Start building a healthier garden with PlantPulse.',
                  style: TextStyle(color: PlantPulseColors.muted, height: 1.5),
                ),
                const SizedBox(height: 26),
                const _FieldLabel('Full name'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  maxLength: SecurityConstants.maxTextInputLength,
                  decoration: const InputDecoration(
                    hintText: 'Your full name',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                    counterText: '',
                  ),
                  validator: _validateName,
                ),
                const SizedBox(height: 16),
                const _FieldLabel('Email'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autocorrect: false,
                  enableSuggestions: false,
                  maxLength: SecurityConstants.maxTextInputLength,
                  decoration: const InputDecoration(
                    hintText: 'you@example.com',
                    prefixIcon: Icon(Icons.mail_outline_rounded),
                    counterText: '',
                  ),
                  validator:
                      (value) => CredentialValidator.validateEmail(value ?? ''),
                ),
                const SizedBox(height: 16),
                const _FieldLabel('Password'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.next,
                  autocorrect: false,
                  enableSuggestions: false,
                  maxLength: SecurityConstants.maxTextInputLength,
                  decoration: InputDecoration(
                    hintText: 'At least 8 characters',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    counterText: '',
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      tooltip:
                          _obscurePassword ? 'Show password' : 'Hide password',
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                  validator:
                      (value) =>
                          CredentialValidator.validatePassword(value ?? ''),
                  onChanged: (_) {
                    if (_confirmPasswordController.text.isNotEmpty) {
                      _formKey.currentState?.validate();
                    }
                  },
                ),
                const SizedBox(height: 16),
                const _FieldLabel('Confirm password'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmation,
                  textInputAction: TextInputAction.done,
                  autocorrect: false,
                  enableSuggestions: false,
                  maxLength: SecurityConstants.maxTextInputLength,
                  decoration: InputDecoration(
                    hintText: 'Re-enter your password',
                    prefixIcon: const Icon(Icons.verified_user_outlined),
                    counterText: '',
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscureConfirmation = !_obscureConfirmation;
                        });
                      },
                      tooltip:
                          _obscureConfirmation
                              ? 'Show password'
                              : 'Hide password',
                      icon: Icon(
                        _obscureConfirmation
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                  validator: _validateConfirmation,
                  onFieldSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _submit,
                    child: const Text('Create Account'),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const AuthScreen()),
                      );
                    },
                    child: const Text('Already have an account? Sign in'),
                  ),
                ),
                Center(
                  child: TextButton(
                    onPressed: _continueAsGuest,
                    child: const Text('Continue as Guest'),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Registration is not connected to a server yet. '
                  'Your account will not be created by this screen.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: PlantPulseColors.muted,
                    fontSize: 11,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(label, style: const TextStyle(fontWeight: FontWeight.w800));
  }
}
