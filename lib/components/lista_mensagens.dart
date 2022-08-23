import 'dart:async';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:whatsappweb/models/conversa.dart';
import 'package:whatsappweb/models/mensagem.dart';
import 'package:whatsappweb/models/usuario.dart';
import 'package:whatsappweb/providers/conversa_provider.dart';
import 'package:whatsappweb/uteis/paleta_cores.dart';

class ListaMensagens extends StatefulWidget {
  final Usuario usuarioRemetente;
  final Usuario usuarioDestinatario;

  const ListaMensagens({
    required this.usuarioRemetente,
    required this.usuarioDestinatario,
    Key? key,
  }) : super(key: key);

  @override
  _ListaMensagensState createState() => _ListaMensagensState();
}

class _ListaMensagensState extends State<ListaMensagens> {
  final TextEditingController _controllerMessage = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late Usuario _usuarioRemetente;
  late Usuario _usuarioDestinatario;

  final StreamController _streamController =
      StreamController<QuerySnapshot>.broadcast();
  late StreamSubscription _streamMessages;

  _enviarMensagem() {
    String textMessage = _controllerMessage.text;
    if (textMessage.isNotEmpty) {
      String idUsuarioRemetente = _usuarioRemetente.idUsuario;
      Mensagem mensagem = Mensagem(
        idUsuario: idUsuarioRemetente,
        texto: textMessage,
        data: Timestamp.now().toString(),
      );

      // Salvar mensagem para remetente
      String idUsuarioDestinatario = _usuarioDestinatario.idUsuario;
      _salvarMensagem(idUsuarioRemetente, idUsuarioDestinatario, mensagem);
      Conversa conversaRemetente = Conversa(
        idUsuarioRemetente,
        idUsuarioDestinatario,
        mensagem.texto,
        _usuarioDestinatario.nome,
        _usuarioDestinatario.email,
        _usuarioDestinatario.urlImagem,
      );
      _salvarConversa(conversaRemetente);

      // Salvar mensagem para destinatário
      _salvarMensagem(idUsuarioDestinatario, idUsuarioRemetente, mensagem);
      Conversa conversaDestinatario = Conversa(
        idUsuarioDestinatario,
        idUsuarioRemetente,
        mensagem.texto,
        _usuarioRemetente.nome,
        _usuarioRemetente.email,
        _usuarioRemetente.urlImagem,
      );
      _salvarConversa(conversaDestinatario);
    }
  }

  _salvarConversa(Conversa conversa) {
    _firestore
        .collection('conversas')
        .doc(conversa.idRemetente)
        .collection('ultimas_mensagens')
        .doc(conversa.idDestinatario)
        .set(conversa.toMap());
  }

  _salvarMensagem(
      String idRemetente, String idDestinatario, Mensagem mensagem) {
    _firestore
        .collection('mensagens')
        .doc(idRemetente)
        .collection(idDestinatario)
        .add(mensagem.toMap());

    _controllerMessage.clear();
  }

  _recuperarDadosIniciais() {
    _usuarioRemetente = widget.usuarioRemetente;
    _usuarioDestinatario = widget.usuarioDestinatario;

    _adicionarListenerMensagens();
  }

  _atualizarListenerMensagens() {
    Usuario? usuarioDestinatario =
        context.watch<ConversaProvider>().usuarioDestinatario;
    if (usuarioDestinatario != null) {
      _usuarioDestinatario = usuarioDestinatario;
      _recuperarDadosIniciais();
    }
  }

  _adicionarListenerMensagens() {
    final stream = _firestore
        .collection('mensagens')
        .doc(_usuarioRemetente.idUsuario)
        .collection(_usuarioDestinatario.idUsuario)
        .orderBy('data', descending: false)
        .snapshots();

    _streamMessages = stream.listen((dados) {
      _streamController.add(dados);
      Timer(const Duration(seconds: 1), () {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _atualizarListenerMensagens();
  }

  @override
  void dispose() {
    _streamMessages.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _recuperarDadosIniciais();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
            'imagens/bg.png',
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Lista de mensagens
          StreamBuilder(
            stream: _streamController.stream,
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return Expanded(
                      child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text('Carregando dados'),
                        SizedBox(
                          height: 16,
                        ),
                        CircularProgressIndicator()
                      ],
                    ),
                  ));
                case ConnectionState.active:
                case ConnectionState.done:
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                          'Erro ao carregar os dados: ${snapshot.error.toString()}'),
                    );
                  } else {
                    QuerySnapshot querySnapshot =
                        snapshot.data as QuerySnapshot;
                    List<DocumentSnapshot> listaMensagens =
                        querySnapshot.docs.toList();
                    return Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: querySnapshot.docs.length,
                        itemBuilder: (context, index) {
                          DocumentSnapshot mensagem = listaMensagens[index];
                          Alignment alignment = Alignment.bottomLeft;
                          Color cor = Colors.white;

                          if (_usuarioRemetente.idUsuario ==
                              mensagem['idUsuario']) {
                            alignment = Alignment.bottomRight;
                            cor = const Color(0xFFD2FFA5);
                          }

                          Size size = MediaQuery.of(context).size * 0.8;

                          return Align(
                            alignment: alignment,
                            child: Container(
                              constraints: BoxConstraints.loose(size),
                              decoration: BoxDecoration(
                                color: cor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.all(16),
                              margin: const EdgeInsets.all(6),
                              child: Text(mensagem['texto']),
                            ),
                          );
                        },
                      ),
                    );
                  }
              }
            },
          ),

          // Caixa de texto
          Container(
            padding: const EdgeInsets.all(8),
            color: PaletaCores.corFundoBarra,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.insert_emoticon),
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        Expanded(
                          child: TextField(
                            controller: _controllerMessage,
                            autofocus: true,
                            decoration: const InputDecoration(
                              hintText: 'Digite uma mensagem',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.attach_file_rounded),
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.camera_alt),
                        ),
                      ],
                    ),
                  ),
                ),
                FloatingActionButton(
                  onPressed: () {
                    _enviarMensagem();
                  },
                  mini: true,
                  backgroundColor: PaletaCores.corPrimaria,
                  child: const Icon(
                    Icons.send,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
