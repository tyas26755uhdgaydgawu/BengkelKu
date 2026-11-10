// main.dart
// Titik awal aplikasi. Ganti ISI file lib/main.dart bawaan Flutter dengan file ini.

import 'package:flutter/material.dart';
import 'app_state.dart';
import 'shell.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final st = AppState();
  await st.init(); // memuat data yang tersimpan di browser
  runApp(BengkelKuApp(st));
}

class BengkelKuApp extends StatelessWidget {
  final AppState st;
  const BengkelKuApp(this.st, {super.key});

  @override
  Widget build(BuildContext context) {
    // Setiap ada perubahan data (st.changed), tampilan dibangun ulang
    return AnimatedBuilder(
      animation: st,
      builder: (context, _) => MaterialApp(
        title: 'BengkelKu',
        debugShowCheckedModeBanner: false,
        scaffoldMessengerKey: messengerKey,
        theme: buildTheme(st.dark),
        home: Shell(st),
      ),
    );
  }
}