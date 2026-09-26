import 'package:flutter/material.dart';
import 'screens/dashboard_screen.dart';
import 'services/guest_repository.dart';
import 'theme/wedding_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final repository = GuestRepository();

  runApp(ZalavadiyaWeddingApp(repository: repository));
}

class ZalavadiyaWeddingApp extends StatelessWidget {
  final GuestRepository repository;

  const ZalavadiyaWeddingApp({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'દર્શન weds બ્રિજળ - ઝાલાવડીયા પરિવાર',
      debugShowCheckedModeBanner: false,

      theme: WeddingTheme.theme,
      home: DashboardScreen(repository: repository),
    );
  }
}
