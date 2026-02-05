import 'package:flutter/material.dart';

class SeguimientoCard extends StatelessWidget {
  final String seguimiento;
  final int numero;
  final bool esReciente;
  final VoidCallback? onDelete;

  const SeguimientoCard({
    Key? key,
    required this.seguimiento,
    required this.numero,
    this.esReciente = false,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Número de seguimiento
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                '$numero',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900],
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Contenido
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (esReciente)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(4),
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
                  if (esReciente) const SizedBox(height: 8),

                  Text(seguimiento, style: const TextStyle(fontSize: 16)),

                  const SizedBox(height: 8),

                  // Extraer fecha del seguimiento
                  Text(
                    _extraerFecha(seguimiento),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            // Botón de eliminar si está disponible
            if (onDelete != null)
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red[400]),
                onPressed: onDelete,
              ),
          ],
        ),
      ),
    );
  }

  String _extraerFecha(String seguimiento) {
    try {
      final partes = seguimiento.split(':');
      if (partes.isNotEmpty) {
        return 'Fecha: ${partes[0].trim()}';
      }
    } catch (e) {
      return 'Fecha no disponible';
    }
    return 'Fecha no disponible';
  }
}
