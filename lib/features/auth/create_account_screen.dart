import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/security/security_constants.dart';
import '../../core/validation/credential_validator.dart';
import '../../l10n/app_localizations.dart';
import '../home/home_screen.dart';
import 'auth_screen.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key, this.auth});

  final FirebaseAuth? auth;

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _isContinuingAsGuest = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  FirebaseAuth get _auth => widget.auth ?? FirebaseAuth.instance;

  AppLocalizations get _l10n => AppLocalizations.of(context);

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    final name = value?.trim() ?? '';

    if (name.isEmpty) {
      return _l10n.fullNameRequired;
    }

    if (name.length < 2) {
      return _l10n.nameTooShort;
    }

    if (name.length > SecurityConstants.maxTextInputLength) {
      return _l10n.nameTooLong;
    }

    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return _l10n.confirmPasswordRequired;
    }

    if (value != _passwordController.text) {
      return _l10n.passwordsDoNotMatch;
    }

    return null;
  }

  String? _localizedValidationMessage(String? message) {
    if (message == null) return null;

    switch (message) {
      case 'Email is required.':
        return _l10n.emailRequired;
      case 'Email is too long.':
        return _l10n.emailTooLong;
      case 'Enter a valid email address.':
        return _l10n.enterValidEmail;
      case 'Password is required.':
        return _l10n.passwordRequired;
      case 'Password must contain at least 8 characters.':
        return _l10n.passwordTooShort;
      case 'Password is too long.':
        return _l10n.passwordTooLong;
      default:
        return message;
    }
  }

  String _registrationError(FirebaseAuthException error) {
    switch (error.code) {
      case 'email-already-in-use':
        return _l10n.emailAlreadyInUse;
      case 'invalid-email':
        return _l10n.enterValidEmail;
      case 'weak-password':
        return _l10n.weakPassword;
      case 'operation-not-allowed':
        return _l10n.registrationNotEnabled;
      case 'too-many-requests':
        return _l10n.tooManyAttempts;
      case 'network-request-failed':
        return _l10n.networkError;
      default:
        return _l10n.unableToCreateAccount;
    }
  }

  Future<void> _submit() async {
    if (_isLoading || _isContinuingAsGuest) return;

    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      try {
        await credential.user?.updateDisplayName(_nameController.text.trim());
      } catch (error, stackTrace) {
        debugPrint(
          'PlantPulse: display-name update failed '
          '(${error.runtimeType}).',
        );
        debugPrintStack(stackTrace: stackTrace);
      }

      if (!mounted) return;

      TextInput.finishAutofillContext(shouldSave: true);

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;

      debugPrint('PlantPulse registration failed: ${error.code}');
      _showMessage(_registrationError(error));
    } catch (error, stackTrace) {
      if (!mounted) return;

      debugPrint('PlantPulse registration failed (${error.runtimeType}).');
      debugPrintStack(stackTrace: stackTrace);
      _showMessage(_l10n.unableToCreateAccount);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _continueAsGuest() async {
    if (_isLoading || _isContinuingAsGuest) return;

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

  void _openSignIn() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => AuthScreen(auth: widget.auth)),
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
    final isBusy = _isLoading || _isContinuingAsGuest;

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: AutofillGroup(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Center(child: _PlantMark()),
                      const SizedBox(height: 20),
                      Text(
                        _l10n.createAccount,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _l10n.createAccountDescription,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 28),

                      _FieldLabel(_l10n.fullName),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.name],
                        validator: _validateName,
                        decoration: InputDecoration(
                          hintText: _l10n.fullNameHint,
                          prefixIcon: const Icon(Icons.person_outline),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),

                      _FieldLabel(_l10n.email),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autocorrect: false,
                        enableSuggestions: false,
                        autofillHints: const [AutofillHints.email],
                        validator:
                            (value) => _localizedValidationMessage(
                              CredentialValidator.validateEmail(value ?? ''),
                            ),
                        decoration: InputDecoration(
                          hintText: _l10n.emailHint,
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),

                      _FieldLabel(_l10n.password),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.newPassword],
                        validator:
                            (value) => _localizedValidationMessage(
                              CredentialValidator.validatePassword(value ?? ''),
                            ),
                        decoration: InputDecoration(
                          hintText: _l10n.createPasswordHint,
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            tooltip:
                                _obscurePassword
                                    ? _l10n.showPassword
                                    : _l10n.hidePassword,
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
                      const SizedBox(height: 8),
                      Text(
                        '${_l10n.passwordRequirements}\n'
                        '• ${_l10n.passwordMinimumRequirement}\n'
                        '• ${_l10n.passwordUppercaseRequirement}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),

                      _FieldLabel(_l10n.confirmPassword),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.newPassword],
                        validator: _validateConfirmPassword,
                        onFieldSubmitted: (_) => _submit(),
                        decoration: InputDecoration(
                          hintText: _l10n.confirmPasswordHint,
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            tooltip:
                                _obscureConfirmPassword
                                    ? _l10n.showPassword
                                    : _l10n.hidePassword,
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      SizedBox(
                        height: 52,
                        child: FilledButton(
                          onPressed: isBusy ? null : _submit,
                          child:
                              _isLoading
                                  ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : Text(_l10n.createAccountButton),
                        ),
                      ),
                      const SizedBox(height: 16),

                      OutlinedButton(
                        onPressed: isBusy ? null : _continueAsGuest,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                        ),
                        child:
                            _isContinuingAsGuest
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                : Text(_l10n.continueAsGuest),
                      ),
                      const SizedBox(height: 20),

                      Center(
                        child: TextButton(
                          onPressed: isBusy ? null : _openSignIn,
                          child: Text(_l10n.alreadyHaveAccount),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _l10n.authenticationSecurityNote,
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

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(label, style: Theme.of(context).textTheme.labelLarge);
  }
}

class _PlantMark extends StatelessWidget {
  const _PlantMark();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Icon(
        Icons.eco_outlined,
        size: 40,
        color: colors.onPrimaryContainer,
      ),
    );
  }
}
