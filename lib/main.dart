import 'package:flutter/material.dart';
import 'calculadora_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculadora de Intereses',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1D3557)),
        useMaterial3: true,
      ),
      home: Scaffold(
        body: CalculadoraPage(),
        persistentFooterButtons: [
          SizedBox(
            height: 50,
            child: Container(
              color: Colors.grey[300],
              child: Center(
                child: Text(
                  'Created By INVERSIONES EL TREBOL',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
