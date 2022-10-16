import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:corralnotes/util/utility.dart';
import 'package:corralnotes/util/widgets.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:the_apple_sign_in/the_apple_sign_in.dart';

part 'authentication_state.dart';

enum SignInType { google, apple, phone }

class AuthenticationCubit extends Cubit<AuthenticationState> {
  AuthenticationCubit() : super(const AuthenticationInitial());

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  GoogleSignInAccount? _user;
  bool _isLoading = false;
  String _uid = '';
  String _generatedOTP = '';

  //GETTERS
  GoogleSignInAccount get user => _user!;
  bool get isLoading => _isLoading;
  String get uid => _uid;

  void setUid(String uid) {
    _uid = uid;
  }

  void signInOrLogin(BuildContext context, SignInType type) {
    switch (type) {
      case SignInType.google:
        googleSignIn(context);
        break;
      case SignInType.apple:
        appleSignIn(context);
        break;
      case SignInType.phone:
        phoneOtpSignIn(context);
        break;
    }
  }

  Future phoneOtpSignIn(BuildContext context) async {
    try {
      showLoader(true);
      _auth.verifyPhoneNumber(
          codeAutoRetrievalTimeout: (String verificationId) {},
          codeSent: (String verificationId, int? forceResendingToken) {
            _generatedOTP = verificationId;
            showLoader(false);
            showDialog(
                context: context,
                builder: (context) => pinVerification(context));
          },
          phoneNumber: '+91' + _uid,
          verificationCompleted: (PhoneAuthCredential phoneAuthCredential) {
            // _auth.signInWithCredential(phoneAuthCredential);
          },
          verificationFailed: (FirebaseAuthException error) {
            showLoader(false);
            if (error.code == 'invalid-phone-number') {
              makeToast('Invalid OTP.');
            } else {
              makeToast('Couldn\'t sign up, please try again later');
            }
          });
    } catch (e) {
      showLoader(false);
      makeToast('Couldn\'t sign up, please try again later');
    }
  }

  Future verifyOtp(BuildContext context, String userOtp) async {
    try {
      PhoneAuthCredential _cred = PhoneAuthProvider.credential(
          verificationId: _generatedOTP, smsCode: userOtp);
      await _auth.signInWithCredential(_cred);
      Navigator.pop(context);
    } catch (e) {
      makeToast('Invalid OTP');
    }
  }

  Future googleSignIn(BuildContext context) async {
    try {
      final _googleUserData = await _googleSignIn.signIn();
      if (_googleUserData == null) {
        makeToast('Couldn\'t sign up, please try again later');
        return;
      }
      showLoader(true);
      _user = _googleUserData;
      final _googleAuthData = await _googleUserData.authentication;
      final _userCreds = GoogleAuthProvider.credential(
          accessToken: _googleAuthData.accessToken,
          idToken: _googleAuthData.idToken);
      await _auth.signInWithCredential(_userCreds);
      makeToast('Signed in');
    } catch (e) {
      // log(e.toString());
      showLoader(false);
      makeToast('Couldn\'t sign up, please try again later');
    }
  }

  Future appleSignIn(BuildContext context) async {
    final AuthorizationResult result = await TheAppleSignIn.performRequests([
      const AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName])
    ]);
    showLoader(true);
    switch (result.status) {
      case AuthorizationStatus.authorized:
        // log(result.credential!.fullName.toString());
        final appleIdCredential = result.credential!;
        final oAuthProvider = OAuthProvider('apple.com');
        final credential = oAuthProvider.credential(
          idToken: String.fromCharCodes(appleIdCredential.identityToken!),
          accessToken:
              String.fromCharCodes(appleIdCredential.authorizationCode!),
        );
        final userCredential = await _auth.signInWithCredential(credential);
        final _user = userCredential.user!;
        final fullName = appleIdCredential.fullName;
        if (fullName != null &&
            fullName.givenName != null &&
            fullName.familyName != null) {
          final displayName = '${fullName.givenName} ${fullName.familyName}';
          await _user.updateDisplayName(displayName);
        }
        showLoader(false);
        makeToast('Signed in.');
        break;
      case AuthorizationStatus.error:
        showLoader(false);
        makeToast('Couldn\'t sign up, please try again later.');
        break;

      case AuthorizationStatus.cancelled:
        showLoader(false);
        makeToast('Sign in cancelled by user.');
        break;
    }
  }

  void showLoader(bool show) {
    emit(const AuthenticationUpdating());
    _isLoading = show;
    emit(const AuthenticationUpdated());
  }

  void logOut() async {
    try {
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.disconnect();
      }
      FirebaseAuth.instance.signOut();
      showLoader(false);
      makeToast('Logged out.');
    } catch (e) {
      log(e.toString());
    }
  }
}
