import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekey_app/features/themes/colors.dart';

class BasicTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBack;
  final bool showMenu;
  final EdgeInsets titlePadding;

  const BasicTopBar({
    super.key,
    required this.title,
    this.showBack = false,
    this.showMenu = false,
    this.titlePadding = const EdgeInsets.only(top: 0),
  });

  // höhe und co der toolbar
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.dunkelbraun,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Material(
        color: AppColors.dunkelbraun,
        child: SafeArea(
          top: true,
          bottom: false,
          child: SizedBox(
            height: kToolbarHeight,
            child: Stack(
              children: [
                if (showBack)
                  Positioned(
                    left: 8,
                    top: 0,
                    bottom: 0,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new,
                          color: AppColors.hellbeige),
                      onPressed: () => Navigator.of(context).maybePop(),
                      tooltip: 'Zurück',
                    ),
                  ),
                Center(
                  child: Padding(
                    padding: titlePadding,
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.hellbeige,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                if (showMenu)
                  Positioned(
                    right: 8,
                    top: 0,
                    bottom: 0,
                    child: IconButton(
                      icon: const Icon(Icons.menu_rounded,
                          color: AppColors.hellbeige),
                      tooltip: 'Menü',
                      onPressed: () {
                        final scaffold = Scaffold.maybeOf(context);
                        if (scaffold?.hasEndDrawer ?? false) {
                          scaffold!.openEndDrawer();
                        }
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
