import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whatsappweb/models/usuario.dart';

class ListaContatos extends StatefulWidget {
  const ListaContatos({Key? key}) : super(key: key);

  @override
  _ListaContatosState createState() => _ListaContatosState();
}

class _ListaContatosState extends State<ListaContatos> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String _idUsuarioLogado;

  Future<List<Usuario>> _recuperarContatos() async {
    final usuariosRef = _firestore.collection('usuarios');
    QuerySnapshot querySnapshot = await usuariosRef.get();
    List<Usuario> listaUsuarios = [];
    for (DocumentSnapshot item in querySnapshot.docs) {
      Usuario user = Usuario(
        idUsuario: item['idUsuario'],
        nome: item['nome'],
        email: item['email'],
        urlImagem: item['urlImagem'],
      );
      if (user.idUsuario != _idUsuarioLogado) {
        listaUsuarios.add(user);
      }
    }
    return listaUsuarios;
  }

  void _recuperarDadosUsuarioLogado() {
    User? user = _auth.currentUser;
    if (user != null) {
      _idUsuarioLogado = user.uid;
    }
  }

  @override
  void initState() {
    super.initState();
    _recuperarDadosUsuarioLogado();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Usuario>>(
      future: _recuperarContatos(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text('Carregando contatos'),
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
                    'Erro ao carregar os dados: ${snapshot.error.toString()}'),
              );
            } else {
              List<Usuario>? listaUsuarios = snapshot.data;
              if (listaUsuarios != null) {
                return ListView.separated(
                  separatorBuilder: (context, index) {
                    return const Divider(
                      color: Colors.grey,
                      thickness: 0.2,
                    );
                  },
                  itemCount: listaUsuarios.length,
                  itemBuilder: (context, index) {
                    Usuario user = listaUsuarios[index];
                    return ListTile(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/mensagens',
                          arguments: user,
                        );
                      },
                      leading: CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.grey,
                        backgroundImage:
                            CachedNetworkImageProvider(user.urlImagem),
                      ),
                      contentPadding: const EdgeInsets.all(8),
                      title: Text(
                        user.nome,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  },
                );
              }
              return const Center(
                child: Text('Nenhum contato encontrado'),
              );
            }
        }
      },
    );
  }
}
