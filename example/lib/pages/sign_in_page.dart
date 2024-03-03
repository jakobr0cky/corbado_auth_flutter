import 'package:corbado_auth/corbado_auth.dart';
import 'package:corbado_auth_example/auth_provider.dart';
import 'package:corbado_auth_example/pages/base_page.dart';
import 'package:corbado_auth_example/router.dart';
import 'package:corbado_auth_example/widgets/filled_text_button.dart';
import 'package:corbado_auth_example/widgets/outlined_text_button.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SignInPage extends StatefulHookConsumerWidget {
  SignInPage({super.key});

  @override
  ConsumerState<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPage> {
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authService = ref.watch(authServiceProvider);

      // As soon as the view has been loaded prepare the autocompleted passkey sign in.
      authService.signInWithAutocomplete().onError((error, stackTrace) {
        if (error is PasskeyAuthCancelledException) {
          debugPrint('FYI: User has cancelled passkey auth.');
          return;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final error = useState<String?>(null);
    final loading = useState<bool>(false);
    final authService = ref.watch(authServiceProvider);

    return BasePage(
        child: SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: const Text(
              'Tired of passwords?',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: const Text(
              'Sign in using your biometrics like fingerprint or face.',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: TextField(
              autofillHints: [_getAutofillHint()],
              controller: _emailController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'email address',
              ),
            ),
          ),
          error.value != null
              ? Text(
                  error.value!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                )
              : Container(),
          SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledTextButton(
              onTap: () async {
                try {
                  loading.value = true;
                  final email = _emailController.value.text;
                  final maybeError = await authService.signIn(email: email);
                  if (maybeError != null) {
                    loading.value = false;
                    error.value = maybeError;
                  }
                } catch (error) {
                  loading.value = false;
                  debugPrint('error: $error');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Theme.of(context).primaryColor,
                      content: Text('$error'),
                      duration: const Duration(seconds: 10),
                    ),
                  );
                }
              },
              isLoading: loading.value,
              content: 'sign in',
            ),
          ),
          SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedTextButton(
              onTap: () => context.go(Routes.signUp),
              content: 'I want to create a new account',
            ),
          ),
        ],
      ),
    ));
  }

  String _getAutofillHint() {
    if (kIsWeb) {
      return 'webauthn';
    } else {
      return AutofillHints.username;
    }
  }
}
