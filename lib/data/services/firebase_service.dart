import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hc_catamarca/data/model/paciente.dart';

class FirebaseService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = 'pacientes';

  // Crear paciente
  Future<String> createPatient(Patient patient) async {
    try {
      final docRef = await _firestore
          .collection(collectionName)
          .add(patient.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Error al crear paciente: $e');
    }
  }

  // Leer todos los pacientes
  Stream<List<Patient>> getPatients() {
    return _firestore
        .collection(collectionName)
        .orderBy('fechaCreacion', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Patient.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  // Leer un paciente específico
  Future<Patient?> getPatient(String id) async {
    try {
      final doc = await _firestore.collection(collectionName).doc(id).get();
      if (doc.exists) {
        return Patient.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener paciente: $e');
    }
  }

  // Actualizar paciente
  Future<void> updatePatient(String id, Patient patient) async {
    try {
      await _firestore
          .collection(collectionName)
          .doc(id)
          .update(patient.toMap());
    } catch (e) {
      throw Exception('Error al actualizar paciente: $e');
    }
  }

  // Eliminar paciente
  Future<void> deletePatient(String id) async {
    try {
      await _firestore.collection(collectionName).doc(id).delete();
    } catch (e) {
      throw Exception('Error al eliminar paciente: $e');
    }
  }

  // Obtener todos los pacientes para Excel
  Future<List<Patient>> getAllPatientsForExcel() async {
    try {
      final querySnapshot = await _firestore
          .collection(collectionName)
          .orderBy('fechaCreacion', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Patient.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener pacientes para Excel: $e');
    }
  }
}
