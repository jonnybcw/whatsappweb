import 'package:flutter/material.dart';
import 'package:whatsappweb/screens/home_mobile.dart';
import 'package:whatsappweb/screens/home_web.dart';
import 'package:whatsappweb/uteis/responsivo.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Responsivo(
      mobile: HomeMobile(),
      web: HomeWeb(),
    );
  }
}
