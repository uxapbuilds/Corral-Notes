import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:corralnotes/constants/strings.dart';
import 'package:corralnotes/model/note_data_model.dart';
import 'package:corralnotes/util/widgets.dart';
import 'package:corralnotes/widgets/note_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../cubit/authentication_cubit/authentication_cubit.dart';
import '../../cubit/home_cubit/home_cubit.dart';
import '../../widgets/error_page.dart';
import '../../widgets/note_edit_create.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late HomeCubit _homeCubit;
  late AuthenticationCubit _authCubit;
  final _userData = FirebaseAuth.instance.currentUser!;
  final TextEditingController _searchBarController = TextEditingController();
  int _currentTabIdx = 0;

  @override
  void initState() {
    super.initState();
    _homeCubit = BlocProvider.of<HomeCubit>(context, listen: false);
    _authCubit = BlocProvider.of<AuthenticationCubit>(context, listen: false);
    _homeCubit.init(_userData.email ?? '', _userData.phoneNumber ?? '');
  }

  String getCollectionId({bool myNotes = true}) {
    if (_userData.email != null && _userData.email!.isNotEmpty) {
      return _userData.email ?? '_';
    }
    if (_userData.phoneNumber != null && _userData.phoneNumber!.isNotEmpty) {
      return _userData.phoneNumber ?? '_';
    }
    return '_';
  }

  final List<Widget> _tabs = [
    const Tab(
      text: 'My Notes',
    ),
    const Tab(
      text: 'Shared with me',
    )
  ];

  Stream<QuerySnapshot<Map<String, dynamic>>> getData() {
    if (_currentTabIdx == 1) {
      final String? findBy;
      if (_userData.email != null && _userData.email!.isNotEmpty) {
        findBy = _userData.email;
      } else {
        findBy = _userData.phoneNumber!.split('+91')[1];
      }
      return FirebaseFirestore.instance
          .collection('sharednotes')
          .where('recipientId', isEqualTo: findBy)
          .snapshots();
    } else {
      return FirebaseFirestore.instance
          .collection(getCollectionId())
          .snapshots();
    }
  }

  @override
  Widget build(BuildContext context) {
    var _mediaQuery = MediaQuery.of(context);
    var _screenHeight = _mediaQuery.size.height -
        (_mediaQuery.padding.top + _mediaQuery.padding.bottom);
    log(_userData.phoneNumber.toString());
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: ((context) => const NoteCreate(
                    isNew: true,
                    isEdit: true,
                  )),
            ),
          );
        },
        child: const Icon(
          FontAwesomeIcons.pencil,
          size: 18,
        ),
      ),
      body: Stack(
        children: [
          Transform(
            transform: Matrix4.identity()..invertRotation(),
            child: SvgPicture.asset(
              BACKGROUND_5,
              fit: BoxFit.fill,
            ),
          ),
          GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Column(
              children: [
                Container(
                  height: _screenHeight * .35,
                  padding: const EdgeInsets.symmetric(
                          horizontal: HORIZONTAL_PADDING) +
                      const EdgeInsets.only(bottom: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: _mediaQuery.padding.top,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              _authCubit.logOut();
                              _homeCubit.setDefaults();
                            },
                            child: Row(
                              children: const [
                                Icon(
                                  FontAwesomeIcons.arrowRightFromBracket,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  'Logout',
                                  style: TextStyle(color: Colors.white),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                  _currentTabIdx == 0
                                      ? 'My\nNotes'
                                      : 'Shared\nwith me',
                                  style: const TextStyle(
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)),
                              const SizedBox(
                                width: 20,
                              ),
                              if (_userData != null &&
                                  _userData.photoURL != null &&
                                  _userData.photoURL!.isNotEmpty)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: Image.network(
                                    _userData.photoURL ?? '',
                                    height: 90,
                                    width: 90,
                                  ),
                                )
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          BlocBuilder<HomeCubit, HomeState>(
                            builder: (context, state) {
                              return Text('${_homeCubit.noteCount} notes',
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.normal,
                                      color: Colors.white));
                            },
                          )
                        ],
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(top: 15, bottom: 7),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.white.withOpacity(.08)),
                                height: 40,
                                width: _mediaQuery.size.width * .4,
                                child: TextField(
                                  controller: _searchBarController,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 16),
                                  cursorColor: Colors.white,
                                  onChanged: (v) {
                                    _homeCubit.searchTerm(v);
                                  },
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(
                                      FontAwesomeIcons.magnifyingGlass,
                                      size: 12,
                                      color: Colors.white,
                                    ),
                                    suffix: InkWell(
                                      onTap: () {
                                        _searchBarController.clear();
                                        _homeCubit.searchTerm('');
                                      },
                                      child: const Icon(
                                        FontAwesomeIcons.xmark,
                                        size: 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                    hintText: "Search..",
                                    hintStyle: const TextStyle(
                                        fontSize: 12, color: Colors.white),
                                    fillColor: Colors.white,
                                    focusedBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.transparent)),
                                    enabledBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.transparent)),
                                  ),
                                  maxLines: 1,
                                  autofocus: false,
                                )),
                            BlocBuilder<HomeCubit, HomeState>(
                              builder: (context, state) {
                                return InkWell(
                                  onTap: () => _homeCubit
                                      .changeSort(!_homeCubit.sortType),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        _homeCubit.sortType
                                            ? Icons.arrow_upward
                                            : Icons.arrow_downward,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                      vMargin(),
                                      const Text('Date created',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.white))
                                    ],
                                  ),
                                );
                              },
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                DefaultTabController(
                  length: _tabs.length,
                  initialIndex: 0,
                  child: Material(
                    color: Colors.transparent,
                    child: SizedBox(
                      height: 40,
                      child: TabBar(
                        onTap: (value) {
                          _currentTabIdx = value;
                          setState(() {});
                        },
                        tabs: _tabs,
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.white30,
                      ),
                    ),
                  ),
                ),
                StreamBuilder(
                  stream: getData(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                          snapshot) {
                    if (snapshot.hasError) {
                      return const ErrorPage(
                        hasError: true,
                        errorText: 'Something went wrong',
                      );
                    }
                    if (snapshot.hasData) {
                      if (snapshot.data != null) {
                        return BlocBuilder<HomeCubit, HomeState>(
                          builder: (context, state) {
                            _homeCubit.buildData(snapshot.data!.docs);
                            _homeCubit.changeNoteCount(_homeCubit.data.length);
                            return _homeCubit.data.isNotEmpty
                                ? Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: HORIZONTAL_PADDING - 8,
                                        vertical: 0),
                                    child: SingleChildScrollView(
                                      child: SizedBox(
                                        height: _screenHeight * .62,
                                        child: GridView.extent(
                                            padding: const EdgeInsets.all(0),
                                            shrinkWrap: true,
                                            maxCrossAxisExtent:
                                                _mediaQuery.size.height * .21,
                                            childAspectRatio: .58,
                                            children: _homeCubit.data.entries
                                                .map((note) => NoteCard(
                                                      isShared:
                                                          _currentTabIdx == 1,
                                                      noteData: note.value,
                                                      fireDocId: note.key,
                                                    ))
                                                .toList()),
                                      ),
                                    ),
                                  )
                                : const Expanded(
                                    child: Center(
                                      child: Text(
                                        'No notes found',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15),
                                      ),
                                    ),
                                  );
                          },
                        );
                      } else {
                        return Container();
                      }
                    }
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: _mediaQuery.size.height * .29,
                        ),
                        const CircularProgressIndicator(
                          strokeWidth: 1,
                          color: Colors.white,
                        )
                      ],
                    );
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
