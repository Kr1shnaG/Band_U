import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/services/storage.dart';
import 'package:flutter_app/widgets/spotify_login.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  var img = 'mhdvkasdv';
  var name = 'Rohan';

  void logout() async {
    // await SecureStorage.deleteToken();
    // var url = dotenv.env['NODE_ENV'] == 'development'
    //     ? dotenv.env['DEV_URL']
    //     : dotenv.env['PROD_URL'];
    // await http.get(Uri.parse('$url/logout'));
    FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, "/");
  }

  void connectSpotify() {
    Navigator.of(context, rootNavigator: true)
        .push(PageRouteBuilder(pageBuilder: (_, __, ___) => SpotifyLogin()));
  }

  void disconnectSpotify() {
    // print('disconnected yippi');
    SecureStorage.deleteToken();
    SecureStorage.deleteRefreshToken();
    SecureStorage.deleteLoggedInName();
    SecureStorage.deleteLoggedInImg();
    setState(() => {img = '', name = 'Rohan'});
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        child: CustomScrollView(slivers: [
      const CupertinoSliverNavigationBar(
        largeTitle: Text(
          "Settings",
        ),
        backgroundColor: Color.fromRGBO(10, 10, 10, 1),
        // stretch: true,
      ),
      SliverToBoxAdapter(
        child: Container(
          child: Column(
            children: [
              // Text('Logged in user: ${auth.currentUser?.uid}'),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    FutureBuilder<String?>(
                        future: Future.delayed(const Duration(seconds: 1)),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            print(snapshot.error.toString());
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          } else if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircleAvatar(
                              radius: 28,
                              backgroundColor: Colors.grey,
                            );
                          } else {
                            if (snapshot.data == null) {
                              return const CircleAvatar(
                                radius: 28,
                                backgroundColor: Colors.grey,
                              );
                            } else {
                              return CircleAvatar(
                                radius: 28,
                                backgroundImage: NetworkImage(snapshot.data!),
                              );
                            }
                          }
                        }),
                    FutureBuilder<String?>(
                        future: Future.delayed(const Duration(seconds: 1)),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            print(snapshot.error.toString());
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          } else if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text(
                                '...',
                                style: TextStyle(fontSize: 18),
                              ),
                            );
                          } else {
                            if (snapshot.data == null) {
                              return const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text(
                                  '',
                                  style: TextStyle(fontSize: 18),
                                ),
                              );
                            } else {
                              return Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  snapshot.data!,
                                  style: const TextStyle(fontSize: 18),
                                ),
                              );
                            }
                          }
                        }),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: FutureBuilder<String?>(
                      future: Future.delayed(const Duration(seconds: 1)),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        } else if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return ElevatedButton(
                            child: const Text('Connect Spotify'),
                            onPressed: null,
                            style: ElevatedButton.styleFrom(
                                primary: const Color.fromRGBO(30, 215, 96, 1)),
                          );
                        } else {
                          if (snapshot.data == null) {
                            return ElevatedButton(
                              child: const Text('Connect Spotify'),
                              onPressed: connectSpotify,
                              style: ElevatedButton.styleFrom(
                                  primary:
                                      const Color.fromRGBO(30, 215, 96, 1)),
                            );
                          } else {
                            return ElevatedButton(
                              child: const Text('Disconnect Spotify'),
                              onPressed: disconnectSpotify,
                              style: ElevatedButton.styleFrom(
                                  primary:
                                      const Color.fromRGBO(30, 215, 96, 1)),
                            );
                          }
                        }
                      }),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    child: const Text('Logout'),
                    onPressed: logout,
                    style:
                        ElevatedButton.styleFrom(primary: Colors.grey.shade900),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ]));
  }
}
