import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/models/user.dart';
import 'package:flutter_app/widgets/chat_page.dart';
import 'package:flutter_app/widgets/list_item.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage({Key? key}) : super(key: key);

  @override
  ChatsPageState createState() => ChatsPageState();
}

class ChatsPageState extends State<ChatsPage> {
  final Stream<QuerySnapshot> _usersStream =
      FirebaseFirestore.instance.collection('users').snapshots();
  final FirebaseAuth auth = FirebaseAuth.instance;
  String? loggedIn;
  late UserModel me;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _usersStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return Container();
        } else if (snapshot.data == null || snapshot.data?.docs == null) {
          return Container();
        } else {
          loggedIn = auth.currentUser?.uid;
          final List<UserModel> u = snapshot.data!.docs
              .map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final String uid = data.containsKey('uid') ? data['uid'] : '';
                // final GeoPoint location = data.containsKey('location') ? data['location'] : null;
                final String token =
                    data.containsKey('token') ? data['token'] : '';
                final String refreshToken = data.containsKey('refreshToken')
                    ? data['refreshToken']
                    : '';
                final List<String> alreadySeen = data.containsKey('alreadySeen')
                    ? List<String>.from(data['alreadySeen'])
                    : [];
                final List<String> liked = data.containsKey('liked')
                    ? List<String>.from(data['liked'])
                    : [];
                final List<String> matched = data.containsKey('matched')
                    ? List<String>.from(data['matched'])
                    : [];
                final String displayName = data.containsKey('displayName')
                    ? data['displayName']
                    : 'GKC';
                final String img = data.containsKey('img') ? data['img'] : '';
                UserModel user = UserModel(
                  uid: uid,
                  location: GeoPoint(12.4, 13.8),
                  token: token,
                  refreshToken: refreshToken,
                  alreadySeen: alreadySeen,
                  liked: liked,
                  matched: matched,
                  displayName: displayName,
                  img: img,
                );
                if (uid == loggedIn) me = user;
                return user;
              })
              .toList()
              .where((user) => me.matched!.contains(user.uid))
              .toList();
          return u.isEmpty
              ? const Center(
                  child: Text('Get to swiping!'),
                )
              : CustomScrollView(slivers: [
                  const CupertinoSliverNavigationBar(
                    transitionBetweenRoutes: true,
                    largeTitle: Text(
                      "Chats",
                    ),
                    backgroundColor: Color.fromRGBO(10, 10, 10, 1),
                    // stretch: true,
                  ),
                  CupertinoSliverRefreshControl(
                    onRefresh: () async {
                      _usersStream;
                    },
                  ),
                  _buildChats(u),
                ]);
        }
      },
    );
  }

  Widget _buildChats(List<UserModel> users) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, i) {
        final index = i ~/ 2;
        return _buildChatRow(users[index], index);
      }, childCount: users.length),
    );
  }

  Widget _buildChatRow(UserModel user, int index) {
    var name = user.displayName ?? '';
    var avatar = user.img ?? '';
    return GestureDetector(
        onTap: () {
          Navigator.of(context, rootNavigator: true).push(CupertinoPageRoute(
            builder: (context) => ChatPage(userTo: user, userFrom: me),
          ));
        },
        child: ListItem(
            img: avatar != ""
                ? CircleAvatar(
                    maxRadius: 28,
                    backgroundImage: NetworkImage(avatar),
                  )
                : const CircleAvatar(backgroundColor: Colors.grey, radius: 28),
            title: Text(
              name,
              style: const TextStyle(fontSize: 18),
            ),
            icon: Icon(
              CupertinoIcons.chevron_forward,
              color: Colors.grey.shade500,
            )));
  }
}

class UsersNotifier extends ValueNotifier<List<UserModel>?> {
  UsersNotifier(List<UserModel>? value) : super(value);

  void changeData(List<UserModel> newUsers) {
    value = newUsers;
    notifyListeners();
  }
}
