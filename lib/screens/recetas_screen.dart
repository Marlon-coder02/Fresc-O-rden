// lib/screens/recetas_screen.dart
import 'package:flutter/material.dart';

class RecetasScreen extends StatefulWidget {
  final List<Map<String, dynamic>> productosInventario;

  const RecetasScreen({super.key, required this.productosInventario});

  @override
  State<RecetasScreen> createState() => _RecetasScreenState();
}

class _RecetasScreenState extends State<RecetasScreen> {
  bool mostrarSoloDisponibles = false;

  // Lista de recetas colombianas
  final List<Map<String, dynamic>> recetas = [
    {
      'nombre': 'Arepa con queso',
      'ingredientes': ['arepa', 'queso', 'mantequilla'],
      'imagen': 'assets/arepa.png',
    },
    {
      'nombre': 'Huevos pericos',
      'ingredientes': ['huevos', 'tomate', 'cebolla', 'aceite', 'sal'],
      'imagen': 'assets/huevos_pericos.png',
    },
    {
      'nombre': 'Caldo de papa',
      'ingredientes': ['papas', 'cebolla', 'ajo', 'agua', 'sal'],
      'imagen': 'assets/caldo_papa.png',
    },
    {
      'nombre': 'Arroz con huevo',
      'ingredientes': ['arroz', 'huevo', 'aceite', 'sal'],
      'imagen': 'assets/arroz_huevo.png',
    },
    {
      'nombre': 'Changua',
      'ingredientes': ['leche', 'agua', 'huevo', 'cebolla', 'pan', 'sal'],
      'imagen': 'assets/changua.png',
    },
  ];

  // Comprueba si en el inventario se tienen todos los ingredientes necesarios para una receta.
  bool tieneTodosLosIngredientes(List<String> necesarios) {
    final nombresInventario = widget.productosInventario
        .map((producto) => producto['name'].toString().toLowerCase())
        .toList();

    return necesarios.every((ingrediente) =>
        nombresInventario.contains(ingrediente.toLowerCase()));
  }

  @override
  Widget build(BuildContext context) {
    final recetasFiltradas = mostrarSoloDisponibles
        ? recetas.where((receta) => tieneTodosLosIngredientes(receta['ingredientes'])).toList()
        : recetas;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recetas Sugeridas'),
        actions: [
          IconButton(
            icon: Icon(
              mostrarSoloDisponibles ? Icons.filter_alt : Icons.filter_alt_off,
            ),
            tooltip: mostrarSoloDisponibles
                ? "Mostrar recetas con productos que no tienes"
                : "Mostrar todas las recetas",
            onPressed: () {
              setState(() {
                mostrarSoloDisponibles = !mostrarSoloDisponibles;
              });
            },
          )
        ],
      ),
      body: recetasFiltradas.isEmpty
          ? const Center(child: Text('No hay recetas disponibles con tus productos 😥'))
          : ListView.builder(
              itemCount: recetasFiltradas.length,
              itemBuilder: (context, index) {
                final receta = recetasFiltradas[index];
                final disponible = tieneTodosLosIngredientes(receta['ingredientes']);

                return Card(
                  color: disponible ? Colors.white : Colors.grey[200],
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  child: ListTile(
                    leading: Image.asset(
                      receta['imagen'],
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    title: Text(receta['nombre']),
                    subtitle: Text("Ingredientes: ${receta['ingredientes'].join(', ')}\n${disponible ? 'Puedes preparar esta receta' : 'Faltan ingredientes'}"),
                    trailing: Icon(
                      disponible ? Icons.check_circle : Icons.warning,
                      color: disponible ? Colors.green : Colors.orange,
                    ),
                  ),
                );
              },
            ),
    );
  }
}

