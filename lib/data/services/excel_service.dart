import 'dart:html' as html;

import 'package:csv/csv.dart';
import 'package:hc_catamarca/data/model/paciente.dart';

class ExcelServiceWeb {
  Future<void> generateAndDownloadPatientsExcel(List<Patient> patients) async {
    // Crear encabezados
    List<List<dynamic>> csvData = [];
    csvData.add([
      'Nombre',
      'Edad',
      'DNI',
      'Dirección',
      'Contacto',
      'Intervenciones',
      'Seguimientos',
      'Fecha Creación',
      'Última Actualización',
    ]);

    // Agregar datos de pacientes
    for (var patient in patients) {
      csvData.add([
        patient.nombre,
        patient.edad,
        patient.dni,
        patient.direccion,
        patient.contacto,
        patient.intervenciones.join('; '),
        patient.seguimientos.join('; '),
        _formatDate(patient.fechaCreacion),
        _formatDate(patient.fechaUltimaActualizacion),
      ]);
    }

    // Convertir a CSV
    String csv = const ListToCsvConverter().convert(csvData);

    // Crear blob y descargar
    final blob = html.Blob([csv], 'text/csv;charset=utf-8;');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', 'pacientes_${_getTimestamp()}.csv')
      ..click();

    html.Url.revokeObjectUrl(url);
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getTimestamp() {
    final now = DateTime.now();
    return '${now.year}${now.month}${now.day}_${now.hour}${now.minute}';
  }
}
