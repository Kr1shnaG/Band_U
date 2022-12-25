import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/material.dart';
import 'package:flutter_app/models/user.dart';
import 'package:flutter_app/widgets/user_card.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({Key? key}) : super(key: key);

  @override
  UsersPageState createState() => UsersPageState();
}

class UsersPageState extends State<UsersPage> {
  final UsersNotifier _usersList = UsersNotifier(null);
  final FirebaseAuth auth = FirebaseAuth.instance;
  String? loggedIn;
  late UserModel me;

  void getUsers() async {
    //set currently logged in user
    loggedIn = auth.currentUser?.uid;
    final List<UserModel> users = await FirebaseFirestore.instance
        .collection('users')
        .get()
        .then((QuerySnapshot querySnapshot) {
      return querySnapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final String uid = data.containsKey('uid') ? data['uid'] : '';
            GeoPoint? location = data['location'];
            final String token = data['token'] ?? '';
            final String refreshToken = data['refreshToken'] ?? '';
            final List<String> alreadySeen =
                List<String>.from(data['alreadySeen'] ?? []);
            final List<String> liked = List<String>.from(data['liked'] ?? []);
            final String displayName = data['displayName'] ?? '';
            final String img = data.containsKey('img') ? data['img'] : '';
            UserModel user = UserModel(
              uid: uid,
              location: location,
              token: token,
              refreshToken: refreshToken,
              alreadySeen: [],
              liked: liked,
              displayName: displayName,
              img: img,
            );
            if (uid == loggedIn) me = user;
            return user;
          })
          .where((user) => user.token != null && user.uid != loggedIn)
          .toList()
          .where((user) =>
              !me.alreadySeen!.contains(user.uid) &&
              !me.liked!.contains(user.uid))
          .toList();
    });
    _usersList.changeData(users);
  }

  void onLike() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _usersList.removeLast();
  }

  void onDislike() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _usersList.removeLast();
  }

  @override
  Widget build(BuildContext context) {
    getUsers();
    return ValueListenableBuilder<List<UserModel>?>(
      builder: (BuildContext context, List<UserModel>? users, Widget? child) {
        if (users == null) {
          return Container();
        } else {
          return Scaffold(
            body: SafeArea(
              child: users.isEmpty
                  ? const Center(
                      child: Text('No more users :('),
                    )
                  : loggedIn == null
                      ? const Center(
                          child: Text('Please log in'),
                        )
                      : Stack(
                          children: users
                              .map((user) => UserCard(
                                    me: me,
                                    user: user,
                                    onDislike: onDislike,
                                    onLike: onLike,
                                  ))
                              .toList()),
            ),
          );
        }
      },
      valueListenable: _usersList,
    );
  }
}

class UsersNotifier extends ValueNotifier<List<UserModel>?> {
  UsersNotifier(List<UserModel>? value) : super(value);

  void changeData(List<UserModel> newUsers) {
    value = newUsers;
    notifyListeners();
  }

  void removeLast() {
    if (value != null) {
      if (value!.isNotEmpty) {
        value!.removeAt(value!.length - 1);
        notifyListeners();
      }
    }
  }
}
