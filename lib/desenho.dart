import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart' show Share, XFile;

// Descomente caso adicione os pacotes de compartilhar ou salvar na galeria:
// import 'package:share_plus/share_plus.dart';
import 'package:gal/gal.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DrawingScreen(),
    ),
  );
}

class DrawingScreen extends StatefulWidget {
  const DrawingScreen({super.key});

  @override
  DrawingScreenState createState() => DrawingScreenState();
}

class DrawingScreenState extends State<DrawingScreen> {
  // Lista para armazenar os pontos do desenho
  List<Offset?> points = <Offset?>[];

  // [PASSO 1] Chave global para identificar a área que será convertida em imagem
  final GlobalKey _canvasKey = GlobalKey();

  // [PASSO 2] Função que converte o RepaintBoundary em bytes PNG (Uint8List)
  Future<void> _gerarECompartilharImagem() async {
    if (points.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Desenhe algo antes de gerar a imagem!')),
      );
      return;
    }

    try {
      // Recupera o objeto de renderização do RepaintBoundary
      final boundary = _canvasKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;

      if (boundary == null) return;

      // Converte o widget renderizado em uma imagem (pixelRatio: 3.0 garante alta qualidade)
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);

      // Converte a imagem para bytes no formato PNG
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData == null) return;
      final Uint8List pngBytes = byteData.buffer.asUint8List();

      // ======================================================================
      // OPÇÃO A: Visualizar a imagem PNG gerada na tela (Sem pacotes externos)
      // ======================================================================
      // if (!mounted) return;
      // showDialog(
      //   context: context,
      //   builder: (context) => AlertDialog(
      //     title: const Text('Imagem PNG Gerada'),
      //     content: Column(
      //       mainAxisSize: MainAxisSize.min,
      //       children: [
      //         Text(
      //           'Tamanho do arquivo: ${(pngBytes.lengthInBytes / 1024).toStringAsFixed(1)} KB',
      //         ),
      //         const SizedBox(height: 12),
      //         DecoratedBox(
      //           decoration: BoxDecoration(
      //             border: Border.all(color: Colors.grey),
      //           ),
      //           // Exibe na tela os bytes PNG gerados a partir do desenho
      //           child: Image.memory(pngBytes, height: 250),
      //         ),
      //       ],
      //     ),
      //     actions: [
      //       TextButton(
      //         onPressed: () => Navigator.pop(context),
      //         child: const Text('Fechar'),
      //       ),
      //     ],
      //   ),
      // );

      // ======================================================================
      // OPÇÃO B: Compartilhar no WhatsApp, Drive, E-mail (Pacote: share_plus)
      // ======================================================================
      await Share.shareXFiles(
        [XFile.fromData(pngBytes, mimeType: 'image/png', name: 'desenho.png')],
        text: 'Meu desenho feito no Flutter!',
      );

      // ======================================================================
      // OPÇÃO C: Gravar direto na Galeria do celular (Pacote: gal)
      // ======================================================================
      //await Gal.putImageBytes(pngBytes, name: 'desenho_flutter');
    } catch (e) {
      debugPrint('Erro ao gerar imagem: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Desenhe com o Dedo'),
        actions: [
          // Botão na AppBar para exportar a imagem
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Gerar / Compartilhar Imagem',
            onPressed: _gerarECompartilharImagem,
          ),
        ],
      ),
      body: GestureDetector(
        // Detecta o início do toque na tela
        onPanStart: (details) {
          setState(() {
            points.add(details.localPosition);
          });
        },
        // Detecta o movimento do dedo na tela
        onPanUpdate: (details) {
          setState(() {
            points.add(details.localPosition);
          });
        },
        // Detecta quando o dedo é removido da tela
        onPanEnd: (details) {
          setState(() {
            points.add(null);
          });
        },
        // [PASSO 3] Envolvemos o CustomPaint com RepaintBoundary e fundo branco
        child: RepaintBoundary(
          key: _canvasKey,
          child: Container(
            // IMPORTANTE: Define cor branca! Sem isso, o fundo do PNG fica
            // transparente (aparecendo preto em muitos visualizadores de fotos).
            color: Colors.white,
            height: double.infinity,
            width: double.infinity,
            child: CustomPaint(
              painter: DrawingPainter(points),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
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
    final paint = Paint()
      ..color = Colors.blue
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 20.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      } else if (points[i] != null && points[i + 1] == null) {
        canvas.drawPoints(ui.PointMode.points, [points[i]!], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}