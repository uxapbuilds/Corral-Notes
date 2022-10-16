import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oktoast/oktoast.dart';

class Utility {
  String captialiseEachWord(String text) {
    if (text == null) {
      return '';
    }
    if (text.length <= 1) {
      return text.toUpperCase();
    }
    final words = text.split(' ');
    final capitalized = words.map((word) {
      String rest = '';
      String first = '';
      final l = word.length;
      if (word.isNotEmpty) {
        first = word.substring(0, 1).toUpperCase();
      }
      if (l > 1) {
        rest = word.substring(1);
      }
      return '$first$rest';
    });
    return capitalized.join(' ');
  }
}

void makeToast(String message, {int duration = 2, bool doCapitalise = false}) {
  showToast(doCapitalise ? Utility().captialiseEachWord(message) : message,
      duration: Duration(seconds: duration),
      position: const ToastPosition(align: Alignment(0, .9)),
      textPadding: const EdgeInsets.symmetric(horizontal: 19, vertical: 12));
}

String formatDate(DateTime date, {String format = 'dd/MM\nhh:mm aa'}) {
  return DateFormat(format).format(date).toString();
}
