import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:whatsappweb/models/usuario.dart';
import 'package:whatsappweb/uteis/paleta_cores.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _controllerNome = TextEditingController();
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerSenha = TextEditingController();

  bool _cadastroUsuario = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Uint8List? _arquivoImagemSelecionada;

  void _selecionarImagem() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    setState(() {
      _arquivoImagemSelecionada = result?.files.single.bytes;
    });
  }

  void _uploadImagem(Usuario usuario) {
    Uint8List? arquivoSelecionado = _arquivoImagemSelecionada;
    if (arquivoSelecionado != null) {
      Reference imagemPerfilRef =
          _storage.ref('imagens/perfil/${usuario.idUsuario}.jpg');
      UploadTask uploadTask = imagemPerfilRef.putData(arquivoSelecionado);
      uploadTask.whenComplete(() async {
        String linkImagem = await uploadTask.snapshot.ref.getDownloadURL();
        usuario.urlImagem = linkImagem;

        // Atualizar url e nome nos dados do usuário
        await _auth.currentUser?.updateDisplayName(usuario.nome);
        await _auth.currentUser?.updatePhotoURL(usuario.urlImagem);

        final usuariosRef = _firestore.collection('usuarios');
        usuariosRef
            .doc('${usuario.idUsuario}')
            .set(usuario.toMap())
            .then((value) {
          // rota para tela principal
          Navigator.pushReplacementNamed(context, '/home');
        });
      });
    }
  }

  void _validarCampos() async {
    String nome = _controllerNome.text;
    String email = _controllerEmail.text;
    String senha = _controllerSenha.text;

    if (email.isNotEmpty && email.contains('@')) {
      if (senha.isNotEmpty && senha.length > 6) {
        if (_cadastroUsuario) {
          if (_arquivoImagemSelecionada != null) {
            // Cadastro
            if (nome.isNotEmpty && nome.length > 3) {
              await _auth
                  .createUserWithEmailAndPassword(
                email: email,
                password: senha,
              )
                  .then((auth) {
                // Upload image
                String? idUsuario = auth.user?.uid;
                print('Usuário cadastrado: $idUsuario');

                if (idUsuario != null) {
                  Usuario usuario = Usuario(
                    idUsuario: idUsuario,
                    nome: nome,
                    email: email,
                  );
                  _uploadImagem(usuario);
                }
              });
            } else {
              print('Nome inválido, digite ao menos 3 caracteres');
            }
          } else {
            print('Selecione uma imagem');
          }
        } else {
          // Login
          await _auth
              .signInWithEmailAndPassword(
            email: email,
            password: senha,
          )
              .then((auth) {
            Navigator.pushReplacementNamed(context, '/home');
          });
        }
      } else {
        print('Senha inválido');
      }
    } else {
      print('Email inválido');
    }
  }

  @override
  Widget build(BuildContext context) {
    double alturaTela = MediaQuery.of(context).size.height;
    double larguraTela = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        color: PaletaCores.corFundo,
        width: larguraTela,
        height: alturaTela,
        child: Stack(
          children: [
            Positioned(
              child: Container(
                width: larguraTela,
                height: alturaTela * 0.4,
                color: PaletaCores.corPrimaria,
              ),
            ),
            Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    elevation: 4,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(40),
                      width: 500,
                      child: Column(
                        children: [
                          Visibility(
                            visible: _cadastroUsuario,
                            child: Column(
                              children: [
                                ClipOval(
                                  child: _arquivoImagemSelecionada != null
                                      ? Image.memory(
                                          _arquivoImagemSelecionada!,
                                          width: 120,
                                          height: 120,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.asset(
                                          'imagens/perfil.png',
                                          width: 120,
                                          height: 120,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                                const SizedBox(
                                  height: 16,
                                ),
                                OutlinedButton(
                                  onPressed: _selecionarImagem,
                                  child: const Text('Selecionar foto'),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                TextField(
                                  keyboardType: TextInputType.text,
                                  controller: _controllerNome,
                                  decoration: const InputDecoration(
                                    hintText: 'Nome',
                                    labelText: 'Nome',
                                    suffixIcon: Icon(Icons.person_outline),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextField(
                            keyboardType: TextInputType.emailAddress,
                            controller: _controllerEmail,
                            decoration: const InputDecoration(
                              hintText: 'Email',
                              labelText: 'Email',
                              suffixIcon: Icon(Icons.mail_outline),
                            ),
                          ),
                          TextField(
                            keyboardType: TextInputType.text,
                            controller: _controllerSenha,
                            obscureText: true,
                            decoration: const InputDecoration(
                              hintText: 'Senha',
                              labelText: 'Senha',
                              suffixIcon: Icon(Icons.lock_outline),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                _validarCampos();
                              },
                              style: ElevatedButton.styleFrom(
                                primary: PaletaCores.corPrimaria,
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Text(
                                  _cadastroUsuario ? 'Cadastro' : 'Login',
                                  style: const TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              const Text(
                                'Login',
                              ),
                              Switch(
                                value: _cadastroUsuario,
                                onChanged: (bool value) {
                                  setState(() {
                                    _cadastroUsuario = value;
                                  });
                                },
                              ),
                              const Text(
                                'Cadastro',
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
