import 'package:flutter/material.dart';
import 'package:hc_catamarca/data/model/paciente.dart';
import 'package:hc_catamarca/data/services/firebase_service.dart';
import 'package:provider/provider.dart';

class IntervencionesScreen extends StatefulWidget {
  final Patient patient;

  const IntervencionesScreen({Key? key, required this.patient})
    : super(key: key);

  @override
  _IntervencionesScreenState createState() => _IntervencionesScreenState();
}

class _IntervencionesScreenState extends State<IntervencionesScreen> {
  final TextEditingController _nuevaIntervencionController =
      TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Desplazar al final cuando se agregue una nueva intervención
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  void _agregarIntervencion() async {
    if (_nuevaIntervencionController.text.trim().isNotEmpty) {
      try {
        final firebaseService = Provider.of<FirebaseService>(
          context,
          listen: false,
        );

        // Crear copia del paciente con la nueva intervención
        final pacienteActualizado = widget.patient.copyWith(
          intervenciones: [
            ...widget.patient.intervenciones,
            '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}: ${_nuevaIntervencionController.text.trim()}',
          ],
          fechaUltimaActualizacion: DateTime.now(),
        );

        // Actualizar en Firebase
        await firebaseService.updatePatient(
          pacienteActualizado.id,
          pacienteActualizado,
        );

        // Limpiar campo
        _nuevaIntervencionController.clear();

        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Intervención agregada exitosamente')),
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

  void _eliminarIntervencion(int index) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Está seguro de eliminar esta intervención?'),
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
                final nuevasIntervenciones = List<String>.from(
                  widget.patient.intervenciones,
                );
                nuevasIntervenciones.removeAt(index);

                final pacienteActualizado = widget.patient.copyWith(
                  intervenciones: nuevasIntervenciones,
                  fechaUltimaActualizacion: DateTime.now(),
                );

                await firebaseService.updatePatient(
                  pacienteActualizado.id,
                  pacienteActualizado,
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Intervención eliminada')),
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
        title: Text('Intervenciones - ${widget.patient.nombre}'),
        backgroundColor: Colors.purple[900], // Color diferente para distinguir
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () {
              // Opción para exportar intervenciones a PDF
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Formulario para nueva intervención
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.medical_services, color: Colors.purple[800]),
                        const SizedBox(width: 8),
                        Text(
                          'Agregar Nueva Intervención',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple[900],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _nuevaIntervencionController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: 'Descripción detallada de la intervención',
                        hintText:
                            'Ej: Cirugía de apéndice, Tratamiento con medicamentos X, etc.',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () => _nuevaIntervencionController.clear(),
                          child: const Text('Limpiar'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: _agregarIntervencion,
                          icon: const Icon(Icons.add),
                          label: const Text('Agregar Intervención'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Nota: La fecha se agregará automáticamente al inicio de cada intervención',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Lista de intervenciones existentes
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

                final intervenciones = pacienteActual.intervenciones;

                if (intervenciones.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.medical_services_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No hay intervenciones registradas',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Agrega la primera intervención usando el formulario superior',
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
                  itemCount: intervenciones.length,
                  itemBuilder: (context, index) {
                    final intervencion = intervenciones[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Número de intervención
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.purple[100],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.purple[900],
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),

                            // Contenido de la intervención
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          intervencion,
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ),
                                      // Indicador si es la más reciente
                                      if (index == intervenciones.length - 1)
                                        Container(
                                          margin: const EdgeInsets.only(
                                            left: 8,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.purple[50],
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                            border: Border.all(
                                              color: Colors.purple[200]!,
                                            ),
                                          ),
                                          child: Text(
                                            'RECIENTE',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.purple[800],
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        size: 14,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Fecha: ${_obtenerFechaIntervencion(intervencion)}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        'Intervención ${index + 1}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.purple[700],
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Botón para eliminar
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red[400]!),
                              onPressed: () => _eliminarIntervencion(index),
                              tooltip: 'Eliminar intervención',
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Desplazar al formulario
          Scrollable.ensureVisible(
            context,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
          // Enfocar el campo de texto
          FocusScope.of(context).requestFocus(FocusNode());
          Future.delayed(const Duration(milliseconds: 350), () {
            _nuevaIntervencionController.selection = TextSelection.fromPosition(
              TextPosition(offset: _nuevaIntervencionController.text.length),
            );
          });
        },
        backgroundColor: Colors.purple[700],
        child: const Icon(Icons.add),
        tooltip: 'Agregar nueva intervención',
      ),
    );
  }

  String _obtenerFechaIntervencion(String intervencion) {
    try {
      // Asumiendo formato: "DD/MM/YYYY: descripción"
      final partes = intervencion.split(':');
      if (partes.isNotEmpty) {
        return partes[0].trim();
      }
    } catch (e) {
      return 'Fecha desconocida';
    }
    return 'Fecha desconocida';
  }
}
