import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/validation/credential_validator.dart';
import '../../l10n/app_localizations.dart';
import '../home/home_screen.dart';
import 'create_account_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, this.auth});

  final FirebaseAuth? auth;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isSigningIn = false;
  bool _isSendingReset = false;
  bool _isContinuingAsGuest = false;

  FirebaseAuth get _auth => widget.auth ?? FirebaseAuth.instance;

  bool get _isBusy => _isSigningIn || _isSendingReset || _isContinuingAsGuest;

  AppLocalizations get _l10n => AppLocalizations.of(context);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _localizedValidationMessage(String? message) {
    if (message == null) return null;

    final l10n = _l10n;

    switch (message) {
      case 'Email is required.':
        return l10n.emailRequired;
      case 'Email is too long.':
        return l10n.emailTooLong;
      case 'Enter a valid email address.':
        return l10n.enterValidEmail;
      case 'Password is required.':
        return l10n.passwordRequired;
      case 'Password must contain at least 8 characters.':
        return l10n.passwordTooShort;
      case 'Password is too long.':
        return l10n.passwordTooLong;
      default:
        return message;
    }
  }

  Future<void> _submit() async {
    if (_isBusy || !_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isSigningIn = true);

    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      TextInput.finishAutofillContext(shouldSave: true);

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;

      final l10n = _l10n;
      final String message;

      switch (error.code) {
        case 'invalid-credential':
        case 'wrong-password':
        case 'user-not-found':
          message = l10n.invalidEmailOrPassword;
          break;
        case 'invalid-email':
          message = l10n.enterValidEmail;
          break;
        case 'user-disabled':
          message = l10n.accountDisabled;
          break;
        case 'too-many-requests':
          message = l10n.tooManyAttempts;
          break;
        case 'network-request-failed':
          message = l10n.networkError;
          break;
        case 'operation-not-allowed':
          message = l10n.signInNotEnabled;
          break;
        default:
          message = l10n.unableToSignIn;
      }

      _showMessage(message);
    } catch (_) {
      if (!mounted) return;
      _showMessage(_l10n.unableToSignIn);
    } finally {
      if (mounted) {
        setState(() => _isSigningIn = false);
      }
    }
  }

  Future<void> _sendPasswordReset() async {
    if (_isBusy) return;

    final email = _emailController.text.trim();
    final validationMessage = CredentialValidator.validateEmail(email);

    if (validationMessage != null) {
      _showMessage(_localizedValidationMessage(validationMessage)!);
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isSendingReset = true);

    try {
      await _auth.sendPasswordResetEmail(email: email);

      if (!mounted) return;

      _showMessage(_l10n.passwordResetSent);
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;

      if (error.code == 'too-many-requests') {
        _showMessage(_l10n.tooManyAttempts);
      } else if (error.code == 'network-request-failed') {
        _showMessage(_l10n.networkError);
      } else {
        _showMessage(_l10n.unableToProcessRequest);
      }
    } catch (_) {
      if (!mounted) return;
      _showMessage(_l10n.unableToProcessRequest);
    } finally {
      if (mounted) {
        setState(() => _isSendingReset = false);
      }
    }
  }

  Future<void> _continueAsGuest() async {
    if (_isBusy) return;

    setState(() => _isContinuingAsGuest = true);

    try {
      await _auth.signOut();

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } catch (_) {
      if (!mounted) return;
      _showMessage(_l10n.unableToSwitchGuest);
    } finally {
      if (mounted) {
        setState(() => _isContinuingAsGuest = false);
      }
    }
  }

  void _openCreateAccount() {
    if (_isBusy) return;

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CreateAccountScreen(auth: widget.auth),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = _l10n;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: AutofillGroup(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Center(child: PlantMark()),
                      const SizedBox(height: 20),
                      Text(
                        l10n.welcomeBack,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.signInToContinue,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 32),

                      Text(l10n.email, style: theme.textTheme.labelLarge),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autocorrect: false,
                        enableSuggestions: false,
                        autofillHints: const [
                          AutofillHints.username,
                          AutofillHints.email,
                        ],
                        validator:
                            (value) => _localizedValidationMessage(
                              CredentialValidator.validateEmail(value ?? ''),
                            ),
                        decoration: InputDecoration(
                          hintText: l10n.emailHint,
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),

                      Text(l10n.password, style: theme.textTheme.labelLarge),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.password],
                        validator:
                            (value) => _localizedValidationMessage(
                              CredentialValidator.validatePassword(value ?? ''),
                            ),
                        onFieldSubmitted: (_) => _submit(),
                        decoration: InputDecoration(
                          hintText: l10n.passwordHint,
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            tooltip:
                                _obscurePassword
                                    ? l10n.showPassword
                                    : l10n.hidePassword,
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _isBusy ? null : _sendPasswordReset,
                          child:
                              _isSendingReset
                                  ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : Text(l10n.forgotPassword),
                        ),
                      ),
                      const SizedBox(height: 12),

                      SizedBox(
                        height: 52,
                        child: FilledButton(
                          onPressed: _isBusy ? null : _submit,
                          child:
                              _isSigningIn
                                  ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : Text(l10n.signIn),
                        ),
                      ),
                      const SizedBox(height: 24),

                      Center(
                        child: TextButton(
                          onPressed: _isBusy ? null : _continueAsGuest,
                          child:
                              _isContinuingAsGuest
                                  ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : Text(l10n.continueAsGuest),
                        ),
                      ),
                      const SizedBox(height: 12),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(child: Text(l10n.newHere)),
                          Flexible(
                            child: TextButton(
                              onPressed: _isBusy ? null : _openCreateAccount,
                              child: Text(l10n.createAccount),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Text(
                        l10n.authenticationSecurityNote,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
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
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Icon(
        Icons.eco_outlined,
        size: 42,
        color: colors.onPrimaryContainer,
      ),
    );
  }
}
