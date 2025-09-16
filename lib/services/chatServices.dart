import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pl_project/models/msgModel.dart';

class ChatServices extends ChangeNotifier {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore fireStore = FirebaseFirestore.instance;

  Future<void> sendMessage(String? receiverId, String? msg,
      {List<String>? groupMembers, String? groupName}) async {
    try {
      final user = auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }
      
      final String uid = user.uid;
      final String uEmail = user.email ?? '';
      final Timestamp timestamp = Timestamp.now();

      MsgModel newMessage = MsgModel(
        senderId: uid,
        senderMail: uEmail,
        receiverId: receiverId,
        message: msg,
        timestamp: timestamp,
      );

      if (groupMembers != null && groupName != null) {
        DocumentReference groupDocRef = await fireStore.collection('chats').add({
          'type': "group",
          'name': groupName,
          'members': groupMembers,
          'lastMessage': newMessage.toMap(),
        });

        await groupDocRef.collection('messages').add(newMessage.toMap());
      } else {
        // Personalized chat
        List<String> ids = [uid, receiverId!];
        ids.sort();
        String chatRoomId = ids.join('_');

        await fireStore.collection('chats').doc(chatRoomId).set({
          'type': "pc",
          'members': ids,
          'lastMessage': newMessage.toMap(),
        });

        await fireStore
            .collection('chats')
            .doc(chatRoomId)
            .collection('messages')
            .add(newMessage.toMap());
      }
    } catch (e) {
      print('Error sending message: $e');
      throw Exception('Failed to send message: $e');
    }
  }

  Future<void> createGroup(String groupName, List<String> groupMembers) async {
    try {
      // Add the group information to the 'chats' collection
      DocumentReference groupDocRef = await fireStore.collection('chats').add({
        'type': "group",
        'name': groupName,
        'members': groupMembers,
      });

      print('Group created with ID: ${groupDocRef.id}');
    } catch (e) {
      print('Error creating group: $e');
      throw e;
    }
  }

  Future<void> sendMessageToGroup(String groupId, String message) async {
    try {
      final user = auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }
      
      final String uid = user.uid;
      final String uEmail = user.email ?? '';
      final Timestamp timestamp = Timestamp.now();
      MsgModel newMessage = MsgModel(
        senderId: uid,
        senderMail: uEmail,
        message: message,
        timestamp: timestamp,
      );

      await fireStore.collection('chats').doc(groupId).collection('messages').add(newMessage.toMap());
      await fireStore.collection('chats').doc(groupId).update({
        'lastMessage': newMessage.toMap(),
      });
      print('Message sent to group $groupId');
    } catch (e) {
      print('Error sending message to group: $e');
      throw Exception('Failed to send message to group: $e');
    }
  }


  Stream<QuerySnapshot> receiveMessages(String? uid, String receiverId, String type) {
    String chatRoomId = "";
    if (type == "group") {
      chatRoomId = receiverId;
    } else{
      List<String> ids = [uid!, receiverId];
      ids.sort();
      chatRoomId = ids.join("_");
    }

    print("chatRoomId: $chatRoomId");

    return fireStore
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  Stream<QuerySnapshot> getAllChats(String? uid) {
    return fireStore
        .collection('chats')
        .where('members', arrayContains: uid)
        .snapshots();
  }

  Future<DocumentSnapshot> getUserData(String userId) async {
    try {
      DocumentSnapshot userData = await fireStore.collection('users').doc(userId).get();
      return userData;
    } catch (e) {
      print('Error fetching user data: $e');
      throw e;
    }
  }
}