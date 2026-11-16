import 'package:flutter/material.dart';

// Cores, textos e estilos do app, copiados do guia de estilo do Figma
// ("ControlaGastos – UI/UX", página "Guia de estilo").
// Mudar uma cor aqui muda o app inteiro.

/// Paleta de cores. Os nomes são os mesmos das variáveis do Figma.
class Cores {
  static const fundo = Color(0xFFF6F5F2); // fundo das telas
  static const superficie = Color(0xFFFFFFFF); // cartões e campos
  static const superficie2 = Color(0xFFEFEDE8); // trilhos e círculo dos ícones
  static const borda = Color(0xFFE1DED7); // bordas e divisores
  static const texto = Color(0xFF1B1D1F); // texto principal
  static const textoSecundario = Color(0xFF5E6366); // rótulos e detalhes
  static const primaria = Color(0xFF1F5C4A); // ações e progresso
  static const primariaClara = Color(0xFFE3EEE9);
  static const sobrePrimaria = Color(0xFFFFFFFF); // texto em cima da primária
  static const alerta = Color(0xFF9A5B00); // a partir de 90% do orçamento
  static const erro = Color(0xFFB3261E); // acima do limite / erro
}

/// Estilos de texto do Figma (fonte Inter).
class Textos {
  static const _fonte = 'Inter';

  static const valorDestaque = TextStyle(
    fontFamily: _fonte,
    fontSize: 34,
    height: 40 / 34,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.5,
    color: Cores.texto,
  );
  static const tituloTela = TextStyle(
    fontFamily: _fonte,
    fontSize: 24,
    height: 30 / 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    color: Cores.texto,
  );
  static const tituloSecao = TextStyle(
    fontFamily: _fonte,
    fontSize: 17,
    height: 24 / 17,
    fontWeight: FontWeight.w600,
    color: Cores.texto,
  );
  static const corpo = TextStyle(
    fontFamily: _fonte,
    fontSize: 15,
    height: 22 / 15,
    fontWeight: FontWeight.w400,
    color: Cores.texto,
  );
  static const corpoForte = TextStyle(
    fontFamily: _fonte,
    fontSize: 15,
    height: 22 / 15,
    fontWeight: FontWeight.w500,
    color: Cores.texto,
  );
  static const legenda = TextStyle(
    fontFamily: _fonte,
    fontSize: 13,
    height: 18 / 13,
    fontWeight: FontWeight.w400,
    color: Cores.textoSecundario,
  );
  static const legendaForte = TextStyle(
    fontFamily: _fonte,
    fontSize: 13,
    height: 18 / 13,
    fontWeight: FontWeight.w500,
    color: Cores.textoSecundario,
  );
}

/// Medidas que se repetem nas telas.
class Medidas {
  static const margemTela = 24.0; // espaço nas laterais da tela
  static const raioCartao = 16.0;
  static const raioCampo = 12.0;
  static const alturaBotao = 52.0;
  static const larguraMaxima =
      480.0; // no navegador, o app não estica além disso
}

/// Monta o ThemeData do Flutter a partir das cores e textos acima,
/// para que os widgets prontos (botões, campos, calendário) já saiam no estilo.
ThemeData criarTema() {
  final esquema =
      ColorScheme.fromSeed(
        seedColor: Cores.primaria,
        brightness: Brightness.light,
      ).copyWith(
        primary: Cores.primaria,
        onPrimary: Cores.sobrePrimaria,
        primaryContainer: Cores.primariaClara,
        onPrimaryContainer: Cores.primaria,
        surface: Cores.superficie,
        onSurface: Cores.texto,
        onSurfaceVariant: Cores.textoSecundario,
        outline: Cores.borda,
        outlineVariant: Cores.borda,
        error: Cores.erro,
      );

  final bordaCampo = OutlineInputBorder(
    borderRadius: BorderRadius.circular(Medidas.raioCampo),
    borderSide: const BorderSide(color: Cores.borda),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: esquema,
    fontFamily: 'Inter',
    scaffoldBackgroundColor: Cores.fundo,
    appBarTheme: const AppBarTheme(
      backgroundColor: Cores.fundo,
      foregroundColor: Cores.texto,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: Textos.tituloSecao,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Cores.superficie,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      hintStyle: Textos.corpo.copyWith(color: Cores.textoSecundario),
      errorStyle: Textos.legenda.copyWith(color: Cores.erro),
      border: bordaCampo,
      enabledBorder: bordaCampo,
      focusedBorder: bordaCampo.copyWith(
        borderSide: const BorderSide(color: Cores.primaria, width: 1.5),
      ),
      errorBorder: bordaCampo.copyWith(
        borderSide: const BorderSide(color: Cores.erro, width: 1.5),
      ),
      focusedErrorBorder: bordaCampo.copyWith(
        borderSide: const BorderSide(color: Cores.erro, width: 1.5),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: Cores.primaria,
        foregroundColor: Cores.sobrePrimaria,
        minimumSize: const Size.fromHeight(Medidas.alturaBotao),
        textStyle: Textos.corpoForte,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Medidas.raioCampo),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Cores.primaria,
        textStyle: Textos.corpoForte,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Cores.primaria,
      foregroundColor: Cores.sobrePrimaria,
      elevation: 2,
      highlightElevation: 4,
      shape: StadiumBorder(),
      extendedTextStyle: Textos.corpoForte,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Cores.texto,
      contentTextStyle: Textos.corpo.copyWith(color: Cores.sobrePrimaria),
      actionTextColor: Cores.primariaClara,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Medidas.raioCampo),
      ),
    ),
    dividerTheme: const DividerThemeData(color: Cores.borda, thickness: 1),
    datePickerTheme: const DatePickerThemeData(
      backgroundColor: Cores.superficie,
      surfaceTintColor: Colors.transparent,
    ),
  );
}
