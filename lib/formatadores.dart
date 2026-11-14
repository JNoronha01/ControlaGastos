// Funções pequenas para mostrar números e datas no padrão brasileiro,
// sem precisar de nenhum pacote externo.

/// 1234.5 vira "R$ 1234,50"
String formatarMoeda(double valor) {
  return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
}

/// DateTime(2026, 11, 3) vira "03/11/2026"
String formatarData(DateTime data) {
  // padLeft(2, '0') completa com zero à esquerda: "3" vira "03".
  final dia = data.day.toString().padLeft(2, '0');
  final mes = data.month.toString().padLeft(2, '0');
  return '$dia/$mes/${data.year}';
}
