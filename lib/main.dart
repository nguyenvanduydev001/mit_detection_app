import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'supabase_config.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/home_page.dart';
import 'pages/about_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "AGRI VISION",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF6DBE45)),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),

      // Nếu có session → vào Home, không → Login
      home: session == null ? const LoginPage() : HomePage(),

      routes: {
        "/login": (_) => const LoginPage(),
        "/register": (_) => const RegisterPage(),
        "/home": (_) => HomePage(),
        "/about": (_) => const AboutPage(),
      },
    );
  }
}
