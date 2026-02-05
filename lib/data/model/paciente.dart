import 'package:cloud_firestore/cloud_firestore.dart';

class Patient {
  String id;
  String nombre;
  int edad;
  String dni;
  String direccion;
  String contacto;
  List<String> intervenciones;
  List<String> seguimientos; // Cambiado de String a List<String>
  DateTime fechaCreacion;
  DateTime fechaUltimaActualizacion;

  Patient({
    required this.id,
    required this.nombre,
    required this.edad,
    required this.dni,
    required this.direccion,
    required this.contacto,
    required this.intervenciones,
    required this.seguimientos, // Cambiado
    required this.fechaCreacion,
    required this.fechaUltimaActualizacion,
  });

  factory Patient.fromMap(Map<String, dynamic> data, String id) {
    return Patient(
      id: id,
      nombre: data['nombre'] ?? '',
      edad: data['edad'] ?? 0,
      dni: data['dni'] ?? '',
      direccion: data['direccion'] ?? '',
      contacto: data['contacto'] ?? '',
      intervenciones: List<String>.from(data['intervenciones'] ?? []),
      seguimientos: List<String>.from(data['seguimientos'] ?? []), // Cambiado
      fechaCreacion: (data['fechaCreacion'] as Timestamp).toDate(),
      fechaUltimaActualizacion: (data['fechaUltimaActualizacion'] as Timestamp)
          .toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'edad': edad,
      'dni': dni,
      'direccion': direccion,
      'contacto': contacto,
      'intervenciones': intervenciones,
      'seguimientos': seguimientos, // Cambiado
      'fechaCreacion': Timestamp.fromDate(fechaCreacion),
      'fechaUltimaActualizacion': Timestamp.fromDate(fechaUltimaActualizacion),
    };
  }

  Patient copyWith({
    String? id,
    String? nombre,
    int? edad,
    String? dni,
    String? direccion,
    String? contacto,
    List<String>? intervenciones,
    List<String>? seguimientos, // Cambiado
    DateTime? fechaCreacion,
    DateTime? fechaUltimaActualizacion,
  }) {
    return Patient(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      edad: edad ?? this.edad,
      dni: dni ?? this.dni,
      direccion: direccion ?? this.direccion,
      contacto: contacto ?? this.contacto,
      intervenciones: intervenciones ?? this.intervenciones,
      seguimientos: seguimientos ?? this.seguimientos, // Cambiado
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaUltimaActualizacion:
          fechaUltimaActualizacion ?? this.fechaUltimaActualizacion,
    );
  }

  // Método para agregar un nuevo seguimiento
  void agregarSeguimiento(String seguimiento) {
    seguimientos.add(seguimiento);
    fechaUltimaActualizacion = DateTime.now();
  }

  // Método para obtener el último seguimiento
  String? get ultimoSeguimiento {
    return seguimientos.isNotEmpty ? seguimientos.last : null;
  }

  // Método para obtener todos los seguimientos como String separado por saltos de línea
  String get seguimientosTexto {
    return seguimientos.map((s) => '• $s').join('\n');
  }
}
