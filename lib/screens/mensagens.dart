import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whatsappweb/components/lista_mensagens.dart';
import 'package:whatsappweb/models/usuario.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen(this.usuarioDestinatario, {Key? key}) : super(key: key);

  final Usuario usuarioDestinatario;

  @override
  _MessagesScreenState createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late Usuario _usuarioRemetente;
  late Usuario _usuarioDestinatario;

  _recuperarDadosIniciais() {
    _usuarioDestinatario = widget.usuarioDestinatario;
    User? usuarioLogado = _auth.currentUser;
    if (usuarioLogado != null) {
      String idUsuario = usuarioLogado.uid;
      String nome = usuarioLogado.displayName ?? '';
      String email = usuarioLogado.email ?? '';
      String urlImagem = usuarioLogado.photoURL ?? '';

      _usuarioRemetente = Usuario(
        idUsuario: idUsuario,
        nome: nome,
        email: email,
        urlImagem: urlImagem,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _recuperarDadosIniciais();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: Colors.grey,
              backgroundImage:
                  CachedNetworkImageProvider(_usuarioDestinatario.urlImagem),
            ),
            const SizedBox(
              width: 8,
            ),
            Text(
              _usuarioDestinatario.nome,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            )
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: ListaMensagens(
          usuarioDestinatario: _usuarioDestinatario,
          usuarioRemetente: _usuarioRemetente,
        ),
      ),
    );
  }
}
