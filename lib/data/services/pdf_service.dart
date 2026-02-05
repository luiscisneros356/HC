import 'package:hc_catamarca/data/model/paciente.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfService {
  Future<void> generateAndDownloadPatientPDF(Patient patient) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Encabezado
              pw.Header(
                level: 0,
                child: pw.Text(
                  'Historia Clínica',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'Paciente: ${patient.nombre}',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text('DNI: ${patient.dni} | Edad: ${patient.edad} años'),
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 20),

              // Información del paciente
              pw.Text(
                'DATOS PERSONALES',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),

              _buildInfoRow('Nombre:', patient.nombre),
              _buildInfoRow('Edad:', '${patient.edad} años'),
              _buildInfoRow('DNI:', patient.dni),
              _buildInfoRow('Dirección:', patient.direccion),
              _buildInfoRow('Contacto:', patient.contacto),

              pw.SizedBox(height: 20),

              // Intervenciones
              pw.Text(
                'HISTORIAL DE INTERVENCIONES/RECOMENDACIONES',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),

              if (patient.intervenciones.isEmpty)
                pw.Text('No hay intervenciones registradas')
              else
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < patient.intervenciones.length; i++)
                      pw.Padding(
                        padding: const pw.EdgeInsets.only(bottom: 10),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'Intervención ${i + 1}:',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.Text(patient.intervenciones[i]),
                            if (i < patient.intervenciones.length - 1)
                              pw.Divider(height: 5),
                          ],
                        ),
                      ),
                  ],
                ),

              pw.SizedBox(height: 20),

              // Seguimientos
              pw.Text(
                'REGISTRO DE SEGUIMIENTOS',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),

              if (patient.seguimientos.isEmpty)
                pw.Text('No hay seguimientos registrados')
              else
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < patient.seguimientos.length; i++)
                      pw.Padding(
                        padding: const pw.EdgeInsets.only(bottom: 10),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'Seguimiento ${i + 1}:',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.Text(patient.seguimientos[i]),
                            if (i < patient.seguimientos.length - 1)
                              pw.Divider(height: 5),
                          ],
                        ),
                      ),
                  ],
                ),

              pw.SizedBox(height: 30),

              // Pie de página
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Total intervenciones: ${patient.intervenciones.length}',
                      ),
                      pw.Text(
                        'Total seguimientos: ${patient.seguimientos.length}',
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'Fecha de creación: ${_formatDate(patient.fechaCreacion)}',
                      ),
                      pw.Text(
                        'Última actualización: ${_formatDate(patient.fechaUltimaActualizacion)}',
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Text(
                  'Documento generado el: ${_formatDate(DateTime.now())}',
                  style: const pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    // Descargar PDF
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  pw.Row _buildInfoRow(String label, String value) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(width: 100, child: pw.Text(label)),
        pw.Text(value),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
