import 'package:flutter/material.dart';

class ListItem extends StatelessWidget {
  final Widget title;
  final Widget? subtitle;
  final Widget? img;
  final Icon? icon;

  const ListItem({required this.title, this.img, this.subtitle, this.icon, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Container(
        height: 72,
        color: Colors.transparent,
        child: Row(children: [
          if (img != null) ...[
            img!,
            const SizedBox(
              width: 16,
            )
          ],
          Expanded(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              title,
              if (subtitle != null) ...[
                const SizedBox(
                  height: 4,
                ),
                subtitle!
              ]
            ],
          )),
          if (icon != null) icon!
        ]),
      ),
    );
  }
}
