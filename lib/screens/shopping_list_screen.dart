import 'package:flutter/material.dart';

class ShoppingListScreen extends StatelessWidget {
  const ShoppingListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Compras'),
      ),
      body: const Center(
        child: Text(
          'Aquí puedes gestionar tu lista de compras.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}