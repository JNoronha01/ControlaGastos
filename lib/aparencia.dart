import 'package:flutter/material.dart';

import 'gasto.dart';

// Ícones e nomes de cada tipo de lançamento e de cada categoria.
// Ficam aqui (e não em gasto.dart) para o modelo não depender do Flutter.

IconData iconeDaCategoria(Categoria categoria) {
  switch (categoria) {
    case Categoria.mercado:
      return Icons.shopping_cart_outlined;
    case Categoria.alimentacao:
      return Icons.restaurant_outlined;
    case Categoria.transporte:
      return Icons.directions_car_outlined;
    case Categoria.moradia:
      return Icons.home_outlined;
    case Categoria.assinaturas:
      return Icons.subscriptions_outlined;
    case Categoria.lazer:
      return Icons.sports_esports_outlined;
    case Categoria.saude:
      return Icons.favorite_border;
    case Categoria.outros:
      return Icons.more_horiz;
  }
}

/// Ícone de um lançamento: a categoria, se for gasto; senão, o tipo.
IconData iconeDoLancamento(Gasto lancamento) {
  switch (lancamento.tipo) {
    case TipoLancamento.gasto:
      return iconeDaCategoria(lancamento.categoria!);
    case TipoLancamento.entrada:
      return Icons.south_west; // dinheiro chegando
    case TipoLancamento.investimento:
      return Icons.trending_up;
  }
}

/// Texto pequeno embaixo da descrição: "Mercado", "Entrada", "Investimento".
String rotuloDoLancamento(Gasto lancamento) {
  switch (lancamento.tipo) {
    case TipoLancamento.gasto:
      return lancamento.categoria!.nome;
    case TipoLancamento.entrada:
      return 'Entrada';
    case TipoLancamento.investimento:
      return 'Investimento';
  }
}

String nomeDoTipo(TipoLancamento tipo) {
  switch (tipo) {
    case TipoLancamento.gasto:
      return 'Gasto';
    case TipoLancamento.entrada:
      return 'Entrada';
    case TipoLancamento.investimento:
      return 'Investimento';
  }
}
