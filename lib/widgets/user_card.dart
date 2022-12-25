import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide UserModel;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/models/user.dart';
import 'package:flutter_app/widgets/top_artists_list.dart';
import 'package:flutter_app/widgets/top_tracks_list.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class UserCard extends StatefulWidget {
  final VoidCallback onDislike;
  final VoidCallback onLike;
  final UserModel me;
  final UserModel user;

  const UserCard({Key? key, required this.onDislike, required this.onLike, required this.me, required this.user})
      : super(key: key);

  @override
  UserCardState createState() => UserCardState();
}

class UserCardState extends State<UserCard> {
  String? _initial;
  int? segmentedControlGroupValue = 0;
  final FirebaseAuth auth = FirebaseAuth.instance;
  late String? distance;

  void dislike() async {
    setState(() {
      _initial = "dislike";
    });
    String? loggedIn = auth.currentUser?.uid;
    if (loggedIn == null) return;
    FirebaseFirestore.instance.collection('users').doc(loggedIn).set({
      'alreadySeen': FieldValue.arrayUnion([widget.user.uid])
    }, SetOptions(merge: true));
    widget.onDislike();
  }

  void like() async {
    setState(() {
      _initial = "like";
    });
    String? loggedIn = auth.currentUser?.uid;
    if (loggedIn == null) return;
    var match = widget.user.liked!.contains(loggedIn);
    FirebaseFirestore.instance.collection('users').doc(loggedIn).set({
      'liked': FieldValue.arrayUnion([widget.user.uid]),
      'matched': match ? FieldValue.arrayUnion([widget.user.uid]) : []
    }, SetOptions(merge: true));
    FirebaseFirestore.instance.collection('users').doc(widget.user.uid).set({
      'matched': match ? FieldValue.arrayUnion([loggedIn]) : []
    }, SetOptions(merge: true));
    widget.onLike();
    if (match) {
      openDialog();
    }
  }

  void close(BuildContext c) {
    Navigator.pop(c);
  }

  Future openDialog() => showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
            title: const Text("MATCHED!"),
            content: Text("You and ${widget.user.displayName} seem to have a similar taste in music."),
            actions: [CupertinoDialogAction(onPressed: () => close(context), child: const Text("Yay"))],
          ));

  @override
  void initState() {
    super.initState();
    if (widget.user.location != null && widget.me.location != null) {
      const Distance d = Distance();
      final double meter = d.as(
          LengthUnit.Meter,
          LatLng(widget.user.location!.latitude, widget.user.location!.longitude),
          LatLng(widget.me.location!.latitude, widget.me.location!.longitude));
      distance = (meter / 1000).toStringAsFixed(1) + "km";
    }
  }

  @override
  Widget build(BuildContext context) {
            return AnimatedOpacity(
              opacity: _initial == null ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: AnimatedContainer(
                  transform: _initial == null
                      ? Matrix4.identity()
                      : _initial == "like"
                          ? Matrix4.rotationZ(0.30)
                          : Matrix4.rotationZ(-0.30),
                  transformAlignment: Alignment.bottomCenter,
                  color: const Color.fromRGBO(10, 10, 10, 1),
                  duration: const Duration(milliseconds: 200),
                  child: Column(children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                      child: widget.user.img != null && widget.user.img != ""
                          ? CircleAvatar(
                              backgroundImage: NetworkImage(widget.user.img!),
                              radius: 32,
                            )
                          : const CircleAvatar(backgroundColor: Colors.grey, radius: 32),
                    ),
                    Text(
                      widget.user.displayName != null ? widget.user.displayName! : '...',
                      style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: distance != null
                          ? Text(
                              distance!,
                              style: const TextStyle(fontSize: 12.0),
                            )
                          : Container(),
                    ),
                    Padding(
                        padding: const EdgeInsets.only(top: 20, bottom: 20),
                        child: CupertinoSlidingSegmentedControl<int>(
                          groupValue: segmentedControlGroupValue,
                          children: const <int, Widget>{
                            0: Text('4 Weeks'),
                            1: Text('6 Months'),
                            2: Text('All Time'),
                          },
                          onValueChanged: (i) {
                            setState(() {
                              segmentedControlGroupValue = i;
                            });
                          },
                        )),
                    Flexible(
                      child: Column(
                        children: [
                          Expanded(
                              child: ListView(
                            cacheExtent: 1000,
                            children: [
                              <Widget>[
                                TopTracksList(
                                  timeRange: 'short_term',
                                  user: widget.user,
                                ),
                                TopTracksList(
                                  timeRange: 'medium_term',
                                  user: widget.user,
                                ),
                                TopTracksList(
                                  timeRange: 'long_term',
                                  user: widget.user,
                                )
                              ].elementAt(segmentedControlGroupValue ?? 0),
                              <Widget>[
                                TopArtistsList(
                                  timeRange: 'short_term',
                                  user: widget.user,
                                ),
                                TopArtistsList(
                                  timeRange: 'medium_term',
                                  user: widget.user,
                                ),
                                TopArtistsList(
                                  timeRange: 'long_term',
                                  user: widget.user,
                                )
                              ].elementAt(segmentedControlGroupValue ?? 0),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16.0),
                                  color: Colors.grey[700],
                                ),
                                margin: const EdgeInsets.all(20),
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  children: [
                                    const Padding(
                                        padding: EdgeInsets.only(bottom: 20),
                                        child: Text('Like for a chance to chat!')),
                                    Padding(
                                      padding: const EdgeInsets.all(0),
                                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                                        ElevatedButton(
                                          onPressed: dislike,
                                          child: const Icon(
                                            Icons.close,
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            shape: const CircleBorder(),
                                            padding: const EdgeInsets.all(20),
                                            primary: Colors.white,
                                            onPrimary: Colors.black,
                                          ),
                                        ),
                                        ElevatedButton(
                                          onPressed: like,
                                          child: const Icon(
                                            Icons.favorite,
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            foregroundColor: Colors.green, backgroundColor: Colors.white, shape: const CircleBorder(),
                                            padding: const EdgeInsets.all(20),
                                          ),
                                        ),
                                      ]),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ))
                        ],
                      ),
                    ),
                  ])),
            );
  }
}
