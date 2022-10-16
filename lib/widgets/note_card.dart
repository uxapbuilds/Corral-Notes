import 'dart:ui';

import 'package:corralnotes/cubit/home_cubit/home_cubit.dart';
import 'package:corralnotes/util/utility.dart';
import 'package:corralnotes/util/widgets.dart';
import 'package:corralnotes/widgets/note_edit_create.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/note_data_model.dart';

class NoteCard extends StatelessWidget {
  const NoteCard(
      {this.noteData, this.fireDocId = '', this.isShared = false, Key? key})
      : super(key: key);
  final NoteModel? noteData;
  final String fireDocId;
  final bool isShared;

  @override
  Widget build(BuildContext context) {
    final _userData = FirebaseAuth.instance.currentUser!;
    var _mediaQuery = MediaQuery.of(context);
    var _homeCubit = BlocProvider.of<HomeCubit>(context, listen: false);

    void onLockedNoteTap() async {
      await _homeCubit.getUserPin();
      showDialog(
        context: context,
        builder: (context) => pinDialog(context,
            isNew: _homeCubit.userPin.isEmpty,
            userEmail: _userData.email ?? '',
            phoneNumber: _userData.phoneNumber ?? ''),
      );
    }

    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
          child: Column(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    if (noteData!.isEncrypted && !_homeCubit.notesUnlocked) {
                      onLockedNoteTap();
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: ((context) => NoteCreate(
                                isShared: isShared,
                                fireDocId: fireDocId,
                                noteData: noteData,
                                isEdit: false,
                              )),
                        ),
                      );
                    }
                  },
                  child: Stack(
                    children: [
                      Container(
                        width: _mediaQuery.size.width * .3,
                        decoration: BoxDecoration(
                          color:
                              noteData!.isEncrypted && !_homeCubit.notesUnlocked
                                  ? Colors.white.withOpacity(.1)
                                  : Colors.white.withOpacity(.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.only(top: 10),
                        padding: const EdgeInsets.all(10),
                        child: SingleChildScrollView(
                          child: SizedBox(
                            height: 150,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    noteData!.description,
                                    maxLines: 7,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  )
                                ]),
                          ),
                        ),
                      ),
                      if (noteData!.isEncrypted && !_homeCubit.notesUnlocked)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(
                              sigmaX: 5.0,
                              sigmaY: 5.0,
                            ),
                            child: Container(
                              alignment: Alignment.center,
                              // width: 130.0,
                              // height: 180.0,
                              child: const Icon(
                                Icons.lock,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              SizedBox(
                width: _mediaQuery.size.height * .13,
                child: Text(noteData!.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
              ),
              const SizedBox(
                height: 4,
              ),
              Visibility(
                visible: isShared && noteData!.senderId.isNotEmpty,
                child: SizedBox(
                  width: _mediaQuery.size.height * .13,
                  child: Text('From:\n${noteData!.senderId}',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.normal,
                          fontSize: 10)),
                ),
              ),
              const SizedBox(
                height: 4,
              ),
              if (noteData != null && noteData!.createdOn != null)
                Text(
                  formatDate(noteData!.createdOn!.toDate()),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10),
                )
            ],
          ),
        );
      },
    );
  }
}
