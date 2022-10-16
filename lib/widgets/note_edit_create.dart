import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:corralnotes/constants/strings.dart';
import 'package:corralnotes/cubit/home_cubit/home_cubit.dart';
import 'package:corralnotes/model/note_data_model.dart';
import 'package:corralnotes/ui/home_page/home.dart';
import 'package:corralnotes/util/utility.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:uuid/uuid.dart';

import '../service/firebase_transactions_service.dart';
import '../util/widgets.dart';

class NoteCreate extends StatefulWidget {
  const NoteCreate(
      {this.fireDocId = '',
      this.isEdit = false,
      this.noteData,
      this.isShared = false,
      this.isNew = false,
      Key? key})
      : super(key: key);
  final String fireDocId;
  final bool isEdit;
  final NoteModel? noteData;
  final bool isShared;
  final bool isNew;
  @override
  State<NoteCreate> createState() => _NoteCreateState();
}

class _NoteCreateState extends State<NoteCreate> {
  final TextEditingController _noteDesc = TextEditingController();
  final TextEditingController _noteTitle = TextEditingController();
  final TextEditingController _recipient = TextEditingController();
  final _userData = FirebaseAuth.instance.currentUser!;
  late FirebaseTransaction _fTransaction;
  late HomeCubit _homeCubit;
  late bool _inEdit;
  bool _isEncrypted = false;
  late bool _isShared;
  bool _shareNote = false;

  String getCollectionId() {
    if (_userData.email != null && _userData.email!.isNotEmpty) {
      return _userData.email ?? '_';
    }
    if (_userData.phoneNumber != null && _userData.phoneNumber!.isNotEmpty) {
      return _userData.phoneNumber ?? '_';
    }
    return const Uuid().v4();
  }

  List<Widget> barActions() {
    return [
      InkWell(
        onTap: () => setState(() {
          _inEdit = !_inEdit;
        }),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
                color: _inEdit
                    ? Colors.black.withOpacity(.06)
                    : Colors.transparent,
                shape: BoxShape.circle),
            child: const Icon(
              FontAwesomeIcons.penToSquare,
              color: Colors.black,
              size: 16,
            ),
          ),
        ),
      ),
      InkWell(
        onTap: () => {
          if (widget.isEdit && !widget.isNew) {onUpdate()} else {onSave()}
        },
        child: const Padding(
          padding: EdgeInsets.all(15),
          child: Icon(
            FontAwesomeIcons.floppyDisk,
            color: Colors.black,
            size: 16,
          ),
        ),
      ),
      InkWell(
        onTap: () => widget.isEdit ? onDelete() : () {},
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Icon(
            FontAwesomeIcons.trash,
            color: widget.isEdit ? Colors.black : Colors.grey.withOpacity(.5),
            size: 16,
          ),
        ),
      ),
    ];
  }

  Widget leading() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      InkWell(
        onTap: () => Navigator.pop(context),
        child: const Icon(
          Icons.arrow_back_ios_new,
          color: Colors.black,
          // size: 15,
        ),
      ),
      if (!_isShared)
        SizedBox(
          width: !_isShared ? 16 : 36,
        ),
      if (!_isShared)
        InkWell(
          onTap: () async {
            await _homeCubit.getUserPin();
            if (_homeCubit.userPin.isEmpty) {
              showDialog(
                context: context,
                builder: (context) => pinDialog(context,
                    isNew: _homeCubit.userPin.isEmpty,
                    userEmail: _userData.email ?? '',
                    phoneNumber: _userData.phoneNumber ?? ''),
              );
            } else {
              setState(() {
                _isEncrypted = !_isEncrypted;
              });
              if (widget.isEdit) {
                onUpdate();
              }
            }
          },
          child: Icon(
            _isEncrypted ? Icons.lock : Icons.lock_open,
            color: Colors.black,
            size: 16,
          ),
        )
    ]);
  }

  void onSave() {
    if (_noteDesc.text.isEmpty) {
      makeToast('Please write something to save.');
    } else {
      NoteModel _data = NoteModel(
          id: const Uuid().v4(),
          title: _noteTitle.text.isEmpty ? 'Title' : _noteTitle.text,
          createdOn: Timestamp.now(),
          isEncrypted: _isEncrypted,
          recipientId: _recipient.text.trim(),
          senderId: _userData.email ?? _userData.phoneNumber ?? '',
          description: _noteDesc.text.isEmpty ? '' : _noteDesc.text);
      if (_recipient.text.isNotEmpty) {
        log('11');
        _fTransaction.uploadShareableNoteData(_data);
      } else {
        _fTransaction.uploadNoteData(_data);
      }
      FocusScope.of(context).unfocus();
      Navigator.pop(context);
      makeToast('Saved note.');
    }
  }

  void onUpdate() {
    NoteModel _data = NoteModel(
        id: widget.isEdit ? widget.noteData!.id : const Uuid().v4(),
        title: _noteTitle.text.isEmpty ? 'Title' : _noteTitle.text,
        createdOn: Timestamp.now(),
        isEncrypted: _isEncrypted,
        description: _noteDesc.text.isEmpty ? '' : _noteDesc.text);
    _fTransaction.updateNote(widget.fireDocId, _data);
    makeToast('Note updated.');
  }

  void onDelete() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => deleteDiag(context, () {
        _fTransaction.deleteNote(widget.fireDocId);
        makeToast('Note deleted.');
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
            (route) => false);
      }, () {
        Navigator.pop(context);
      }),
    );
  }

  @override
  void initState() {
    super.initState();
    _homeCubit = BlocProvider.of<HomeCubit>(context, listen: false);
    _fTransaction = FirebaseTransaction(collectionId: getCollectionId());
    log('aa ' + _fTransaction.collectionId);
    _inEdit = widget.isEdit;
    _isShared = widget.isShared;

    if (widget.noteData != null) {
      _recipient.text = widget.noteData!.recipientId;
      _noteDesc.text = widget.noteData!.description;
      _noteTitle.text = widget.noteData!.title;
      _isEncrypted = widget.noteData!.isEncrypted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        actions: _isShared ? null : barActions(),
        backgroundColor: Colors.white,
        leadingWidth:
            MediaQuery.of(context).size.width * (_isShared ? 0.12 : .2),
        leading: leading(),
        centerTitle: _isShared,
        title: Column(
          children: [
            TextField(
              controller: _noteTitle,
              readOnly: !_inEdit || _isShared,
              style: const TextStyle(color: Colors.black),
              cursorColor: Colors.black,
              decoration: const InputDecoration(
                hintText: "Title",
                hintStyle: TextStyle(color: Colors.black),
                fillColor: Colors.black,
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)),
              ),
              maxLines: 1,
              autofocus: true,
            ),
          ],
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              widget.isNew
                  ? ExpansionTile(
                      expandedAlignment: Alignment.center,
                      initiallyExpanded: false,
                      children: [
                        TextField(
                          decoration: InputDecoration(
                            icon: Icon(
                              _userData.email != null
                                  ? FontAwesomeIcons.envelope
                                  : FontAwesomeIcons.phone,
                              color: Colors.black,
                              size: 20,
                            ),
                            hintStyle: const TextStyle(color: Colors.black),
                            fillColor: Colors.black,
                            hintText:
                                '${_userData.email ?? _userData.phoneNumber}',
                            focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black)),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.black.withOpacity(.5))),
                          ),
                          readOnly: true,
                          keyboardType: TextInputType.multiline,
                          maxLines: 1,
                          autofocus: true,
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        TextField(
                          controller: _recipient,
                          decoration: InputDecoration(
                            icon: const Icon(
                              FontAwesomeIcons.user,
                              color: Colors.black,
                              size: 20,
                            ),
                            hintStyle: const TextStyle(color: Colors.black),
                            fillColor: Colors.black,
                            hintText: 'Recipient\'s ID',
                            focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black)),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.black.withOpacity(.5))),
                          ),
                          keyboardType: TextInputType.multiline,
                          maxLines: 1,
                          autofocus: true,
                        )
                      ],

                      textColor: Colors.black,
                      collapsedTextColor: Colors.black,
                      // controlAffinity: ListTileControlAffinity.leading,
                      backgroundColor: Colors.white,
                      collapsedBackgroundColor: Colors.white,
                      tilePadding: const EdgeInsets.symmetric(horizontal: 15),
                      childrenPadding:
                          const EdgeInsets.symmetric(horizontal: 15) +
                              const EdgeInsets.only(bottom: 20),
                      title: const Text(
                        'Share with:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    )
                  : Visibility(
                      visible: widget.noteData!.senderId.isNotEmpty,
                      child: Container(
                        color: Colors.white,
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                    horizontal: HORIZONTAL_PADDING - 5,
                                  ) +
                                  const EdgeInsets.only(top: 10, bottom: 20),
                              child: Text(
                                'From: ${widget.noteData!.senderId}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 8.0, horizontal: HORIZONTAL_PADDING - 10),
                child: TextField(
                  readOnly: !_inEdit || _isShared,
                  controller: _noteDesc,
                  decoration: InputDecoration(
                    hintText: _noteDesc.text.isNotEmpty
                        ? _noteDesc.text
                        : "Write something...",
                  ),
                  keyboardType: TextInputType.multiline,
                  maxLines: 99999,
                  autofocus: true,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
