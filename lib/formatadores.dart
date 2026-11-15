// Funções pequenas para mostrar números e datas no padrão brasileiro,
// sem precisar de nenhum pacote externo.

/// 1234.5 vira "R$ 1.234,50"
String formatarMoeda(double valor) {
  final negativo = valor < 0;
  // toStringAsFixed(2) arredonda para 2 casas: 1234.5 -> "1234.50"
  final partes = valor.abs().toStringAsFixed(2).split('.');
  final inteiro = partes[0];
  final centavos = partes[1];

  // Põe um ponto a cada 3 dígitos, contando da direita: 1234567 -> 1.234.567
  final comPontos = StringBuffer();
  for (var i = 0; i < inteiro.length; i++) {
    final faltam = inteiro.length - i;
    if (i > 0 && faltam % 3 == 0) comPontos.write('.');
    comPontos.write(inteiro[i]);
  }

  return '${negativo ? '-' : ''}R\$ $comPontos,$centavos';
}

/// DateTime(2026, 11, 3) vira "03/11/2026"
String formatarData(DateTime data) {
  // padLeft(2, '0') completa com zero à esquerda: "3" vira "03".
  final dia = data.day.toString().padLeft(2, '0');
  final mes = data.month.toString().padLeft(2, '0');
  return '$dia/$mes/${data.year}';
}

const _meses = [
  'jan',
  'fev',
  'mar',
  'abr',
  'mai',
  'jun',
  'jul',
  'ago',
  'set',
  'out',
  'nov',
  'dez',
];

const _diasDaSemana = [
  'Segunda',
  'Terça',
  'Quarta',
  'Quinta',
  'Sexta',
  'Sábado',
  'Domingo',
];

/// Título de cada grupo da lista, como no Figma:
/// "Hoje, 15 nov", "Ontem, 14 nov", "Quinta, 12 nov".
/// [hoje] pode ser passado nos testes; no app usa a data atual.
String formatarDiaDaLista(DateTime data, {DateTime? hoje}) {
  final agora = hoje ?? DateTime.now();
  final dia = DateTime(data.year, data.month, data.day);
  final diaDeHoje = DateTime(agora.year, agora.month, agora.day);
  final diferenca = diaDeHoje.difference(dia).inDays;

  final String nome;
  if (diferenca == 0) {
    nome = 'Hoje';
  } else if (diferenca == 1) {
    nome = 'Ontem';
  } else {
    // weekday vai de 1 (segunda) a 7 (domingo).
    nome = _diasDaSemana[data.weekday - 1];
  }
  return '$nome, ${data.day} ${_meses[data.month - 1]}';
}
