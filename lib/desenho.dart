import 'package:flutter/material.dart';
import 'dart:ui';

class DrawingScreen extends StatefulWidget {
  const DrawingScreen({super.key});

  @override
  DrawingScreenState createState() => DrawingScreenState();
}

class DrawingScreenState extends State<DrawingScreen> {
  // Lista para armazenar os pontos do desenho
  List<Offset?> points = <Offset?>[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Desenhe com o Dedo'),
      ),
      body: GestureDetector(
        // Detecta o início do toque na tela
        onPanStart: (details) {
          setState(() {
            // Adiciona a posição inicial do toque à lista de pontos
            points.add(details.localPosition);
          });
        },
        // Detecta o movimento do dedo na tela
        onPanUpdate: (details) {
          setState(() {
            // Adiciona a nova posição do toque à lista de pontos
            points.add(details.localPosition);
          });
        },
        // Detecta quando o dedo é removido da tela
        onPanEnd: (details) {
          setState(() {
            // Adiciona um valor nulo para indicar o fim de uma linha
            points.add(null);
          });
        },
        child: CustomPaint(
          painter: DrawingPainter(points),
          child: Container(
            // Ocupa toda a altura e largura disponíveis
            height: double.infinity,
            width: double.infinity,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            // Limpa a lista de pontos para apagar o desenho
            points.clear();
          });
        },
        
        tooltip: 'Limpar Tela',
        child: const Icon(Icons.clear),
      ),
    );
  }
}

class DrawingPainter extends CustomPainter {
  final List<Offset?> points;

  DrawingPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    // Configurações do pincel
    final paint = Paint()
      ..color = Colors.blue // Cor do traço
      ..strokeCap = StrokeCap.round // Formato da ponta do traço
      ..strokeWidth = 20.0; // Espessura do traço

    // Itera sobre a lista de pontos para desenhar as linhas
    for (int i = 0; i < points.length - 1; i++) {
      // Verifica se os pontos atual e o próximo não são nulos para desenhar uma linha
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
      // Se o ponto atual não é nulo e o próximo é nulo, desenha um ponto (final de uma linha)
      else if (points[i] != null && points[i + 1] == null) {
        canvas.drawPoints(PointMode.points, [points[i]!], paint);
      }
    }
  }

  // Define se o canvas precisa ser redesenhado
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Retorna true para que o desenho seja atualizado constantemente
  }
}