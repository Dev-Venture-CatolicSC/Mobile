import 'package:flutter/material.dart';
import 'package:dev_venture/components/button_component.dart';

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  int clickCount = 0;
  bool isDevModeActive = false;

  void handleDevModeClick() {
    if (isDevModeActive) {
      Navigator.pushNamed(context, '/theme-demo');
      return;
    }

    setState(() {
      clickCount++;
      if (clickCount >= 6 && clickCount < 10) {
        final remaining = 10 - clickCount;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Você está a $remaining passos de se tornar um desenvolvedor.',
            ),
            duration: const Duration(milliseconds: 500),
          ),
        );
      }

      if (clickCount >= 10) {
        isDevModeActive = true;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Modo desenvolvedor ativado! 🎉'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,

      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            GestureDetector(
              onTap: handleDevModeClick,
              behavior: HitTestBehavior.opaque,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Image(
                    image: AssetImage('assets/base_icon.png'),
                    height: 120,
                    width: 120,
                  ),
                  Text(
                    "Dev Venture",
                    style: theme.textTheme.titleLarge?.copyWith(fontSize: 45),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Container(
                width: 420,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isDevModeActive
                          ? Icons.developer_mode
                          : Icons.person_add_alt_1,
                      size: 64,
                      color: theme.colorScheme.primary,
                    ),

                    const SizedBox(height: 16),

                    Text(
                      'Criar conta',

                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Preencha seus dados para acessar o Dev Venture',

                      textAlign: TextAlign.center,

                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: 28),

                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Nome completo',
                        prefixIcon: const Icon(Icons.person),

                        filled: true,

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextField(
                      decoration: InputDecoration(
                        labelText: 'E-mail',
                        prefixIcon: const Icon(Icons.email),

                        filled: true,

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextField(
                      obscureText: true,

                      decoration: InputDecoration(
                        labelText: 'Senha',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: const Icon(Icons.visibility),

                        filled: true,

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextField(
                      obscureText: true,

                      decoration: InputDecoration(
                        labelText: 'Confirmar senha',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: const Icon(Icons.visibility),

                        filled: true,

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    ButtonComponent(
                      text: 'Cadastrar',
                      icon: Icons.arrow_forward,
                      onPressed: () {
                        Navigator.pushNamed(context, '/home');
                      },
                    ),
                    const SizedBox(height: 12),

                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },

                      child: Text(
                        'Já tenho conta',

                        style: TextStyle(color: theme.colorScheme.primary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
