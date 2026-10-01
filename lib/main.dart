import 'package:app_de_registro/screens/home_srceen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';


void main() async {
  // Garante o correto funcionamento das ligações nativas do Flutter antes de iniciar a interface
  WidgetsFlutterBinding.ensureInitialized();

  // Tenta inicializar o Firebase em segurança
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Aviso: Firebase não configurado. A aplicação irá funcionar em modo de simulação: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ponto Eletrónico',
      debugShowCheckedModeBanner: false, // Remove a faixa amarela de Debug no topo
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}