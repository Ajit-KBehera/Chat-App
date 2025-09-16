import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../services/chatServices.dart';
import '../utils/conts.dart';

class CreateGroup extends StatefulWidget {
  const CreateGroup({super.key});

  @override
  State<CreateGroup> createState() => _CreateGroupState();
}

class _CreateGroupState extends State<CreateGroup> {
  TextEditingController grpName = TextEditingController();
  final FirebaseAuth auth = FirebaseAuth.instance;
  late double? height;
  late double? width;
  bool showLoader = false;
  List userList = [];
  Set<String> selectedUserIds = {};

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  void fetchData() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('users').get();
      setState(() {
        userList = querySnapshot.docs.map((e) => e.data()).toList();
      });
    } catch (e) {
      print('Error fetching users: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load users: $e')),
      );
    }
  }

  void toggleUserSelection(String userId) {
    setState(() {
      if (selectedUserIds.contains(userId)) {
        selectedUserIds.remove(userId);
      } else {
        selectedUserIds.add(userId);
      }
    });
  }

  void createGroup() async {
    try {
      setState(() {
        showLoader = true;
      });
      String groupName = grpName.text.trim();
      final user = auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }
      selectedUserIds.add(user.uid);
      await ChatServices().createGroup(groupName, selectedUserIds.toList());
      grpName.clear();
      selectedUserIds.clear();
      Navigator.of(context).pop();
    } catch (e) {
      print('Error creating group: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create group: $e')),
      );
    } finally {
      setState(() {
        showLoader = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    height = getHeight(context);
    width = getWidth(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Create Group",
          style: TextStyle(),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TextField(
            controller: grpName,
            decoration: const InputDecoration(
                // border: OutlineInputBorder(),
                label: Text('Group Name'),
                suffixIcon: Icon(Icons.emoji_emotions_outlined),
                hintText: 'Enter Group Name'),
          ).paddingOnly(top: 20,bottom: 20),
          Container(
            alignment: Alignment.centerLeft,
            child: const Text("Select members to add them in the group"),
          ),
          Expanded(
            child: ListView.separated(
                itemBuilder: (context, index) {
                  var user = userList[index];
                  final currentUser = auth.currentUser;
                  if (currentUser != null && user['email'] == currentUser.email) {
                    return const SizedBox();
                  }
                  return ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(user['name']),
                    onTap: (){
                      toggleUserSelection(user['uid']);
                    },
                    trailing: selectedUserIds.contains(user['uid']) ? const Icon(Icons.check) : null
                  );
                },
                separatorBuilder: (context, index) {
                  var user = userList[index];
                  final currentUser = auth.currentUser;
                  if (currentUser != null && user['email'] == currentUser.email) {
                    return const SizedBox();
                  }
                  return const Divider();
                },
                itemCount: userList.length),
          ),
          SizedBox(
            width: height! * 0.4,
            child: ElevatedButton(
              style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
              onPressed: () {
                if(!grpName.text.isEmptyOrNull && selectedUserIds.isNotEmpty) {
                  createGroup();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a group name and select at least one member'),
                    ),
                  );
                }
              },
              child: const Text('Create Group'),
            ),
          ).paddingBottom(20),
        ],
      ).paddingSymmetric(horizontal: 20),
    );
  }
}
