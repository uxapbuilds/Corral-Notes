import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:corralnotes/service/firebase_transactions_service.dart';
import 'package:equatable/equatable.dart';
import '../../model/note_data_model.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(const HomeInitial());

  String _userPin = '';
  bool _notesUnlocked = false;
  String _userEmail = '';
  String _phoneNumber = '';
  bool _isSortAsc = false;
  String _searchTerm = '';
  int _noteCount = 0;
  Map<String, NoteModel> _data = {};
  //GETTERS
  String get userPin => _userPin;
  bool get notesUnlocked => _notesUnlocked;
  String get userEmail => _userEmail;
  bool get sortType => _isSortAsc;
  int get noteCount => _noteCount;
  String get phoneNumber => _phoneNumber;
  Map<String, NoteModel> get data => _data;
  // StreamController<Map<dynamic, NoteModel>> get dataStream => _dataStream;

  void init(String userEmail, String phoneNumber) {
    _userEmail = userEmail;
    _phoneNumber = phoneNumber;
    getUserPin();
  }

  void setDefaults() {
    _userEmail = '';
    _phoneNumber = '';
    _userPin = '';
    _notesUnlocked = false;
    _searchTerm = '';
  }

  // void setCurrentIdx(int idx) {
  // emit(const HomeUpdating());
  // _tabIndexController.add(idx);
  // emit(const HomeUpdated());
  // }

  Future getUserPin() async {
    _userPin = await FirebaseTransaction(collectionId: '')
        .getUserPin(userEmail, phoneNumber);
    // log('pib $userPin');
  }

  void setUnlocked() {
    emit(const HomeUpdating());
    _notesUnlocked = true;
    emit(const HomeUpdated());
  }

  void changeSort(bool type) {
    emit(const HomeUpdating());
    _isSortAsc = type;
    emit(const HomeUpdated());
  }

  void searchTerm(String searchTerm) {
    emit(const HomeUpdating());
    _searchTerm = searchTerm.trim();
    emit(const HomeUpdated());
  }

  void changeNoteCount(int i) {
    emit(const HomeUpdating());
    _noteCount = i;
    emit(const HomeUpdated());
  }

  Map<String, NoteModel> buildData(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> data) {
    emit(const HomeUpdating());

    Map<String, NoteModel> _notesData = {};
    if (data != null) {
      for (var element in data) {
        _notesData[element.id] = NoteModel().fromMap(element.data());
      }
      if (_isSortAsc) {
        _notesData = Map.fromEntries(_notesData.entries.toList()
          ..sort((e1, e2) => e1.value.createdOn!
              .toDate()
              .compareTo(e2.value.createdOn!.toDate())));
      } else {
        _notesData = Map.fromEntries(_notesData.entries.toList()
          ..sort((e1, e2) => e2.value.createdOn!
              .toDate()
              .compareTo(e1.value.createdOn!.toDate())));
      }
      if (_searchTerm.isNotEmpty) {
        _notesData = Map.fromEntries(_notesData.entries.where((element) =>
            (!element.value.isEncrypted || _notesUnlocked) &&
            (element.value.title
                    .toLowerCase()
                    .contains(_searchTerm.toLowerCase()) ||
                element.value.description
                    .toLowerCase()
                    .contains(_searchTerm.toLowerCase()))));
      }
    }
    _data = _notesData;
    emit(const HomeUpdated());
    return _notesData;
  }
}
