import 'package:flutter/material.dart';
import 'package:hc_catamarca/data/model/paciente.dart';
import 'package:hc_catamarca/data/services/pdf_service.dart';

import 'seguimientos_screen.dart'; // Nueva importación

class PatientDetailScreen extends StatelessWidget {
  final Patient patient;
  final PdfService pdfService = PdfService();

  PatientDetailScreen({Key? key, required this.patient}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalle del Paciente'),
        backgroundColor: Colors.amber,
        actions: [
          IconButton(
            icon: Icon(Icons.note_add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SeguimientosScreen(patient: patient),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            onPressed: () async {
              await pdfService.generateAndDownloadPatientPDF(patient);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ... (resto del código permanece igual hasta la sección de seguimientos)
            const SizedBox(height: 20),
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Registro de Seguimientos',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[900],
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    SeguimientosScreen(patient: patient),
                              ),
                            );
                          },
                          icon: Icon(Icons.add),
                          label: Text('Agregar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    if (patient.seguimientos.isEmpty)
                      Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.note_add,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No hay seguimientos registrados',
                              style: TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        SeguimientosScreen(patient: patient),
                                  ),
                                );
                              },
                              child: Text('Agregar primer seguimiento'),
                            ),
                          ],
                        ),
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total de seguimientos: ${patient.seguimientos.length}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[800],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Mostrar últimos 3 seguimientos
                          for (
                            var i = patient.seguimientos.length - 1;
                            i >= 0 && i >= patient.seguimientos.length - 3;
                            i--
                          )
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: Card(
                                color: Colors.grey[50],
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.blue[100],
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              'Seguimiento ${i + 1}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blue[900],
                                              ),
                                            ),
                                          ),
                                          if (i ==
                                              patient.seguimientos.length - 1)
                                            Container(
                                              margin: const EdgeInsets.only(
                                                left: 8,
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.green[100],
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                'MÁS RECIENTE',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.green[900],
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(patient.seguimientos[i]),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                          if (patient.seguimientos.length > 3)
                            Center(
                              child: TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          SeguimientosScreen(patient: patient),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Ver todos los ${patient.seguimientos.length} seguimientos',
                                  style: TextStyle(color: Colors.blue[700]),
                                ),
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            ),

            // ... (resto del código permanece igual)
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
