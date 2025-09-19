import 'package:flutter/material.dart';
import 'package:notekey_app/features/themes/colors.dart';
import 'basic_topbar.dart';
import 'hamburger/hamburger_drawer.dart';

class BaseScaffold extends StatelessWidget {
  final String appBarTitle;
  final Widget body;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final bool showBack;

  const BaseScaffold({
    super.key,
    required this.appBarTitle,
    required this.body,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.showBack = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.hellbeige,
      endDrawer: const HamburgerDrawer(), // rechter Drawer
      appBar: BasicTopBar(
        title: appBarTitle,
        showBack: showBack,
        showMenu: true,
      ),
      body: body,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
    );
  }
}
