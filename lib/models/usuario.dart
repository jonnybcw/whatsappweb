import 'package:flutter/material.dart';

class Usuario {
  String idUsuario;
  String nome;
  String email;
  String urlImagem;

  Usuario({
    required this.idUsuario,
    required this.nome,
    required this.email,
    this.urlImagem = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'idUsuario': idUsuario,
      'nome': nome,
      'email': email,
      'urlImagem': urlImagem,
    };
  }
}
