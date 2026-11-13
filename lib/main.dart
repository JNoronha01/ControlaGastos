import 'package:flutter/material.dart';

import 'gasto.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Controle de Gastos',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: const TelaGastos(title: 'Página Inicial - Controle de Gastos'),
    );
  }
}

class TelaGastos extends StatefulWidget {
  const TelaGastos({super.key, required this.title});
  final String title;

  @override
  State<TelaGastos> createState() => _TelaGastosState();
}

class _TelaGastosState extends State<TelaGastos> {
  final ControleGastos _controle = ControleGastos();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: .center,
          children: [Text('Total: R\$ ${_controle.total.toStringAsFixed(2)}')],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Adicionar Gasto',
        child: const Icon(Icons.add),
      ),
    );
  }
}
