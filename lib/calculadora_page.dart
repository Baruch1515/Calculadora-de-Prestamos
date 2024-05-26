import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

enum TipoPago { Diario, Semanal }

class Pago {
  final DateTime fecha;
  final double monto;
  final double saldo;

  Pago({required this.fecha, required this.monto, required this.saldo});
}

class CalculadoraPage extends StatefulWidget {
  const CalculadoraPage({Key? key}) : super(key: key);

  @override
  _CalculadoraPageState createState() => _CalculadoraPageState();
}

class _CalculadoraPageState extends State<CalculadoraPage> {
  final TextEditingController _montoController = TextEditingController();
  final TextEditingController _interesController = TextEditingController();
  final TextEditingController _cuotasController = TextEditingController();
  TipoPago _tipoPago = TipoPago.Diario;
  double _total = 0.0;
  double _cuota = 0.0;
  List<Pago> _planPago = [];
  DateTime _fechaInicio = DateTime.now();

  final NumberFormat _currencyFormat =
      NumberFormat.currency(symbol: '\$', decimalDigits: 0);
  final NumberFormat _percentFormat =
      NumberFormat.decimalPercentPattern(decimalDigits: 0, locale: 'es');

  void _calcularTotal() {
    final double monto = double.tryParse(
            _montoController.text.replaceAll(RegExp(r'[^\d.]'), '')) ??
        0;
    final double interes = double.tryParse(
            _interesController.text.replaceAll(RegExp(r'[^\d.]'), '')) ??
        0;
    final int cuotas = int.tryParse(
            _cuotasController.text.replaceAll(RegExp(r'[^\d.]'), '')) ??
        1;

    setState(() {
      _total = monto + (monto * interes / 100);
      _cuota = _total / cuotas;

      // Generar el plan de pagos
      _planPago.clear();
      DateTime fechaPago = _fechaInicio;
      double saldo = _total;
      for (int i = 0; i < cuotas; i++) {
        _planPago.add(Pago(
          fecha: fechaPago,
          monto: _cuota,
          saldo: saldo,
        ));
        saldo -= _cuota;
        if (_tipoPago == TipoPago.Diario) {
          fechaPago = fechaPago.add(const Duration(days: 1));
          while (fechaPago.weekday == DateTime.sunday) {
            fechaPago = fechaPago.add(const Duration(days: 1));
          }
        } else {
          fechaPago = fechaPago.add(const Duration(days: 7));
        }
      }
    });
  }

  String _formatCurrency(String value) {
    double amount =
        double.tryParse(value.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
    return _currencyFormat.format(amount);
  }

  String _formatPercentage(String value) {
    double percentage =
        double.tryParse(value.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
    return _percentFormat.format(percentage / 100);
  }

  @override
  void initState() {
    super.initState();
    _montoController.addListener(() {
      final text = _montoController.text;
      _montoController.value = _montoController.value.copyWith(
        text: _formatCurrency(text),
        selection:
            TextSelection.collapsed(offset: _formatCurrency(text).length),
      );
    });

    _interesController.addListener(() {
      final text = _interesController.text;
      _interesController.value = _interesController.value.copyWith(
        text: _formatPercentage(text),
        selection:
            TextSelection.collapsed(offset: _formatPercentage(text).length),
      );
    });

    _cuotasController.addListener(() {
      // Aquí iría la lógica para manejar los cambios en el campo de texto de las cuotas
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D3557),
        title: Text(
          'CALCULADORA DE PRESTAMOS',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white, // Texto del título en blanco
          ),
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: _montoController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Monto',
                  border: OutlineInputBorder(),
                ),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                ],
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _interesController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Intereses (%)',
                  border: OutlineInputBorder(),
                ),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                ],
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _cuotasController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Número de Cuotas',
                  border: OutlineInputBorder(),
                ),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                ],
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Text('Tipo de Pago: '),
                  DropdownButton<TipoPago>(
                    value: _tipoPago,
                    onChanged: (TipoPago? value) {
                      setState(() {
                        _tipoPago = value!;
                      });
                    },
                    items: TipoPago.values.map((TipoPago tipoPago) {
                      return DropdownMenuItem<TipoPago>(
                        value: tipoPago,
                        child: Text(tipoPago.toString().split('.').last),
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Text('Fecha de Inicio: '),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: TextFormField(
                        readOnly: true,
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: _fechaInicio,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2101),
                          );
                          if (picked != null) {
                            setState(() {
                              _fechaInicio = picked;
                            });
                          }
                        },
                        controller: TextEditingController(
                            text:
                                DateFormat('dd/MM/yyyy').format(_fechaInicio)),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _calcularTotal,
                child: const Text('Calcular Total'),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _limpiarCampos,
                child: const Text('Limpiar Campos'),
              ),
              const SizedBox(height: 16.0),
              Text(
                'Total con Intereses: ${_currencyFormat.format(_total)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16.0),
              Text(
                'Monto de cada Cuota: ${_currencyFormat.format(_cuota)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16.0),
              DataTable(
                columns: const <DataColumn>[
                  DataColumn(
                    label: Text('FECHA'),
                  ),
                  DataColumn(
                    label: Text('MONTO'),
                  ),
                  DataColumn(
                    label: Text('SALDO'),
                  ),
                ],
                rows: _planPago.map((pago) {
                  return DataRow(
                    cells: <DataCell>[
                      DataCell(
                          Text(DateFormat('dd/MM/yyyy').format(pago.fecha))),
                      DataCell(Text(_currencyFormat.format(pago.monto))),
                      DataCell(Text(_currencyFormat.format(pago.saldo))),
                    ],
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _limpiarCampos() {
    _montoController.clear();
    _interesController.clear();
    _cuotasController.clear();
    setState(() {
      _total = 0.0;
      _cuota = 0.0;
      _planPago.clear();
      _fechaInicio = DateTime.now();
    });
  }
}
