import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp ({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
    title: 'My First App',
    home: Inicio(),
    );
  }
}


class Inicio extends StatefulWidget {
  const Inicio({super.key});

  @override
  State<Inicio> createState() => _InicioState();
}

class _InicioState extends State<Inicio> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fresc(o)rden'),
      ),
      drawer: Drawer(
        child:ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 175, 186, 245), // Color de fondo
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fresc(o)rden',
                    style: TextStyle(
                      color: const Color.fromARGB(255, 0, 0, 0), // Color del texto
                      fontSize: 24,
                      fontWeight: FontWeight.w700
                    ),
                  ),
                  const SizedBox(height: 10.0), // Espacio entre los elementos
                ],
              ) 
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: const Text('Inicio'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(context,
                MaterialPageRoute(builder:(context) => Inicio()));
              },
            ),
            ListTile(
              leading: Icon(Icons.shopping_basket),
              title: const Text('Productos'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.fastfood),
              title: const Text('Recetas'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.shopping_cart),
              title: const Text('Lista de Compras'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: const Text('Configuración'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: const Text('Contatcto'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.info),
              title: const Text('Acerca de'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        )
      ),
      body: ListView(
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.all(150.0),
              child: Opacity(
                opacity: 0.5, // Valor entre 0.0 y 1.0
                child: Image.asset("assets/verduras.png"),
              ),
            ),
          ),
          Center(
            child: Text(
              '¡Bienvenido a Fresc(o)rden!',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Textos(),
        ],
      ),
      floatingActionButton: ButtonPlus(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class Textos extends StatelessWidget {
  const Textos({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Da en la  "), // Texto
        Image.asset("assets/manzana.png",
        width: 25.0,
        height: 25.0,
        ),
        const SizedBox(width: 3.0,), // Espacio entre los elementos
        const Text(" para Agregar un Producto"), // Texto
      ],
    );
  }
}

class ButtonPlus extends StatelessWidget {
  const ButtonPlus({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        child: Row(children: [
          
        ],
        );
        print('Agregar Producto'); // Acción a realizar
      },
      backgroundColor: Colors.transparent, // Color del botón
      child: Image.asset(
        'assets/manzana.png',
        width: 75.0, // Tamaño del ícono
        height: 75.0,
      ),
    );
  }
}


/*class _InicioState extends State<Inicio> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fresc(o)rden'),
      ),
      body: Container(
        padding: EdgeInsets.all(150.0),
        child: Image.asset("assets/verduras.png"),
      ) 
    );
  }
}
*/

/*          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: () {
                print('Agregar Producto'); // Acción a realizar
              },
              icon: const Icon(Icons.add), // Icono
              label: const Text(''), // Texto
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black54, // Color de fondo
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 18), // Color del texto
              ),
            ),
          ),
)
*/