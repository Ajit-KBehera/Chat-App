import 'package:cloud_firestore/cloud_firestore.dart';

class MsgModel {
  final String senderId;
  final String senderMail;
  final String? receiverId;
  final String? message;
  final Timestamp timestamp;

  MsgModel({
    required this.senderId,
    required this.senderMail,
    this.receiverId,
    this.message,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId' : senderId,
      'senderMail' : senderMail,
      'receiverId' : receiverId,
      'message' : message,
      'timestamp' : timestamp,
    };
  }
}
