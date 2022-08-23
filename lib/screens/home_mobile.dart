import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whatsappweb/components/lista_contatos.dart';
import 'package:whatsappweb/components/lista_conversas.dart';

class HomeMobile extends StatefulWidget {
  const HomeMobile({Key? key}) : super(key: key);

  @override
  State<HomeMobile> createState() => _HomeMobileState();
}

class _HomeMobileState extends State<HomeMobile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('WhatsApp'),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.search),
            ),
            const SizedBox(
              width: 6,
            ),
            IconButton(
              onPressed: () async {
                await _auth.signOut();
                Navigator.pushReplacementNamed(context, '/');
              },
              icon: const Icon(Icons.logout),
            )
          ],
          bottom: const TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 2,
            labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            tabs: [
              Tab(
                text: 'Conversas',
              ),
              Tab(
                text: 'Contatos',
              ),
            ],
          ),
        ),
        body: const SafeArea(
          child: TabBarView(
            children: [
              ListaConversas(),
              ListaContatos(),
            ],
          ),
        ),
      ),
    );
  }
}
