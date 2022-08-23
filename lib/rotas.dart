import 'package:flutter/material.dart';
import 'package:whatsappweb/models/usuario.dart';
import 'package:whatsappweb/screens/home.dart';
import 'package:whatsappweb/screens/login.dart';
import 'package:whatsappweb/screens/mensagens.dart';

class Rotas {
  static Route<dynamic> gerarRotas(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          builder: (context) {
            return const Login();
          },
        );
      case '/login':
        return MaterialPageRoute(
          builder: (context) {
            return const Login();
          },
        );
      case '/home':
        return MaterialPageRoute(
          builder: (context) {
            return const Home();
          },
        );
      case '/mensagens':
        return MaterialPageRoute(
          builder: (context) {
            return MessagesScreen(args as Usuario);
          },
        );
    }

    return _erroRota();
  }

  static Route<dynamic> _erroRota() {
    return MaterialPageRoute(builder: (context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Tela não encontrada'),
        ),
        body: const Center(
          child: Text('Tela não encontrada'),
        ),
      );
    });
  }
}
