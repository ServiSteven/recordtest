import 'package:flutter/material.dart';

const Color AzulClaro = Color(0xff2596be);
const Color VerdePantano = Color(0xff16573a);
const Color Verde = Color(0xff55c46a);
const Color Rojo = Color(0xffaf2018);
const Color Bazaar = Color(0xff988084);

ThemeData miTema(BuildContext con) {
  return ThemeData(
    primaryColor: AzulClaro, //color de fondo principal
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: Colors.blue,
    ).copyWith(
      secondary: Colors.green,
    ),
  );
}
