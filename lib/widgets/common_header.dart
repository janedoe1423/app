import 'package:flutter/material.dart';

class CommonHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CommonHeader({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications),
          onPressed: () {
            // TODO: Implement notifications
          },
        ),
        IconButton(
          icon: const Icon(Icons.person),
          onPressed: () {
            // TODO: Implement profile
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight); // Set the preferred size
} 