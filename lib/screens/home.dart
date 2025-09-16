import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:pl_project/services/chatServices.dart';
import '../utils/conts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late double? height;
  late double? width;
  final FirebaseAuth auth = FirebaseAuth.instance;

  String formatTimestamp(DateTime timestamp) {
    DateFormat formatter = DateFormat('hh:mm a');
    return formatter.format(timestamp);
  }

  @override
  Widget build(BuildContext context) {
    height = getHeight(context);
    width = getWidth(context);
    final user = auth.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('User not authenticated'),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome - ${user.email}'),
        centerTitle: true,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        tooltip: 'Create Group',
        onPressed: () {
          Navigator.pushNamed(context, 'Create Group');
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomAppBar(
        height: height! * 0.09,
        notchMargin: 7,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, 'UserList Screen');
                },
                child: Container(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.contact_page,
                        color: Colors.white,
                        size: height! * 0.032,
                      ),
                      Text(
                        "Contacts",
                        style: TextStyle(
                          fontSize: height! * 0.017,
                          color: Colors.white,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, 'Setting Screen');
                },
                child: Container(
                  alignment: Alignment.centerRight,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.settings,
                        color: Colors.white,
                        size: height! * 0.032,
                      ),
                      Text(
                        "Settings",
                        style: TextStyle(
                          fontSize: height! * 0.017,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: ChatServices().getAllChats(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Loader(color: Colors.amberAccent),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          if (snapshot.data!.size == 0) {
            return const Center(
              child: Text(
                "No Active Chats Found!\nStart Chatting with friends.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }
          List<DocumentSnapshot> chats = snapshot.data!.docs;

          return ListView.separated(
            itemCount: chats.length,
            separatorBuilder: (context, index) {
              return const Divider();
            },
            itemBuilder: (context, index) {
              Map<String, dynamic> chatsData =
                  chats[index].data()! as Map<String, dynamic>;
              Map<String, dynamic>? lastMessage = chatsData['lastMessage'];

              return chatsData["type"] == "group"
                  ? ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.group),
                      ),
                      title: Text(chatsData["name"]),
                      subtitle: Text(
                          lastMessage != null ? lastMessage["message"] : ""),
                      trailing: Text(lastMessage != null
                          ? formatTimestamp(lastMessage["timestamp"].toDate())
                          : ""),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          'Chat Screen',
                          arguments: {
                            "name": chatsData["name"],
                            "type": chatsData["type"],
                            "members": List<String>.from(chatsData["members"]),
                            "rid": chats[index].id,
                          },
                        );
                      },
                    )
                  : FutureBuilder<DocumentSnapshot>(
                      future: ChatServices().getUserData(chatsData['members']
                          .firstWhere((id) => id != user.uid)),
                      builder: (context, receiverSnapshot) {
                        if (receiverSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const ListTile(
                            leading: CircularProgressIndicator(),
                            title: Text('Loading...'),
                          );
                        }
                        var receiverName = receiverSnapshot.data!['name'];
                        return ListTile(
                          leading: CircleAvatar(
                            child: Text(receiverName[0].toUpperCase()),
                          ),
                          title: Text(receiverName),
                          subtitle: Text(lastMessage != null
                              ? lastMessage["message"]
                              : ""),
                          trailing: Text(lastMessage != null
                              ? formatTimestamp(
                                  lastMessage["timestamp"].toDate())
                              : ""),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              'Chat Screen',
                              arguments: {
                                "name": receiverName,
                                "type": chatsData["type"],
                                "rid": chatsData['members'].firstWhere(
                                    (id) => id != user.uid),
                              },
                            );
                          },
                        );
                      },
                    );
            },
          );
        },
      ),
    );
  }
}
