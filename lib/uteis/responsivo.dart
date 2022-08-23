import 'package:flutter/material.dart';

class Responsivo extends StatelessWidget {
  const Responsivo({
    required this.mobile,
    this.tablet,
    required this.web,
    Key? key,
  }) : super(key: key);

  final Widget mobile;
  final Widget? tablet;
  final Widget web;

  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 800;
  }

  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= 800 &&
        MediaQuery.of(context).size.width < 1200;
  }

  static bool isWeb(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1200;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1200) {
          return web;
        } else if (constraints.maxWidth >= 800) {
          return tablet ?? web;
        } else {
          return mobile;
        }
      },
    );
  }
}
