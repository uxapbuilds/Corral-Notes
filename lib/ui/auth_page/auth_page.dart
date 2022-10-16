import 'dart:io';

import 'package:corralnotes/constants/strings.dart';
import 'package:corralnotes/cubit/authentication_cubit/authentication_cubit.dart';
import 'package:corralnotes/util/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  late AuthenticationCubit _authCubit;
  final TextEditingController _phoneNumberController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _authCubit = BlocProvider.of<AuthenticationCubit>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    var _mediaQuery = MediaQuery.of(context);
    Widget signUpOptions() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _phoneNumberController,
            style: const TextStyle(color: Colors.white),
            cursorColor: Colors.white,
            enableInteractiveSelection: false,
            keyboardType: TextInputType.number,
            maxLength: 10,
            decoration: InputDecoration(
              counterText: '',
              prefixText: '+91',
              prefixIcon: const Icon(
                FontAwesomeIcons.phone,
                size: 15,
                color: Colors.white,
              ),
              suffixIcon: InkWell(
                onTap: () {
                  _authCubit.setUid(_phoneNumberController.text.trim());
                  _authCubit.signInOrLogin(context, SignInType.phone);
                  FocusScope.of(context).unfocus();
                },
                child: const Icon(
                  FontAwesomeIcons.check,
                  size: 13,
                ),
              ),
              hintStyle: const TextStyle(color: Colors.white),
              fillColor: Colors.white,
              focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white)),
              enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white)),
            ),
            maxLines: 1,
            autofocus: false,
          ),
          SizedBox(
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                hMargin(width: 50, height: .3),
                const Text(
                  'or',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                hMargin(width: 50, height: .3),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              _authCubit.signInOrLogin(context, SignInType.google);
            },
            label: const Text('Sign in with Google'),
            icon: const Icon(
              FontAwesomeIcons.google,
              size: 15,
            ),
          ),
          if (Platform.isIOS)
            SizedBox(
              width: _mediaQuery.size.width * .5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      _authCubit.signInOrLogin(context, SignInType.apple);
                    },
                    label: const Text('Sign in with Apple'),
                    icon: const Icon(
                      FontAwesomeIcons.apple,
                      size: 15,
                    ),
                  ),
                ],
              ),
            )
        ],
      );
    }

    Widget topInfo() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Welcome to,',
            style: TextStyle(
                fontSize: 33, color: Colors.white, fontWeight: FontWeight.w300),
          ),
          Text(
            'Corral Notes',
            style: TextStyle(
                fontSize: 38, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(
            height: 30,
          ),
          Text(
            'Sign In.',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.normal,
                color: Colors.white),
          ),
          SizedBox(
            height: 10,
          ),
        ],
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          SvgPicture.asset(
            BACKGROUND_5,
            fit: BoxFit.fill,
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: HORIZONTAL_PADDING) +
                    EdgeInsets.only(top: _mediaQuery.padding.top + 20),
            child: BlocBuilder<AuthenticationCubit, AuthenticationState>(
              builder: (context, state) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    topInfo(),
                    signUpOptions(),
                    if (_authCubit.isLoading)
                      Column(
                        children: const [
                          SizedBox(
                            height: 25,
                          ),
                          CircularProgressIndicator(
                            strokeWidth: 1,
                            color: Colors.white,
                          )
                        ],
                      )
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
