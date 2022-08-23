import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whatsappweb/models/usuario.dart';
import 'package:whatsappweb/providers/conversa_provider.dart';
import 'package:whatsappweb/uteis/responsivo.dart';
import 'package:provider/provider.dart';

class ListaConversas extends StatefulWidget {
  const ListaConversas({Key? key}) : super(key: key);

  @override
  _ListaConversasState createState() => _ListaConversasState();
}

class _ListaConversasState extends State<ListaConversas> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late Usuario _usuarioRemetente;

  final StreamController _streamController =
      StreamController<QuerySnapshot>.broadcast();
  late StreamSubscription _streamConversas;

  _adicionarListenerConversas() {
    final stream = _firestore
        .collection('conversas')
        .doc(_usuarioRemetente.idUsuario)
        .collection('ultimas_mensagens')
        .snapshots();

    _streamConversas = stream.listen((dados) {
      _streamController.add(dados);
    });
  }

  _recuperarDadosIniciais() {
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

    _adicionarListenerConversas();
  }

  @override
  void initState() {
    super.initState();
    _recuperarDadosIniciais();
  }

  @override
  void dispose() {
    _streamConversas.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsivo.isMobile(context);

    return StreamBuilder(
      stream: _streamController.stream,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text('Carregando conversas'),
                  SizedBox(
                    height: 16,
                  ),
                  CircularProgressIndicator()
                ],
              ),
            );
          case ConnectionState.active:
          case ConnectionState.done:
            if (snapshot.hasError) {
              return Center(
                child: Text(
                    'Erro ao carregar as conversas: ${snapshot.error.toString()}'),
              );
            } else {
              QuerySnapshot querySnapshot = snapshot.data as QuerySnapshot;
              List<DocumentSnapshot> listaConversas =
                  querySnapshot.docs.toList();
              return ListView.separated(
                separatorBuilder: (context, index) {
                  return const Divider(
                    color: Colors.grey,
                    thickness: 0.2,
                  );
                },
                itemCount: listaConversas.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot conversa = listaConversas[index];
                  String urlImagemDestinatario =
                      conversa['urlImagemDestinatario'];
                  String nomeDestinatario = conversa['nomeDestinatario'];
                  String emailDestinatario = conversa['emailDestinatario'];
                  String ultimaMensagem = conversa['ultimaMensagem'];
                  String idDestinatario = conversa['idDestinatario'];

                  Usuario usuario = Usuario(
                      idUsuario: idDestinatario,
                      nome: nomeDestinatario,
                      email: emailDestinatario,
                      urlImagem: urlImagemDestinatario);

                  return ListTile(
                    onTap: () {
                      if (isMobile) {
                        Navigator.pushNamed(
                          context,
                          '/mensagens',
                          arguments: usuario,
                        );
                      } else {
                        context.read<ConversaProvider>().usuarioDestinatario =
                            usuario;
                      }
                    },
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.grey,
                      backgroundImage:
                          CachedNetworkImageProvider(urlImagemDestinatario),
                    ),
                    contentPadding: const EdgeInsets.all(8),
                    title: Text(
                      nomeDestinatario,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      ultimaMensagem,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                },
              );
            }
        }
      },
    );
  }
}
