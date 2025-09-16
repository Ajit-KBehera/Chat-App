import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:pl_project/services/chatServices.dart';
import '../utils/conts.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late double? height;
  late double? width;
  final TextEditingController msgController = TextEditingController();
  final ChatServices chatServices = ChatServices();
  final FirebaseAuth auth = FirebaseAuth.instance;

  void sendMessage(rid, msg) async {
    try {
      await chatServices.sendMessage(rid, msg);
      msgController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: $e')),
      );
    }
  }

  void sendGroupMessage(id, msg) async {
    try {
      await chatServices.sendMessageToGroup(id, msg);
      msgController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send group message: $e')),
      );
    }
  }

  String formatTimestamp(DateTime timestamp) {
    DateFormat formatter = DateFormat('hh:mm a');
    return formatter.format(timestamp);
  }

  @override
  Widget build(BuildContext context) {
    height = getHeight(context);
    width = getWidth(context);
    Map<String, dynamic>? args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    return Stack(
      children: [
        Opacity(
          opacity: 0.9,
          child: Image.asset(
            "assets/bg.jpg",
            scale: 3.0,
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.cover,
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text(args?['name']),
          ),
          body: Column(
            children: [
              Expanded(child: msgList(args!['rid'], args['type'])),
              Container(
                padding: const EdgeInsets.only(
                    top: 15, left: 15, right: 15, bottom: 10),
                height: height! * 0.1,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  // border: Border(top: BorderSide(color: Colors.grey, width: 1)),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15.0),
                    topRight: Radius.circular(15.0),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: msgController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          hintText: 'Enter your message',
                        ),
                      ),
                    ),
                    FloatingActionButton(
                      onPressed: () {
                        if (msgController.text.isNotEmpty) {
                          args['type'] == "group"
                              ? sendGroupMessage(
                                  args['rid'], msgController.text)
                              : sendMessage(args['rid'], msgController.text);
                        }
                      },
                      child: const Icon(Icons.send),
                    ).paddingLeft(12)
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget msgList(rid, type) {
    final user = auth.currentUser;
    if (user == null) {
      return const Center(
        child: Text('User not authenticated'),
      );
    }
    
    return StreamBuilder(
      stream: chatServices.receiveMessages(user.uid, rid, type),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Loader(color: Colors.amberAccent),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(8),
          children: snapshot.data!.docs.map((e) {
            Map<String, dynamic> data = e.data() as Map<String, dynamic>;

            bool isCurrentUser = data['senderId'] == user.uid;

            return buildMessageBubble(
                isCurrentUser, data['message'], data['timestamp']);
          }).toList(),
        );
      },
    );
  }

  Widget buildMessageBubble(
    bool isCurrentUser,
    String message,
    Timestamp timestamp,
  ) {
    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        decoration: BoxDecoration(
          color: isCurrentUser ? Colors.blue[200] : Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: message,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
              const TextSpan(
                text: "   ",
              ),
              TextSpan(
                text: formatTimestamp(timestamp.toDate()),
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
