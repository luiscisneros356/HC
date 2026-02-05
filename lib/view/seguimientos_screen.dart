import 'package:flutter/material.dart';
import 'package:hc_catamarca/data/model/paciente.dart';
import 'package:hc_catamarca/data/services/firebase_service.dart';
import 'package:provider/provider.dart';

class SeguimientosScreen extends StatefulWidget {
  final Patient patient;

  const SeguimientosScreen({Key? key, required this.patient}) : super(key: key);

  @override
  _SeguimientosScreenState createState() => _SeguimientosScreenState();
}

class _SeguimientosScreenState extends State<SeguimientosScreen> {
  final TextEditingController _nuevoSeguimientoController =
      TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Desplazar al final cuando se agregue un nuevo seguimiento
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  void _agregarSeguimiento() async {
    if (_nuevoSeguimientoController.text.trim().isNotEmpty) {
      try {
        final firebaseService = Provider.of<FirebaseService>(
          context,
          listen: false,
        );

        // Crear copia del paciente con el nuevo seguimiento
        final pacienteActualizado = widget.patient.copyWith(
          seguimientos: [
            ...widget.patient.seguimientos,
            '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}: ${_nuevoSeguimientoController.text.trim()}',
          ],
          fechaUltimaActualizacion: DateTime.now(),
        );

        // Actualizar en Firebase
        await firebaseService.updatePatient(
          pacienteActualizado.id,
          pacienteActualizado,
        );

        // Limpiar campo
        _nuevoSeguimientoController.clear();

        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Seguimiento agregado exitosamente')),
        );

        // Desplazar al final
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _eliminarSeguimiento(int index) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Está seguro de eliminar este seguimiento?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final firebaseService = Provider.of<FirebaseService>(
                  context,
                  listen: false,
                );
                final nuevosSeguimientos = List<String>.from(
                  widget.patient.seguimientos,
                );
                nuevosSeguimientos.removeAt(index);

                final pacienteActualizado = widget.patient.copyWith(
                  seguimientos: nuevosSeguimientos,
                  fechaUltimaActualizacion: DateTime.now(),
                );

                await firebaseService.updatePatient(
                  pacienteActualizado.id,
                  pacienteActualizado,
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Seguimiento eliminado')),
                );
              } catch (e) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seguimientos - ${widget.patient.nombre}'),
        backgroundColor: Colors.amber,
      ),
      body: Column(
        children: [
          // Formulario para nuevo seguimiento
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Agregar Nuevo Seguimiento',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[900],
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _nuevoSeguimientoController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: 'Descripción del seguimiento',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        onPressed: _agregarSeguimiento,
                        icon: const Icon(Icons.add),
                        label: const Text('Agregar Seguimiento'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Lista de seguimientos existentes
          Expanded(
            child: StreamBuilder<List<Patient>>(
              stream: Provider.of<FirebaseService>(context).getPatients(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final pacientes = snapshot.data!;
                final pacienteActual = pacientes.firstWhere(
                  (p) => p.id == widget.patient.id,
                  orElse: () => widget.patient,
                );

                final seguimientos = pacienteActual.seguimientos;

                if (seguimientos.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.note_add, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No hay seguimientos registrados',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Agrega el primer seguimiento usando el formulario superior',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16.0),
                  itemCount: seguimientos.length,
                  itemBuilder: (context, index) {
                    final seguimiento = seguimientos[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Número de seguimiento
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue[100],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[900],
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),

                            // Contenido del seguimiento
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    seguimiento,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Registrado el: ${_obtenerFechaSeguimiento(seguimiento)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Botón para eliminar
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red[400]),
                              onPressed: () => _eliminarSeguimiento(index),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _obtenerFechaSeguimiento(String seguimiento) {
    try {
      // Asumiendo formato: "DD/MM/YYYY: descripción"
      final partes = seguimiento.split(':');
      if (partes.isNotEmpty) {
        return partes[0].trim();
      }
    } catch (e) {
      return 'Fecha desconocida';
    }
    return 'Fecha desconocida';
  }
}
