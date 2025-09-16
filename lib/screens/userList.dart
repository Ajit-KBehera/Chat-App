import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class UserList extends StatefulWidget {
  const UserList({super.key});

  @override
  State<UserList> createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  final FirebaseAuth auth = FirebaseAuth.instance;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "User List",
          style: TextStyle(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search...",
                hintStyle: TextStyle(color: Colors.grey.shade600),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey.shade600,
                  size: 20,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: EdgeInsets.all(8),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Colors.grey.shade100)),
              ),
            ),
          ),
          Expanded(child: userList()),
        ],
      ),
    );
  }

  Widget userList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
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

        List<DocumentSnapshot> users = snapshot.data!.docs;

        return ListView.separated(
          itemCount: users.length,
          separatorBuilder: (context, index) {
            Map<String, dynamic> userData =
                users[index].data()! as Map<String, dynamic>;
            String userEmail = userData['email'];
            final currentUser = auth.currentUser;
            if (currentUser != null && userEmail == currentUser.email) {
              return const SizedBox();
            } else {
              return const Divider();
            }
          },
          itemBuilder: (context, index) {
            Map<String, dynamic> userData =
                users[index].data()! as Map<String, dynamic>;
            String userName = userData['name'];
            String userEmail = userData['email'];
            final currentUser = auth.currentUser;
            if (currentUser != null && userEmail == currentUser.email) {
              return const SizedBox();
            }
            return ListTile(
              leading: CircleAvatar(
                child: Text(userName.substring(0, 1).toUpperCase()),
              ),
              title: Text(userName),
              subtitle: Text(userEmail),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  'Chat Screen',
                  arguments: {
                    "name": userName,
                    "type": "pc",
                    "rid": userData['uid'],
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
