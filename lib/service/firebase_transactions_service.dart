import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:corralnotes/model/note_data_model.dart';
import 'package:corralnotes/model/pin_data_model.dart';

class FirebaseTransaction {
  final String collectionId;
  final String pinCollectionId = 'userpins';
  FirebaseTransaction({required this.collectionId});

  Future<void> uploadNoteData(NoteModel data) async {
    await FirebaseFirestore.instance.collection(collectionId).add(data.toMap());
  }

  Future<void> uploadShareableNoteData(NoteModel data) async {
    await FirebaseFirestore.instance
        .collection('sharednotes')
        .add(data.toMap());
  }

  Future<void> updateNote(String docId, NoteModel data) async {
    log('ww ' + collectionId);
    await FirebaseFirestore.instance
        .collection(collectionId)
        .doc(docId)
        .update(data.toMap());
  }

  Future<void> deleteNote(String docId) async {
    await FirebaseFirestore.instance
        .collection(collectionId)
        .doc(docId)
        .delete();
  }

  Future<void> setUserPin(PinDataModel data) async {
    try {
      late QuerySnapshot query;
      if (data.userEmail != null && data.userEmail.isNotEmpty) {
        query = await FirebaseFirestore.instance
            .collection(pinCollectionId)
            .where('userEmail', isEqualTo: data.userEmail)
            .get();
      } else if (data.phoneNumber != null && data.phoneNumber.isNotEmpty) {
        query = await FirebaseFirestore.instance
            .collection(pinCollectionId)
            .where('phoneNumber', isEqualTo: data.phoneNumber)
            .get();
      }
      if (query != null && query.docs.isEmpty) {
        log('1');
        await FirebaseFirestore.instance
            .collection(pinCollectionId)
            .add(data.toMap());
      } else {
        //IF EXISTS, UPDATE
        log('2');
        await FirebaseFirestore.instance
            .collection(collectionId)
            .doc(query.docs[0].id)
            .update(data.toMap());
      }
    } catch (e) {
      log(e.toString());
    }
  }

  Future<String> getUserPin(String emailId, String phoneNumber) async {
    try {
      late QuerySnapshot query;
      if (emailId != null && emailId.isNotEmpty) {
        query = await FirebaseFirestore.instance
            .collection(pinCollectionId)
            .where('userEmail', isEqualTo: emailId)
            .get();
      } else if (phoneNumber != null && phoneNumber.isNotEmpty) {
        query = await FirebaseFirestore.instance
            .collection(pinCollectionId)
            .where('phoneNumber', isEqualTo: phoneNumber)
            .get();
      }
      if (query != null && query.docs.isNotEmpty) {
        return PinDataModel()
            .fromMap(query.docs[0].data() as Map<String, dynamic>)
            .pin;
      } else {
        return '';
      }
    } catch (e) {
      log(e.toString());
    }
    return '';
  }
}
