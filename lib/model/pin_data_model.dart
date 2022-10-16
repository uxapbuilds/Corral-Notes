import 'dart:math';

class PinDataModel {
  String userEmail;
  String pin;
  String phoneNumber;

  PinDataModel({this.pin = '', this.userEmail = '', this.phoneNumber = ''});

  Map<String, dynamic> toMap() {
    return {'userEmail': userEmail, 'pin': pin, 'phoneNumber': phoneNumber};
  }

  PinDataModel fromMap(Map<String, dynamic> mapData) {
    return PinDataModel(
        userEmail: mapData['userEmail'],
        pin: mapData['pin'] ?? '',
        phoneNumber: mapData['phoneNumber'] ?? '');
  }
}
