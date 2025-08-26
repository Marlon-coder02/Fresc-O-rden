import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/services.dart';
import 'package:android_intent_plus/android_intent.dart';

class AddProductScreen extends StatefulWidget {
  final String? scannedCode;
  final List<Map<String, dynamic>> existingProducts;
  final Function(Map<String, dynamic>) onSave;
  final Map<String, dynamic>? initialProduct;
  final bool isManualAdd; // Nueva propiedad para indicar si es un agregado manual

  const AddProductScreen({
    super.key,
    this.scannedCode,
    required this.existingProducts,
    required this.onSave,
    this.initialProduct,
    this.isManualAdd = false, // Valor predeterminado: no es manual
  });

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  bool _isSaving = false;
  final TextEditingController _barcodeController = TextEditingController();
  bool _isManualAdd = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController(text: '1');

  String _selectedUnit = 'unidad';
  File? _imageFile;
  DateTime? _expiryDate;
  final picker = ImagePicker();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final List<String> _units = ['unidad', 'kg', 'g', 'L', 'ml', 'lbs', 'oz'];

  @override
  void initState() {
    super.initState();

    // Inicializar las zonas horarias para las notificaciones
    tzdata.initializeTimeZones();

    _initializeNotificationPlugin();

    // Verificar el permiso de alarmas exactas
    _checkExactAlarmPermission();

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
    } else {
      _isManualAdd = widget.isManualAdd;
    }
  }

  Future<void> _initializeNotificationPlugin() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

Future<void> _checkExactAlarmPermission() async {
  if (Platform.isAndroid && (await _isAndroid12OrHigher())) {
    try {
      // Redirigir al usuario a la configuración de la aplicación
      final intent = AndroidIntent(
        action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
      );
      await intent.launch();
    } catch (e) {
      print('Error al redirigir a la configuración de alarmas exactas: $e');
    }
  }
}

Future<bool> _isAndroid12OrHigher() async {
  final version = int.tryParse(Platform.version.split(' ')[0]) ?? 0;
  return version >= 31; // Android 12 es API 31
}

Future<void> _scheduleNotification(String productName, DateTime expiryDate) async {
  final notificationTime = expiryDate.subtract(const Duration(days: 3));
  final now = DateTime.now();

  if (notificationTime.isAfter(now)) {
    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        'Producto por vencer',
        'El producto "$productName" vencerá pronto.',
        tz.TZDateTime.from(notificationTime, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'vencimiento_channel',
            'Notificaciones de Vencimiento',
            channelDescription: 'Avisos de productos cercanos a su fecha de vencimiento',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      print('Error al programar la notificación: $e');
    }
  }
}

void _guardarProducto() async {
  if (_isSaving) return;
  setState(() {
    _isSaving = true;
  });

  final name = _nameController.text.trim();
  final quantity = _quantityController.text.trim();
  final barcode = _barcodeController.text.trim();

  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Debes iniciar sesión para guardar un producto')),
    );
    setState(() {
      _isSaving = false;
    });
    return;
  }

  if (name.isEmpty || quantity.isEmpty || int.tryParse(quantity) == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Por favor, completa todos los campos correctamente')),
    );
    setState(() {
      _isSaving = false;
    });
    return;
  }

  if (_expiryDate == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Por favor, selecciona una fecha de vencimiento')),
    );
    setState(() {
      _isSaving = false;
    });
    return;
  }

  try {
    final productosRef = FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid)
        .collection('productos');

    QuerySnapshot querySnapshot;
    if (barcode.isNotEmpty) {
      querySnapshot = await productosRef.where('barcode', isEqualTo: barcode).get();
    } else {
      querySnapshot = await productosRef.where('name', isEqualTo: name).get();
    }

    if (querySnapshot.docs.isNotEmpty) {
      final existingDoc = querySnapshot.docs.first;

      await productosRef.doc(existingDoc.id).update({
        'name': name,
        'barcode': barcode.isNotEmpty ? barcode : null,
        'quantity': quantity,
        'unit': _selectedUnit,
        'image': _imageFile?.path,
        'expirationDate': _expiryDate?.toIso8601String(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto actualizado correctamente')),
      );
    } else {
      final producto = {
        'name': name,
        'barcode': barcode.isNotEmpty ? barcode : null,
        'quantity': quantity,
        'unit': _selectedUnit,
        'image': _imageFile?.path,
        'expirationDate': _expiryDate?.toIso8601String(),
        'createdAt': FieldValue.serverTimestamp(),
      };

      final docRef = await productosRef.add(producto);

      producto['id'] = docRef.id;
      widget.onSave(producto);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto guardado correctamente')),
      );
    }

    // Programar notificación para el producto
    await _scheduleNotification(name, _expiryDate!);

    // Cerrar la ventana solo si todo fue exitoso
    Navigator.pop(context);
  } catch (e) {
    print('Error al guardar producto: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error al guardar el producto: $e')),
    );
  } finally {
    setState(() {
      _isSaving = false;
    });
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
    appBar: AppBar(
      title: const Text('Agregar Producto'),
      backgroundColor: Colors.green,
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nombre del producto
          const Text(
            'Nombre del producto',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: 'Ej: Leche deslactosada',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              filled: true,
              fillColor: Colors.grey.shade100,
            ),
          ),
          const SizedBox(height: 16),

          // Código de barras (si no es manual)
          if (!_isManualAdd)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Código de barras',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _barcodeController,
                  decoration: InputDecoration(
                    hintText: 'Ej: 7701234567890',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),

          // Cantidad
          const Text(
            'Cantidad',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Ej: 3',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              DropdownButton<String>(
                value: _selectedUnit,
                items: _units
                    .map((unit) => DropdownMenuItem(
                          value: unit,
                          child: Text(unit),
                        ))
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

          // Fecha de vencimiento
          const Text(
            'Fecha de vencimiento',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _buildExpiryDatePicker(),
          const SizedBox(height: 20),

          // Foto del producto
          const Text(
            'Foto del producto (opcional)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Tomar Foto'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
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

          // Botón Guardar
          Center(
            child: ElevatedButton(
              onPressed: _isSaving ? null : _guardarProducto,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _isSaving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Guardar',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    ),
  );
}
}