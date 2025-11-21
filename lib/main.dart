import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:app_links/app_links.dart';

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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final appLinks = AppLinks(); // Listener deep link

  @override
  void initState() {
    super.initState();

    // Khi bấm link xác thực email → app tự mở → quay login
    appLinks.uriLinkStream.listen((uri) {
      if (uri.toString().contains("account-verified")) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "AGRI VISION",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6DBE45)),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
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
