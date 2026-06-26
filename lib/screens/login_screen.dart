import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dev_venture/components/button_component.dart';
import 'package:dev_venture/components/custom_dialog.dart';
import 'package:dev_venture/providers/auth_provider.dart';
import 'package:dev_venture/screens/home_screen.dart';
import 'package:dev_venture/screens/cadastro_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _senhaVisivel = false;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (_emailController.text.trim().isEmpty ||
        _senhaController.text.trim().isEmpty) {
      CustomDialog.show(
        context: context,
        title: 'Campos obrigatórios',
        message: 'Preencha o e-mail e a senha para continuar.',
        type: DialogType.warning,
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final sucesso = await authProvider.login(
      _emailController.text,
      _senhaController.text,
    );

    if (!mounted) return;

    if (sucesso) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              HomeScreen(onThemeChanged: () {}, themeMode: ThemeMode.system),
        ),
      );
    } else {
      CustomDialog.show(
        context: context,
        title: 'Não foi possível entrar',
        message: authProvider.erro ?? 'Verifique seus dados e tente novamente.',
        type: DialogType.warning,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final carregando = context.watch<AuthProvider>().carregando;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      // Sobe o layout quando o teclado aparece
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: constraints.maxWidth > 600 ? 80 : 24,
                vertical: 24,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image(
                        image: const AssetImage('assets/base_icon.png'),
                        height: constraints.maxWidth > 400 ? 80 : 60,
                        width: constraints.maxWidth > 400 ? 80 : 60,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        "Dev Venture",
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontSize: constraints.maxWidth > 400 ? 36 : 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 24,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.login_rounded,
                              size: 56,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Entrar',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Acesse sua conta do Dev Venture',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 28),
                            TextField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                labelText: 'E-mail',
                                prefixIcon: const Icon(Icons.email_outlined),
                                filled: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _senhaController,
                              obscureText: !_senhaVisivel,
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => _entrar(),
                              decoration: InputDecoration(
                                labelText: 'Senha',
                                prefixIcon: const Icon(Icons.lock_outlined),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _senhaVisivel
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                  ),
                                  onPressed: () => setState(
                                    () => _senhaVisivel = !_senhaVisivel,
                                  ),
                                ),
                                filled: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: carregando
                                  ? const Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  : ButtonComponent(
                                      text: 'Entrar',
                                      icon: Icons.arrow_forward,
                                      onPressed: _entrar,
                                    ),
                            ),
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: () => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const CadastroScreen(),
                                ),
                              ),
                              child: Text(
                                'Ainda não tenho conta',
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
