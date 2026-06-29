import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../components/button_component.dart';
import '../providers/auth_provider.dart';

class OtpScreen extends StatefulWidget {
  final AuthProvider authProvider;

  const OtpScreen({super.key, required this.authProvider});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.authProvider.addListener(_onProviderChange);
  }

  @override
  void dispose() {
    widget.authProvider.removeListener(_onProviderChange);
    _otpController.dispose();
    super.dispose();
  }

  void _onProviderChange() {
    if (mounted) setState(() {});
  }

  String? _validarOtp(String? value) {
    final otp = value?.trim() ?? '';
    if (otp.isEmpty) {
      return 'Informe o código OTP.';
    }
    if (!RegExp(r'^\d{6}$').hasMatch(otp)) {
      return 'Digite um código numérico de 6 dígitos.';
    }
    return null;
  }

  Future<void> _confirmarOtp() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final success = await widget.authProvider.validarOtp(_otpController.text);

    if (!mounted) return;

    if (success) {
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.authProvider.erro ?? 'Não foi possível validar o OTP.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final phoneNumber = widget.authProvider.otpChallenge?.phoneNumber;

    return Scaffold(
      appBar: AppBar(title: const Text('Validação OTP')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.security_outlined,
                        size: 52,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Confirme o código',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        phoneNumber == null
                            ? 'Digite o código OTP enviado.'
                            : 'Digite o código enviado para $phoneNumber.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        validator: _validarOtp,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        maxLength: 6,
                        decoration: InputDecoration(
                          labelText: 'Código OTP',
                          prefixIcon: const Icon(Icons.pin_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          filled: true,
                          counterText: '',
                        ),
                      ),
                      const SizedBox(height: 16),
                      ButtonComponent(
                        text: 'Confirmar',
                        icon: Icons.verified_user_outlined,
                        isLoading: widget.authProvider.carregando,
                        onPressed: _confirmarOtp,
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
