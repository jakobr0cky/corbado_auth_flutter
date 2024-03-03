import 'package:corbado_auth/corbado_auth.dart';
import 'package:corbado_auth_example/auth_provider.dart';
import 'package:corbado_auth_example/pages/loading_page.dart';
import 'package:corbado_auth_example/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // This is a nice pattern if you need to initialize some of your services
  // before the app starts.
  // As we are using riverpod this initialization happens inside providers.
  // First we show a loading page.
  runApp(const LoadingPage());

  // Now we do the initialization.
  final projectId = 'pro-1746396311186430674';
  final customDomain = const String.fromEnvironment('CORBADO_CUSTOM_DOMAIN');
  final corbadoAuth = CorbadoAuth();
  await corbadoAuth.init(projectId);

  // Finally we override the providers that needed initialization.
  // Now the real app can be loaded.
  runApp(ProviderScope(
    overrides: [
      corbadoProvider.overrideWithValue(corbadoAuth),
    ],
    child: MyApp(),
  ));

}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      routeInformationParser: router.routeInformationParser,
      routerDelegate: router.routerDelegate,
      routeInformationProvider: router.routeInformationProvider,
      theme: ThemeData(
        useMaterial3: false,
        colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: Color(0xFF1953ff),
          onPrimary: Colors.white,
          secondary: Colors.white,
          onSecondary: Color(0xFF1953ff),
          error: Colors.redAccent,
          onError: Colors.white,
          background: Color(0xFF1953ff),
          onBackground: Colors.white,
          surface: Color(0xFF1953ff),
          onSurface: Color(0xFF1953ff),
        ),
      ),
    );
  }
}