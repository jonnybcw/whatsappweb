import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:whatsappweb/providers/conversa_provider.dart';
import 'package:whatsappweb/rotas.dart';
import 'package:whatsappweb/uteis/paleta_cores.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';

final ThemeData temaPadrao = ThemeData(
  primaryColor: PaletaCores.corPrimaria,
  colorScheme:
      ColorScheme.fromSwatch().copyWith(secondary: PaletaCores.corDestaque),
  appBarTheme: const AppBarTheme(
    backgroundColor: PaletaCores.corPrimaria,
  ),
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  User? usuarioLogado = FirebaseAuth.instance.currentUser;
  String urlInicial = '/';
  if (usuarioLogado != null) {
    urlInicial = '/home';
  }

  runApp(
    ChangeNotifierProvider(
      create: (context) {
        return ConversaProvider();
      },
      child: MaterialApp(
        title: 'WhatsApp Web',
        initialRoute: urlInicial,
        onGenerateRoute: Rotas.gerarRotas,
        debugShowCheckedModeBanner: false,
        theme: temaPadrao,
      ),
    ),
  );
}
