import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);
  static const String id = 'chat_screen';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

final _firestore = FirebaseFirestore.instance;
User? loggedInUser;

class _ChatScreenState extends State<ChatScreen> {
  final _auth = FirebaseAuth.instance;
  final messageTextController = TextEditingController();

  String messageText = '';

  void getCurrentUser() async {
    try {
      if (_auth.currentUser != null) {
        loggedInUser = _auth.currentUser;
        print(loggedInUser?.email);
      }
    } catch (e) {
      print(e);
    }
  }

  void messageStream() async {
    await for (var snapshot in _firestore.collection('messages').snapshots()) {
      for (var message in snapshot.docs) {
        print(message.data());
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.light,
        ),
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: const Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const MessageStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      textInputAction: TextInputAction.newline,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      onChanged: (value) {
                        setState(() {
                          messageText = value;
                        });
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      //Implement send functionality.
                      if (messageText.isNotEmpty) {
                        _firestore.collection('messages').add({
                          'sender': loggedInUser?.email,
                          'text': messageText,
                          "timestamp": FieldValue.serverTimestamp(),
                        });
                        messageTextController.clear();
                        setState(() {
                          messageText = '';
                        });
                      }
                    },
                    icon: Icon(
                      Icons.send,
                      color: messageText.isNotEmpty
                          ? Colors.lightBlueAccent
                          : Colors.black12,
                      size: 35.0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageStream extends StatelessWidget {
  const MessageStream({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream:
          _firestore.collection('messages').orderBy('timestamp').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }
        final messages = snapshot.data?.docs;
        List<MessageBubble> messageBubbles = [];

        dynamic lastSender = "";

        for (var message in messages!) {
          final messageText = message.data()['text'];
          final sender = message.data()['sender'];

          final messageBubble = MessageBubble(
            sender: sender ?? '',
            text: messageText ?? '',
            isCurrentUser: (sender ?? false) == loggedInUser?.email,
            isSameUser: sender == lastSender,
          );
          messageBubbles.add(messageBubble);
          lastSender = sender;
        }

        // Reversing List order to shift last message to bottom of screen
        messageBubbles = List.from(messageBubbles.reversed);

        return Expanded(
          child: ListView(
            reverse: true,
            padding: const EdgeInsets.symmetric(
              horizontal: 10.0,
              vertical: 20.0,
            ),
            children: messageBubbles,
          ),
        );
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  MessageBubble({
    Key? key,
    required String sender,
    required String text,
    required bool isCurrentUser,
    required bool isSameUser,
  }) : super(key: key) {
    this.sender = sender;
    this.text = text;
    this.isCurrentUser = isCurrentUser;
    this.isSameUser = isSameUser;
    userName = setUser(sender);
  }

  late final String sender;
  late final String text;
  late final bool isCurrentUser;
  late final bool isSameUser;
  late final String userName;

  String setUser(String email) {
    String user = email.split('@').first;
    user = user[0].toUpperCase() + user.substring(1);
    return user;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        10.0,
        isSameUser ? 2.0 : 18.0,
        10.0,
        2.0,
      ),
      child: Column(
        crossAxisAlignment:
            isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Material(
            color: isCurrentUser ? Colors.lightBlueAccent : Colors.white,
            elevation: 5.0,
            borderRadius: isCurrentUser
                ? kMessageBubbleBorderRadius.copyWith(
                    topRight: const Radius.circular(0.0))
                : kMessageBubbleBorderRadius.copyWith(
                    topLeft: const Radius.circular(0.0)),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isSameUser)
                    Text(
                      userName,
                      style: TextStyle(
                        color: isCurrentUser ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 16.0,
                      ),
                    ),
                  Text(
                    text,
                    style: TextStyle(
                      color: isCurrentUser ? Colors.white : Colors.black54,
                      fontSize: 15.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
