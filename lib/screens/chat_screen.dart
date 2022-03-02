import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../constaint.dart';

User? currentUser = FirebaseAuth.instance.currentUser;

class ChatScreen extends StatefulWidget {
  static String routeName = '/chat';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageTextController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final Stream<QuerySnapshot> _messagesStream =
      FirebaseFirestore.instance.collection('messages').snapshots();
  String _message = '';

  Future<void> _addMessage(String sender, String message) async {
    _firestore.collection('messages').add({'sender': sender, 'text': message});
  }

  String _getCurrentUser() {
    final user = _auth.currentUser;

    return user?.email ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                _auth.signOut();
                Navigator.of(context).pop();
              }),
        ],
        title: const Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessagesStream(messagesStream: _messagesStream),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _messageTextController,
                      onChanged: (value) {
                        _message = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      _messageTextController.clear();
                      _addMessage(_getCurrentUser(), _message);
                    },
                    child: const Text(
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

class MessagesStream extends StatelessWidget {
  const MessagesStream({
    Key? key,
    required Stream<QuerySnapshot<Object?>> messagesStream,
  })  : _messagesStream = messagesStream,
        super(key: key);

  final Stream<QuerySnapshot<Object?>> _messagesStream;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _messagesStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Something went wrong');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return Expanded(
          child: ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;
              return ChatBubble(
                  data: data, isMe: data['sender'] == currentUser?.email);
            }).toList(),
          ),
        );
      },
    );
  }
}

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    Key? key,
    required this.data,
    required this.isMe,
  }) : super(key: key);

  final Map<String, dynamic> data;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('${data['sender']}'),
          Material(
            borderRadius: BorderRadius.circular(30.0),
            elevation: 5.0,
            color: Theme.of(context).primaryColor,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Text(
                '${data['text']}',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
