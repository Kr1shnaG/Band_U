import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/services/storage.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late WebViewController controller;

  String _email = "";
  String _password = "";

  Future<void> _createUser() async {
    try {
      UserCredential userCredentials =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(email: _email, password: _password);
      print(userCredentials);
      FirebaseFirestore.instance
          .collection('users')
          .doc(userCredentials.user?.uid)
          .set({'uid': userCredentials.user?.uid});
    } on FirebaseAuthException catch (e) {
      print("Error: $e");
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> _loginUser() async {
    try {
      UserCredential userCredentials =
          await FirebaseAuth.instance.signInWithEmailAndPassword(email: _email, password: _password);

      //see if user has connected to spotify before, else delete all local data
      DocumentSnapshot snapshot =
          await FirebaseFirestore.instance.collection('users').doc(userCredentials.user?.uid).get();
      final data = snapshot.data() as Map<String, dynamic>;
      var token = data['token'];
      if (token == null || token == '') {
        print('Please connect to Spotify first.');
        SecureStorage.deleteToken();
        SecureStorage.deleteRefreshToken();
        SecureStorage.deleteLoggedInName();
        SecureStorage.deleteLoggedInImg();
      } else {
        print('Set Spotify Login data.');
        var refreshToken = data['refreshToken'];
        var displayName = data['displayName'];
        var img = data['img'];
        SecureStorage.setToken(token);
        SecureStorage.setRefreshToken(refreshToken);
        SecureStorage.setLoggedInName(displayName);
        SecureStorage.setLoggedInImg(img);
      }
    } on FirebaseAuthException catch (e) {
      print("Error: $e");
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Login'),
        backgroundColor: Color.fromRGBO(30, 215, 96, 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  children: [
                    CupertinoTextField(
                      style: const TextStyle(color: Colors.black),
                      onChanged: (value) {
                        _email = value;
                      },
                      decoration:
                          const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(20))),
                      textCapitalization: TextCapitalization.sentences,
                      autocorrect: false,
                      enableSuggestions: false,
                      padding: const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 10),
                      placeholder: 'Email',
                      placeholderStyle: TextStyle(color: Colors.grey.shade500),
                      cursorColor: const Color(0xff1ed760),
                    ),
                    const SizedBox(height: 10),
                    CupertinoTextField(
                      style: const TextStyle(color: Colors.black),
                      onChanged: (value) {
                        _password = value;
                      },
                      obscureText: true,
                      enableSuggestions: false,
                      autocorrect: false,
                      decoration:
                          const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(20))),
                      textCapitalization: TextCapitalization.sentences,
                      padding: const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 10),
                      placeholder: 'Password',
                      placeholderStyle: TextStyle(color: Colors.grey.shade500),
                      cursorColor: const Color(0xff1ed760),
                    )
                  ],
                )),
            Column(children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  child: const Text('Create Account'),
                  onPressed: _createUser,
                  style: ElevatedButton.styleFrom(primary: Colors.grey.shade900),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  child: const Text('Login'),
                  onPressed: _loginUser,
                  style: ElevatedButton.styleFrom(primary: const Color.fromRGBO(30, 215, 96, 1)),
                ),
              ),
            ]),
          ],
        )),
      ),
    );
  }
}
