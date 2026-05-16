import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    await Supabase.initialize(
      url: 'https://ozzlviyzmtmzkxbbbuzu.supabase.co',
      anonKey: 'sb_publishable_EQB-8JP6RUej_KUEUHAwZg__Nmmkm0e',
    );

    runApp(const PlantCareApp());
  } catch (e) {
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: SelectableText('Configuration Error: $e\n\nPlease check your Supabase credentials.'),
        ),
      ),
    ));
  }
}

class PlantCareApp extends StatelessWidget {
  const PlantCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plant Care Diary',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B5E20),
          primary: const Color(0xFF2E7D32),
          secondary: const Color(0xFF00C853),
          surface: Colors.white,
        ),
        textTheme: GoogleFonts.philosopherTextTheme(Theme.of(context).textTheme),
        appBarTheme: AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.transparent,
          foregroundColor: const Color(0xFF1B5E20),
          titleTextStyle: GoogleFonts.philosopher(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1B5E20),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 8,
            shadowColor: const Color(0x6600C853),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
