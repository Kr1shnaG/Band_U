import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/models/message.dart';
import 'package:flutter_app/models/user.dart';
import 'package:flutter_app/services/utils.dart';
import 'package:flutter_app/widgets/message_widget.dart';

class ChatPage extends StatefulWidget {
  final UserModel userTo;
  final UserModel userFrom;
  const ChatPage({required this.userTo, required this.userFrom, Key? key}) : super(key: key);

  @override
  ChatPageState createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> {
  final _controller = TextEditingController();
  late String roomId;
  String message = "";

  @override
  void initState() {
    super.initState();
    var order = widget.userFrom.uid.compareTo(widget.userTo.uid);
    roomId = order < 0 ? widget.userFrom.uid + '_' + widget.userTo.uid : widget.userTo.uid + '_' + widget.userFrom.uid;
  }

  void unfocus() {
    FocusScope.of(context).unfocus();
  }

  void sendMessage() async {
    _controller.clear();

    final msgs = FirebaseFirestore.instance.collection('chats/$roomId/messages');
    final msg = Message(
        message: message, createdAt: DateTime.now(), toUserId: widget.userTo.uid, fromUserId: widget.userFrom.uid);
    await msgs.add(msg.toJson());
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          // heroTag: '${widget.userTo} Chat',
          middle: Text(
            '${widget.userTo.displayName}',
            style: const TextStyle(color: Colors.white),
          ),
          previousPageTitle: 'Matches',
          backgroundColor: const Color.fromRGBO(10, 10, 10, 1),
        ),
        // resizeToAvoidBottomInset: false,
        child: GestureDetector(
          onTap: unfocus,
          child: Column(
            children: [
              Expanded(
                  child: Container(
                      padding: const EdgeInsets.only(left: 16, right: 16),
                      child: StreamBuilder<List<Message>>(
                        stream: FirebaseFirestore.instance
                            .collection('chats/$roomId/messages')
                            .orderBy('createdAt', descending: true)
                            .snapshots()
                            .transform(Utils.transformer(Message.fromJson)),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Text('error ${snapshot.error}');
                          } else if (snapshot.hasData) {
                            final messages = snapshot.data!;
                            return messages.isEmpty
                                ? Flex(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    direction: Axis.vertical,
                                    children: const [
                                      Text(
                                        'Say Hi! 👋',
                                        style: TextStyle(fontSize: 18),
                                      )
                                    ],
                                  )
                                : ListView.builder(
                                    physics: const BouncingScrollPhysics(),
                                    reverse: true,
                                    itemCount: messages.length,
                                    itemBuilder: (context, index) {
                                      final message = messages[index];
                                      return MessageWidget(
                                        message: message,
                                        isMe: message.fromUserId == widget.userFrom.uid,
                                      );
                                    },
                                  );
                          } else {
                            return Container();
                            // return const Center(child: CircularProgressIndicator());
                          }
                        },
                      ))),
              Container(
                padding: const EdgeInsets.only(bottom: 24, top: 16, left: 16, right: 16),
                child: Row(
                  children: [
                    Expanded(
                        child: CupertinoTextField(
                      style: const TextStyle(color: Colors.black),
                      controller: _controller,
                      textCapitalization: TextCapitalization.sentences,
                      autocorrect: false,
                      clearButtonMode: OverlayVisibilityMode.always,
                      enableSuggestions: true,
                      padding: const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 10),
                      placeholder: 'Type something fun..',
                      placeholderStyle: TextStyle(color: Colors.grey.shade500),
                      decoration:
                          const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(20))),
                      cursorColor: const Color(0xff1ed760),
                      onChanged: (value) => setState(() {
                        message = value;
                      }),
                    )),
                    const SizedBox(
                      width: 10,
                    ),
                    GestureDetector(
                      onTap: message.trim().isEmpty ? null : sendMessage,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xff1ed760)),
                        child: const Icon(
                          Icons.send,
                          color: Colors.white,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
