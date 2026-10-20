import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:projeto/desenho.dart';
import 'package:projeto/home_screen.dart';
import 'package:projeto/tip_calculator.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
    // Inicialização específica para diferentes plataformas
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
    // O Sqflite por padrão vai usar o FFI para web se disponível
  } else if (defaultTargetPlatform == TargetPlatform.windows ||
             defaultTargetPlatform == TargetPlatform.linux ||
             defaultTargetPlatform == TargetPlatform.macOS) {
    // Para desktop, usamos sqflite_common_ffi
    sqfliteFfiInit(); // Inicializa o FFI para desktop
    databaseFactory = databaseFactoryFfi; // Define a factory para desktop
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Projeto Flutter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.yellow),
      ),
      home: const MyHomePage(title: 'Projeto Flutter Piloto'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _controller1 = TextEditingController();
  final TextEditingController _controller2 = TextEditingController();
  int _soma = 0;

  void _calcularSoma() {
    setState(() {
      _soma = int.parse(_controller1.text) + int.parse(_controller2.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: .center,
          children: [
            SizedBox(height: 15,),
            TextField(
              controller:_controller1,
              decoration: InputDecoration(
                labelText: 'Digite um número',
                hintText: 'um número',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 40,),
            TextField(
              controller:_controller2,
              decoration: InputDecoration(
                labelText: 'Digite um número',
                hintText: 'um número',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 40,),
            const Text('A soma é:'),
            Text(
              '$_soma',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            ElevatedButton(
              onPressed: (){
                Navigator.push(context, 
                MaterialPageRoute(
                  builder: (context) => const TipCalculator()),
                );
              }, child: const Text('Calculadora de gorjeta')
            ),
            ElevatedButton(
              onPressed: () {
                // Navega para a Tela de Tarefas
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DatabaseHomeScreen()),
                );
              },
              child: const Text('Ir para Tarefas'),
            ),
                        ElevatedButton(
              onPressed: () {
                // Navega para a Tela de Tarefas
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DrawingScreen()),
                );
              },
              child: const Text('Ir para Desenho'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _calcularSoma,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
