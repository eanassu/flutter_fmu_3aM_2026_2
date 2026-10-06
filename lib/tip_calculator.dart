import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TipCalculator extends StatefulWidget {
  const TipCalculator({super.key});

  @override
  State<TipCalculator> createState() => _TipCalculatorState();
}
class _TipCalculatorState extends State<TipCalculator> {
  double _currentSliderValue = 15;
  double _valor = 0.0;
  double _gorjeta = 0.0;
  double _valorTotal = 0.0;

  final TextEditingController _controller1 = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculadora de Gorjeta'),
        
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Esta é a calculadora de gorjeta!',
              style: TextStyle(fontSize: 20),
          ),
          TextField(
              keyboardType: TextInputType.number,
              controller: _controller1,
              onChanged: (value) {
                setState(() {
                  _valor = double.tryParse(value) ?? 0.0;
                  _valor /= 100.0;
                  _gorjeta = (_valor * _currentSliderValue / 100);
                  _valorTotal = _valor + _gorjeta;
                });
              }, 
              decoration: InputDecoration(
                labelText: 'Digite o valor',
                hintText: 'valor',
                border: OutlineInputBorder(),
              ),
            ),
          Text(
            'Valor: ${NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(_valor)}',
            style: TextStyle(fontSize: 20),
          ),
          Text(
            'Gorjeta: ${NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(_gorjeta)}',
            style: TextStyle(fontSize: 20),
          ),
          Text(
            'Total: ${NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(_valorTotal)}',
            style: TextStyle(fontSize: 20),
          ),
          Slider(
              value: _currentSliderValue,
              max: 30,
              onChanged: (double value) {
                setState(() {
                  _currentSliderValue = value.round().toDouble();
                  _gorjeta = (_valor * _currentSliderValue / 100);
                  _valorTotal = _valor + _gorjeta;
                });
              },
            ),
          Text(
            'Porcentagem: ${_currentSliderValue.toStringAsFixed(0)}%',
            style: TextStyle(fontSize: 20),
          ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // Volta para a tela anterior
                Navigator.pop(context);
              },
              child: const Text('Voltar para a Tela Principal'),
            ),
          ],
        ),
      ),
    );
  }
}