import 'package:cloud_firestore/cloud_firestore.dart';

class NoteModel {
  final String id;
  final String title;
  final String description;
  final bool isEncrypted;
  final Timestamp? createdOn;
  final String senderId;
  final String recipientId;
  final bool isShared;

  NoteModel(
      {this.id = '',
      this.title = '',
      this.createdOn,
      this.description = '',
      this.recipientId = '',
      this.senderId = '',
      this.isShared = false,
      this.isEncrypted = false});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'recipientId': recipientId,
      'senderId': senderId,
      'isShared': isShared,
      'createdOn': createdOn,
      'description': description,
      'isEncrypted': isEncrypted
    };
  }

  NoteModel fromMap(Map<String, dynamic> mapData) {
    return NoteModel(
        id: mapData['id'] ?? '',
        title: mapData['title'] ?? '--',
        createdOn: mapData['createdOn'],
        recipientId: mapData['recipientId'] ?? '',
        senderId: mapData['senderId'] ?? '',
        isShared: mapData['isShared'] ?? false,
        description: mapData['description'] ?? '',
        isEncrypted: mapData['isEncrypted'] ?? false);
  }
}
