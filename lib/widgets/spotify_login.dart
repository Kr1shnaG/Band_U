import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/services/storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as https;

var scopes = [
  // 'ugc-image-upload',
  // 'playlist-modify-private',
  // 'playlist-read-private',
  // 'playlist-modify-public',
  // 'playlist-read-collaborative',
  // 'user-read-private',
  'user-read-email',
  // 'user-read-playback-state',
  // 'user-modify-playback-state',
  // 'user-read-currently-playing',
  // 'user-library-modify',
  // 'user-library-read',
  // 'user-read-playback-position',
  'user-read-recently-played',
  'user-top-read',
  // 'app-remote-control',
  // 'streaming',
  // 'user-follow-modify',
  // 'user-follow-read',
];

var url = dotenv.env['NODE_ENV'] == 'development'
    ? dotenv.env['DEV_URL']
    : dotenv.env['PROD_URL'];

var uri = Uri.https("accounts.spotify.com", "/authorize", {
  "client_id":  dotenv.env['CLIENT_ID'],
  "response_type": "code",
  "redirect_uri": "http://localhost:8888/callback",
  "scope": scopes.join('%20'),
  "state": getRandomString(16),
});
const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
Random _rnd = Random();

String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
    length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

// ignore: must_be_immutable
class SpotifyLogin extends StatelessWidget {
  final FirebaseAuth auth = FirebaseAuth.instance;
  late WebViewController controller;

  SpotifyLogin({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(
          middle: Text('Spotify Login'),
          backgroundColor: Color.fromRGBO(30, 215, 96, 1),
        ),
        child: WebView(
          userAgent: 'random',
          initialUrl: uri.toString(),
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (controller) async {
            this.controller = controller;
            await controller.currentUrl();
          },
          navigationDelegate: (request) async {
            var url = dotenv.env['NODE_ENV'] == 'development'
                ? dotenv.env['DEV_URL']
                : dotenv.env['PROD_URL'];
            if (request.url.startsWith('http://localhost:8888/callback')) {

              String credentials = (dotenv.env['CLIENT_ID'] ?? '') +
                  ':' +
                  (dotenv.env['CLIENT_SECRET'] ?? '');
              Codec<String, String> stringToBase64Url = utf8.fuse(base64Url);

              var tokensAPI = await https.post(
                  Uri.parse('https://accounts.spotify.com/api/token'),
                  body: {
                    'code': request.url.split('&').first.split('code=').last,
                    'redirect_uri': 'http://localhost:8888/callback',
                    'grant_type': 'authorization_code'
                  },
                  headers: {
                    'Authorization':
                        'Basic ${stringToBase64Url.encode(credentials)}',
                  }).then((res) async {
                var token = json.decode(res.body)['access_token'];
                var refreshToken = json.decode(res.body)['refresh_token'];
                if (token.isNotEmpty) {
                  final User? user = auth.currentUser;
                  final String? uid = user?.uid;
                  var me = await https.get(Uri.parse('$url/me'), headers: {
                    'Content-Type': 'application/json',
                    'Accept': 'application/json',
                    'Authorization': 'Bearer $token',
                  }).then((res) {
                    print(res.body);
                    return jsonDecode(res.body);
                  }).then((json) => json);
                  var name = me['display_name'];
                  var imgUrl = '';
                  Future.wait(<Future>[
                    SecureStorage.setLoggedInName(name ?? ''),
                    SecureStorage.setLoggedInImg(imgUrl ?? ''),
                    SecureStorage.setToken(token ?? ''),
                    SecureStorage.setRefreshToken(refreshToken ?? '')
                  ]).then((value) async => {
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(uid)
                            .set({
                          'token': token,
                          'refreshToken': refreshToken,
                          'displayName': name,
                          'img': imgUrl,
                        }, SetOptions(merge: true)),
                        Navigator.pushReplacementNamed(context, "/")
                      });
                }
              });
            }
            return NavigationDecision.navigate;
          },
        ));
  }
}
