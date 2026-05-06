import 'package:flutter/material.dart';

import 'app_background.dart';
import 'app_drawer.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.showMenu = false,
    this.showBack = false,
    this.title,
  });

  final Widget body;
  final bool showMenu;
  final bool showBack;
  final Widget? title;

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        drawer: showMenu ? const AppDrawer() : null,
        appBar: (showMenu || showBack || title != null)
            ? AppBar(
                leading: showBack
                    ? IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.of(context).maybePop(),
                      )
                    : null,
                title: title,
              )
            : null,
        body: SafeArea(child: body),
      ),
    );
  }
}
