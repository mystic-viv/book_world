import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  
  const CustomAppBar({super.key, this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: Padding(
        padding: const EdgeInsets.only(left: 10.0),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.orange),
          onPressed: () => Get.back(),
        ),
      ),
      title: title != null ? Text(
        title!,
        style: const TextStyle(
          color: Colors.orange,
          fontFamily: 'Sanchez',
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ) : null,
      backgroundColor: Colors.transparent,
      scrolledUnderElevation: 0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}