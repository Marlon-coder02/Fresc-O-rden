import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;

class AddProductScreen extends StatefulWidget {
  final String? scannedCode;
  final List<Map<String, dynamic>> existingProducts;
  final Function(Map<String, dynamic>) onSave;
  final Map<String, dynamic>? initialProduct;

  const AddProductScreen({
    super.key,
    this.scannedCode,
    required this.existingProducts,
    required this.onSave,
    this.initialProduct,
  });

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _barcodeController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController(text: '1');

  String _selectedUnit = 'unidad';
  File? _imageFile;
  DateTime? _expiryDate;
  final picker = ImagePicker();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final List<String> _units = ['unidad', 'kg', 'g', 'L', 'ml'];

  @override
  void initState() {
    super.initState();
    tzdata.initializeTimeZones();
    _initializeNotificationPlugin();

    if (widget.initialProduct != null) {
      _nameController.text = widget.initialProduct!['name'] ?? '';
      _barcodeController.text = widget.initialProduct!['barcode'] ?? '';
      _quantityController.text = widget.initialProduct!['quantity'] ?? '1';
      _selectedUnit = widget.initialProduct!['unit'] ?? 'unidad';

      if (widget.initialProduct!['image'] != null) {
        _imageFile = File(widget.initialProduct!['image']);
      }

      if (widget.initialProduct!['expirationDate'] != null) {
        _expiryDate = DateTime.tryParse(widget.initialProduct!['expirationDate']);
      }
    } else if (widget.scannedCode != null) {
      _barcodeController.text = widget.scannedCode!;
    }
  }

  Future<void> _initializeNotificationPlugin() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

Future<void> _scheduleNotification(String productName, DateTime expiryDate) async {
  final notificationTime = expiryDate.subtract(const Duration(days: 3));
  final now = DateTime.now();

  if (notificationTime.isAfter(now)) {
    final delay = notificationTime.difference(now);

    Future.delayed(delay, () async {
      await flutterLocalNotificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        'Producto por vencer',
        'El producto "$productName" vencerá pronto.',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'vencimiento_channel',
            'Notificaciones de Vencimiento',
            channelDescription: 'Avisos de productos cercanos a su fecha de vencimiento',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
      );
    });
  }
}



void _guardarProducto() async {
  final name = _nameController.text.trim();
  final quantity = _quantityController.text.trim();

  // Verificar que el usuario esté autenticado
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Debes iniciar sesión para guardar un producto')),
    );
    return;
  }

  // Validar los campos del formulario
  if (name.isEmpty || quantity.isEmpty || int.tryParse(quantity) == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Por favor, completa todos los campos correctamente')),
    );
    return;
  }

  // Crear el mapa del producto
  final producto = {
    'name': name,
    'barcode': _barcodeController.text.trim(),
    'quantity': quantity,
    'unit': _selectedUnit,
    'image': _imageFile?.path,
    'expirationDate': _expiryDate?.toIso8601String(),
    'createdAt': FieldValue.serverTimestamp(),
  };

  try {
    // Guardar el producto en la subcolección del usuario en Firestore
    final docRef = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid)
        .collection('productos')
        .add(producto);

    // Obtener el ID generado automáticamente por Firestore
    final generatedId = docRef.id;

    // Asignar el ID generado al mapa del producto
    producto['id'] = generatedId;

    // Llamar al callback onSave con el producto actualizado
    widget.onSave(producto);

    // Programar una notificación si hay una fecha de vencimiento válida
    if (_expiryDate != null) {
      await _scheduleNotification(name, _expiryDate!);
    }

    // Cerrar la pantalla
    Navigator.pop(context);
  } catch (e) {
    print('Error al guardar producto: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error al guardar el producto')),
    );
  }
}

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Widget _buildExpiryDatePicker() {
    return Row(
      children: [
        const Icon(Icons.calendar_today, color: Colors.grey),
        const SizedBox(width: 10),
        Expanded(
          child: InkWell(
            onTap: () async {
              final now = DateTime.now();
              final selectedDate = await showDatePicker(
                context: context,
                initialDate: _expiryDate ?? now,
                firstDate: now,
                lastDate: DateTime(now.year + 5),
              );
              if (selectedDate != null) {
                setState(() {
                  _expiryDate = selectedDate;
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey.shade400)),
              ),
              child: Text(
                _expiryDate == null
                    ? 'Seleccionar fecha de vencimiento'
                    : 'Vence el: ${_expiryDate!.day}/${_expiryDate!.month}/${_expiryDate!.year}',
                style: TextStyle(
                  fontSize: 16,
                  color: _expiryDate == null ? Colors.grey : Colors.black,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agregar Producto')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Nombre del producto'),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'Ej: Leche deslactosada',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Código de barras'),
            TextField(
              controller: _barcodeController,
              decoration: const InputDecoration(
                hintText: 'Ej: 7701234567890',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Cantidad'),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'Ej: 3',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: _selectedUnit,
                  items: _units
                      .map((unit) => DropdownMenuItem(value: unit, child: Text(unit)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedUnit = value;
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildExpiryDatePicker(),
            const SizedBox(height: 20),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Tomar foto'),
                ),
                const SizedBox(width: 16),
                if (_imageFile != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      _imageFile!,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _guardarProducto,
                child: const Text('Guardar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
