import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isDarkMode = false; // Estado para el tema oscuro
  bool notificationsEnabled = true; // Estado para las notificaciones

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Tema de la aplicación
          SwitchListTile(
            title: const Text('Modo oscuro'),
            subtitle: const Text('Activa o desactiva el tema oscuro'),
            value: isDarkMode,
            onChanged: (value) {
              setState(() {
                isDarkMode = value;
              });
              // Aquí puedes agregar lógica para cambiar el tema global
            },
          ),
          const Divider(),

          // Notificaciones
          SwitchListTile(
            title: const Text('Notificaciones'),
            subtitle: const Text('Recibe recordatorios y alertas'),
            value: notificationsEnabled,
            onChanged: (value) {
              setState(() {
                notificationsEnabled = value;
              });
              // Aquí puedes agregar lógica para manejar notificaciones
            },
          ),
          const Divider(),

          // Idioma
          ListTile(
            title: const Text('Idioma'),
            subtitle: const Text('Selecciona el idioma de la aplicación'),
            trailing: const Icon(Icons.language),
            onTap: () {
              // Aquí puedes mostrar un diálogo para seleccionar el idioma
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Selecciona un idioma'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          title: const Text('Español'),
                          onTap: () {
                            Navigator.pop(context);
                            // Cambiar idioma a español
                          },
                        ),
                        ListTile(
                          title: const Text('Inglés'),
                          onTap: () {
                            Navigator.pop(context);
                            // Cambiar idioma a inglés
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
          const Divider(),

          // Acerca de
          ListTile(
            title: const Text('Acerca de'),
            subtitle: const Text('Información sobre la aplicación'),
            trailing: const Icon(Icons.info),
            onTap: () {
              Navigator.pushNamed(context, '/about'); // Navegar a la pantalla "Acerca de"
            },
          ),
          const Divider(),

          // Cerrar sesión
          ListTile(
            title: const Text('Cerrar sesión'),
            subtitle: const Text('Salir de tu cuenta'),
            trailing: const Icon(Icons.logout),
            onTap: () {
              // Aquí puedes agregar lógica para cerrar sesión
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Cerrar sesión'),
                    content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // Lógica para cerrar sesión
                        },
                        child: const Text('Cerrar sesión'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}