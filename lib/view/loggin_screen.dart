import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hc_catamarca/view/home_screen.dart';

class SimpleLocalLoginScreen extends StatefulWidget {
  const SimpleLocalLoginScreen({Key? key}) : super(key: key);

  @override
  _SimpleLocalLoginScreenState createState() => _SimpleLocalLoginScreenState();
}

class _SimpleLocalLoginScreenState extends State<SimpleLocalLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dniController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = true;

  // Usuarios predefinidos para desarrollo
  final List<Map<String, String>> _predefinedUsers = [
    {'dni': '12345678', 'password': 'harry'},
  ];

  @override
  void dispose() {
    _dniController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // Validación simple en el widget

      final dni = _dniController.text.trim();
      final password = _passwordController.text;

      // Buscar usuario en la lista predefinida
      final user = _predefinedUsers.firstWhere(
        (user) => user['dni'] == dni && user['password'] == password,
        orElse: () => {},
      );

      // Pequeño delay para simular procesamiento
      Future.delayed(Duration(milliseconds: 1000), () {
        setState(() => _isLoading = false);

        if (user.isNotEmpty) {
          // Login exitoso

          Fluttertoast.showToast(
            msg: '¡Bienvenido !',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.green,
            textColor: Colors.white,
          );

          final route = MaterialPageRoute(builder: (context) => HomeScreen());
          if (mounted) Navigator.pushReplacement(context, route);
        } else {
          // Credenciales incorrectas
          Fluttertoast.showToast(
            msg: 'Credenciales incorrectas',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo/Icono
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.medical_services,
                  size: 50,
                  color: Colors.blue[800],
                ),
              ),
              SizedBox(height: 20),

              // Título
              Text(
                'Historia Clínica',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900],
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Sistema de Gestión Médica',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              SizedBox(height: 40),

              // Card del formulario
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Título del formulario
                        Text(
                          'Iniciar Sesión',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[900],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Ingrese sus credenciales',
                          style: TextStyle(color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 25),

                        // Campo: Nombre y Apellido

                        // Campo: DNI
                        TextFormField(
                          controller: _dniController,
                          decoration: InputDecoration(
                            labelText: 'DNI',
                            prefixIcon: Icon(
                              Icons.badge,
                              color: Colors.blue[700],
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 15,
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          maxLength: 8,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ingrese su DNI';
                            }
                            if (value.length != 8) {
                              return 'El DNI debe tener 8 dígitos';
                            }
                            if (!RegExp(r'^\d+$').hasMatch(value)) {
                              return 'Solo se permiten números';
                            }
                            if (value != '12345678') {
                              return 'DNI no registrado';
                            }

                            return null;
                          },
                        ),
                        SizedBox(height: 20),

                        // Campo: Contraseña
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            prefixIcon: Icon(
                              Icons.lock,
                              color: Colors.blue[700],
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.grey[600],
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 15,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ingrese la contraseña';
                            }
                            if (value != 'harry') {
                              return 'Contraseña incorrecta';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 10),

                        // Recordar datos (opcional)
                        Row(
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              onChanged: (value) {
                                setState(() {
                                  _rememberMe = value ?? true;
                                });
                              },
                              activeColor: Colors.blue[800],
                            ),
                            Text('Recordar mis datos'),
                          ],
                        ),

                        // Indicador de contraseña
                        SizedBox(height: 25),

                        // Botón de login
                        _isLoading
                            ? Center(child: CircularProgressIndicator())
                            : ElevatedButton(
                                onPressed: _login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue[800],
                                  minimumSize: Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 3,
                                ),
                                child: Text(
                                  'Ingresar al Sistema',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                        SizedBox(height: 15),

                        // Botón de invitado
                      ],
                    ),
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
