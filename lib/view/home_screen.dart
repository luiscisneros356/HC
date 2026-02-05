import 'package:flutter/material.dart';
import 'package:hc_catamarca/data/services/excel_service.dart';
import 'package:hc_catamarca/data/services/firebase_service.dart';
import 'package:hc_catamarca/view/patient_form_screen.dart';
import 'package:provider/provider.dart';

import 'patient_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firebaseService = context.read<FirebaseService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historia Clínica Digital'),
        backgroundColor: Colors.amber,
        elevation: 4,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.amber),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.medical_services, size: 48),
                  SizedBox(height: 10),
                  Text(
                    'Historia Clínica',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text('Sistema de Gestión'),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Inicio'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('Lista de Pacientes'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PatientListScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Nuevo Paciente'),
              onTap: () {
                // Navegar a formulario de nuevo paciente
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PatientFormScreen(),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Exportar a Excel'),
              onTap: () async {
                try {
                  // Mostrar loading
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) =>
                        Center(child: CircularProgressIndicator()),
                  );

                  // Obtener datos
                  final firebaseService = Provider.of<FirebaseService>(
                    context,
                    listen: false,
                  );
                  final patients = await firebaseService
                      .getAllPatientsForExcel();

                  // Generar y descargar Excel
                  final excelService =
                      ExcelServiceWeb(); // o ExcelServiceSyncfusion()
                  await excelService.generateAndDownloadPatientsExcel(patients);

                  // Cerrar loading
                  Navigator.pop(context);

                  // Mostrar mensaje de éxito
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Excel descargado exitosamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al descargar: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.medical_services, size: 100, color: Colors.blue[900]),
              const SizedBox(height: 20),
              Text(
                'Bienvenido al Sistema de\nHistoria Clínica Digital',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Gestione los registros médicos de manera eficiente',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.blue[800]),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PatientListScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.list),
                label: const Text('Ver Lista de Pacientes'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  // Navegar a crear nuevo paciente
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PatientFormScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Agregar Nuevo Paciente'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
