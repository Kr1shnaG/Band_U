import 'package:flutter/cupertino.dart';
import 'package:flutter_app/widgets/chats_page.dart';
import 'package:flutter_app/widgets/settings_page.dart';
import 'package:flutter_app/widgets/users_page.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int selectedIndex = 0;

  final List<Widget> _tabs = [
    const UsersPage(),
    const ChatsPage(),
    const SettingsPage(),
  ];

  final appRoutes = {
    '/home': (context) => const UsersPage(),
    '/chats': (context) => const ChatsPage(),
    '/settings': (context) => const SettingsPage(),
  };

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color.fromRGBO(10, 10, 10, 1),
      child: CupertinoTabScaffold(
          resizeToAvoidBottomInset: false,
          tabBar: CupertinoTabBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.layers_alt_fill),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.chat_bubble_2_fill),
                label: 'Chats',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.settings),
                label: 'Settings',
              ),
            ],
          ),
          tabBuilder: (BuildContext context, index) {
            return CupertinoTabView(
              routes: appRoutes,
              builder: (context) {
                return _tabs[index];
              },
            );
          }),
    );
  }
}
