import 'package:flutter/material.dart';
import 'package:hc_catamarca/data/model/paciente.dart';
import 'package:hc_catamarca/data/services/firebase_service.dart';
import 'package:provider/provider.dart';

class PatientFormScreen extends StatefulWidget {
  final Patient? patient;

  const PatientFormScreen({Key? key, this.patient}) : super(key: key);

  @override
  _PatientFormScreenState createState() => _PatientFormScreenState();
}

class _PatientFormScreenState extends State<PatientFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _intervencionesController = TextEditingController();
  final _seguimientoController = TextEditingController();
  final List<String> _intervencionesList = [];
  final List<String> _seguimientoList = [];

  // Controladores para los campos
  final _nombreController = TextEditingController();
  final _edadController = TextEditingController();
  final _dniController = TextEditingController();
  final _direccionController = TextEditingController();
  final _contactoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.patient != null) {
      _nombreController.text = widget.patient!.nombre;
      _edadController.text = widget.patient!.edad.toString();
      _dniController.text = widget.patient!.dni;
      _direccionController.text = widget.patient!.direccion;
      _contactoController.text = widget.patient!.contacto;

      _intervencionesList.addAll(widget.patient!.intervenciones);
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _edadController.dispose();
    _dniController.dispose();
    _direccionController.dispose();
    _contactoController.dispose();
    _seguimientoController.dispose();
    _intervencionesController.dispose();
    super.dispose();
  }

  void _addIntervencion() {
    if (_intervencionesController.text.isNotEmpty) {
      setState(() {
        _intervencionesList.add(_intervencionesController.text);
        _intervencionesController.clear();
      });
    }
  }

  void _removeIntervencion(int index) {
    setState(() {
      _intervencionesList.removeAt(index);
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        final firebaseService = Provider.of<FirebaseService>(
          context,
          listen: false,
        );
        final now = DateTime.now();

        final patient = Patient(
          id: widget.patient?.id ?? '',
          nombre: _nombreController.text,
          edad: int.parse(_edadController.text),
          dni: _dniController.text,
          direccion: _direccionController.text,
          contacto: _contactoController.text,
          intervenciones: List<String>.from(_intervencionesList),
          seguimientos:
              widget.patient?.seguimientos ?? [], // Inicializar lista vacía
          fechaCreacion: widget.patient?.fechaCreacion ?? now,
          fechaUltimaActualizacion: now,
        );

        if (widget.patient == null) {
          await firebaseService.createPatient(patient);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Paciente creado exitosamente')),
          );
        } else {
          await firebaseService.updatePatient(patient.id, patient);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Paciente actualizado exitosamente')),
          );
        }

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.patient == null ? 'Nuevo Paciente' : 'Editar Paciente',
        ),
        backgroundColor: Colors.amber,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: InputDecoration(
                  labelText: 'Nombre Completo *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _edadController,
                decoration: InputDecoration(
                  labelText: 'Edad *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese la edad';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Por favor ingrese una edad válida';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dniController,
                decoration: InputDecoration(
                  labelText: 'DNI *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.badge),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el DNI';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _direccionController,
                decoration: InputDecoration(
                  labelText: 'Dirección',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contactoController,
                decoration: InputDecoration(
                  labelText: 'Contacto *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un contacto';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Text('Intervenciones y/o recomendaciones'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _intervencionesController,
                      decoration: InputDecoration(
                        labelText: 'Agregar intervención',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: _addIntervencion,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ..._intervencionesList.asMap().entries.map((entry) {
                final index = entry.key;
                final intervencion = entry.value;
                return ListTile(
                  title: Text(intervencion),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeIntervencion(index),
                  ),
                );
              }).toList(),

              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  widget.patient == null
                      ? 'Crear Paciente'
                      : 'Actualizar Paciente',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
