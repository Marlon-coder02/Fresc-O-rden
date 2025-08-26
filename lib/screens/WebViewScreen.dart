import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatelessWidget {
  final String url;
  final String title;

  const WebViewScreen({super.key, required this.url, required this.title});

  @override
  Widget build(BuildContext context) {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(url));

    return Scaffold(
      appBar: AppBar(
        title: Text('Navegando en $title'),
        backgroundColor: Colors.green,
        actions: [
          // Botón para el menú de opciones
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'reload':
                  controller.reload(); // Recargar la página
                  break;
                case 'goHome':
                  controller.loadRequest(Uri.parse('https://www.google.com')); // Redirige a Google (por ejemplo)
                  break;
                case 'close':
                  Navigator.pop(context); // Cerrar la pantalla
                  break;
                default:
                  break;
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'reload',
                  child: Row(
                    children: const [
                      Icon(Icons.refresh),
                      SizedBox(width: 8),
                      Text('Recargar'),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'goHome',
                  child: Row(
                    children: const [
                      Icon(Icons.home),
                      SizedBox(width: 8),
                      Text('Ir al inicio'),
                    ],
                  ),
                ),
              ];
            },
          ),
          // Botón de cerrar
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: WebViewWidget(controller: controller),
    );
  }
}

