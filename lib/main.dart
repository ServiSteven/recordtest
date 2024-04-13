import 'package:flutter/material.dart';
import 'package:recordtest/record.dart';
import 'package:recordtest/values/temas.dart';
import 'package:recordtest/notas.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SCAD',
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AzulClaro,
        title: const Text(
          'Inicio',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(
          color: Colors.white, // Cambiar el color del ícono de hamburguesa aquí
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: AzulClaro,
              ),
              child: Text(
                'Menú',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: const Text('Recordatorio'),
              onTap: () {
                Navigator.pop(context); // Cerrar el drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ReminderScreen()),
                );
              },
            ),
            ListTile(
              title: const Text('Notas'),
              onTap: () {
                Navigator.pop(context); // Cerrar el drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const NoteListScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: const Text('Contenido de la página principal'),
      ),
    );
  }
}
