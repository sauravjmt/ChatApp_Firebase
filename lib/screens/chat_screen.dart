import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

final fireStore = FirebaseFirestore.instance;
User loggedInUser;

class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final textEditingController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  String messageText;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
        print(loggedInUser.email);
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessageStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: textEditingController,
                      onChanged: (value) {
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      //Implement send functionality.
                      //messageText + userLoggedIn

                      textEditingController.clear();

                      fireStore.collection("messages").add(
                          {"text": messageText, "sender": loggedInUser.email});
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
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
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: fireStore.collection('messages').snapshots(),
      builder: (context, snapshots) {
        if (!snapshots.hasData) {
          return Center(
              child: CircularProgressIndicator(
            backgroundColor: Colors.lightBlueAccent,
          ));
        }
        final messages = snapshots.data.docs.reversed;
        List<MessageBubble> messagesBubbles = [];
        for (var message in messages) {
          final messageMap = message.data();
          final messageText = messageMap['text'] ?? 'No Message';
          final messageSender = messageMap['sender'];

          final currentSender = loggedInUser.email;

          final messageBubble = MessageBubble(
            text: messageText,
            sender: messageSender,
            isMe: currentSender == messageSender,
          );
          messagesBubbles.add(messageBubble);
        }

        return Expanded(
          child: ListView(
            reverse: true,
            children: messagesBubbles,
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
          ),
        );
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  MessageBubble({this.text, this.sender, this.isMe});

  final String text;
  final String sender;
  final bool isMe;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            sender,
            style: TextStyle(fontSize: 10.0, color: Colors.black54),
          ),
          Material(
              borderRadius: isMe
                  ? BorderRadius.only(
                      topLeft: Radius.circular(30.0),
                      bottomLeft: Radius.circular(30.0),
                      bottomRight: Radius.circular(30.0))
                  : BorderRadius.only(
                      topRight: Radius.circular(30.0),
                      bottomLeft: Radius.circular(30.0),
                      bottomRight: Radius.circular(30.0)),
              elevation: 5.0,
              color: isMe ? Colors.lightBlueAccent : Colors.white,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                child: Column(
                  children: [
                    Text(
                      text,
                      style: TextStyle(
                          color: isMe ? Colors.white : Colors.black54,
                          fontSize: 15.0),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      text,
                      style: TextStyle(
                          color: isMe ? Colors.white : Colors.black54,
                          fontSize: 15.0),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
