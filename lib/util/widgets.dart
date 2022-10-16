import 'dart:developer';
import 'dart:ffi';

import 'package:corralnotes/constants/strings.dart';
import 'package:corralnotes/cubit/authentication_cubit/authentication_cubit.dart';
import 'package:corralnotes/model/pin_data_model.dart';
import 'package:corralnotes/service/firebase_transactions_service.dart';
import 'package:corralnotes/util/utility.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../cubit/home_cubit/home_cubit.dart';

var pinCode = '';

Widget hMargin({double height = .1, double width = 90}) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: HORIZONTAL_PADDING - 10),
    height: height,
    width: width,
    color: Colors.white,
  );
}

Widget vMargin({double height = 10, double width = .1}) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: HORIZONTAL_PADDING - 15),
    height: height,
    width: width,
    color: Colors.white,
  );
}

Widget deleteDiag(BuildContext context, Function onDelete, Function onCancel) {
  return Dialog(
    insetPadding: EdgeInsets.symmetric(
        vertical: MediaQuery.of(context).size.height * .4,
        horizontal: MediaQuery.of(context).size.width * .1),
    child: Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Are you sure?',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(
            height: 8,
          ),
          const Text('Note will be permanenetly deleted.'),
          const SizedBox(
            height: 15,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              OutlinedButton(
                onPressed: () {
                  onCancel();
                },
                style: ButtonStyle(
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0))),
                ),
                child: const Text("Cancel"),
              ),
              OutlinedButton(
                onPressed: () {
                  onDelete();
                },
                style: ButtonStyle(
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0))),
                ),
                child: const Text("Delete"),
              ),
            ],
          )
        ],
      ),
    ),
  );
}

Widget pinDialog(BuildContext context,
    {bool isNew = false, String userEmail = '', String phoneNumber = ''}) {
  var _homeCubit = BlocProvider.of<HomeCubit>(context, listen: false);
  return Dialog(
    child: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isNew ? 'Create new pin' : 'Encripted note',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(
              height: 8,
            ),
            Text(isNew
                ? 'Please enter the pin'
                : 'Please enter the pin to unlock.'),
            const SizedBox(
              height: 15,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * .9,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: PinCodeTextField(
                  appContext: context,
                  length: 4,
                  pinTheme: PinTheme(
                    borderWidth: 1,
                    errorBorderColor: Colors.black,
                    inactiveColor: Colors.grey,
                    activeColor: Colors.black,
                    selectedColor: Colors.black,
                    fieldOuterPadding:
                        const EdgeInsets.symmetric(horizontal: 0.1),
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(8),
                    fieldHeight: 50,
                    fieldWidth: 40,
                    activeFillColor: Colors.white,
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (_) {},
                  onCompleted: (v) {
                    if (!isNew) {
                      if (_homeCubit.userPin == v) {
                        _homeCubit.setUnlocked();
                        Navigator.pop(context);
                        makeToast('Unlocked');
                      } else {
                        makeToast('Incorrect pin, please try again.');
                      }
                    } else {
                      pinCode = v;
                    }
                  },
                  obscureText: true,
                ),
              ),
            ),
            if (isNew)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0))),
                    ),
                    child: const Text("Cancel",
                        style: TextStyle(color: Colors.black)),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      if ((userEmail.isNotEmpty || phoneNumber.isNotEmpty) &&
                          pinCode.isNotEmpty) {
                        FirebaseTransaction(collectionId: '').setUserPin(
                            PinDataModel(
                                userEmail: userEmail,
                                pin: pinCode,
                                phoneNumber: phoneNumber));
                        Navigator.pop(context);
                        makeToast('Pin successfully created.');
                      } else {
                        makeToast('Pin creation unsuccessfull.');
                      }
                    },
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0))),
                    ),
                    child: const Text(
                      "Save",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              )
          ],
        ),
      ),
    ),
  );
}

Widget pinVerification(BuildContext context) {
  var _authCubit = BlocProvider.of<AuthenticationCubit>(context, listen: false);
  return Dialog(
    child: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Verify OTP',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(
              height: 8,
            ),
            Text('Please enter the OTP sent to +91${_authCubit.uid}'),
            const SizedBox(
              height: 15,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * .9,
              child: PinCodeTextField(
                appContext: context,
                length: 6,
                pinTheme: PinTheme(
                  borderWidth: 1,
                  errorBorderColor: Colors.black,
                  inactiveColor: Colors.grey,
                  activeColor: Colors.black,
                  selectedColor: Colors.black,
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(8),
                  fieldHeight: 50,
                  fieldWidth: 40,
                  activeFillColor: Colors.white,
                ),
                keyboardType: TextInputType.number,
                onChanged: (_) {},
                onCompleted: (v) {
                  if (v.length == 6) {
                    _authCubit.verifyOtp(context, v);
                  } else {
                    makeToast('Please enter correct OTP.');
                  }
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
