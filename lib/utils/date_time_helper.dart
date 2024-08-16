import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:swarm/consts/colors.dart';

String formatDate(DateTime dateTime) {
  final DateFormat formatter = DateFormat('E MMM d hh:mm a');
  return formatter.format(dateTime);
}

String formatDateLong(DateTime dateTime) {
  final DateFormat formatter = DateFormat('EEEE, MMMM d, yyyy');
  final DateFormat formattertime = DateFormat('hh:mm a');
  return formatter.format(dateTime) + " at " + formattertime.format(dateTime);
}

String formatDateOnlyLong(DateTime dateTime) {
  final DateFormat formatter = DateFormat('EEEE, MMMM d, yyyy');
  return formatter.format(dateTime);
}

String formatTime(DateTime time) {
  return DateFormat('E MMM d h:mm a')
      .format(time); // Use 'h:mm a' for 12-hour format with am/pm
}

String formatDateOnly(DateTime time) {
  return DateFormat('E. MMM d, yyyy')
      .format(time); // Use 'h:mm a' for 12-hour format with am/pm
}

String formatDateString(DateTime date) {
  final now = DateTime.now();
  final difference = date.difference(now).inDays;

  if (difference == 0) {
    return 'Today';
  } else if (difference == 1) {
    return 'Tomorrow';
  } else if (difference == -1) {
    return 'Yesterday';
  } else {
    final formatter = DateFormat('E MMM d');
    return formatter.format(date);
  }
}

String formatDateTimeString(DateTime date) {
  final now = DateTime.now();
  final difference = date.difference(now).inDays;
  final DateFormat formattertime = DateFormat('hh:mm a');

  if (difference == 0) {
    return 'Today ' + formattertime.format(date);
  } else if (difference == 1) {
    return 'Tomorrow ' + formattertime.format(date);
  } else if (difference == -1) {
    return 'Yesterday ' + formattertime.format(date);
  } else {
    final formatter = DateFormat('E MMM d hh:mm a');
    return formatter.format(date);
  }
}

String remainingDays(DateTime date) {
  final now = DateTime.now();
  final difference = date.difference(now).inDays;

  if (difference == 0) {
    return 'today';
  } else if (difference == -1) {
    return 'yesterday';
  } else if (difference < -1) {
    final formatter = DateFormat('E MMM d');
    return formatter.format(date);
  } else {
    return "In ${difference}d";
  }
}

String remainingHours(DateTime date) {
  final now = DateTime.now();
  final difference = date.difference(now).inHours;
  return "${difference} hours";
}

int remainingHoursInt(DateTime date) {
  final now = DateTime.now();
  return date.difference(now).inHours;
}

String formatDateTime(DateTime dateTime) {
  final DateFormat formatter = DateFormat('E MMM d');
  if (formatter.format(dateTime) == formatter.format(DateTime.now()))
    return DateFormat('h:mm a').format(dateTime);
  else
    return DateFormat('EEEE MMM d').format(dateTime);
}

String formatDateTimeChat(DateTime dateTime) {
  final DateFormat formatter = DateFormat('E MMM d');
  if (formatter.format(dateTime) == formatter.format(DateTime.now()))
    return DateFormat('h:mm a').format(dateTime);
  else {
    final now = DateTime.now();
    final difference = dateTime.difference(now).inDays;
    return "${difference}d ago";
  }
}

DateTime convertUtcToLocal(DateTime? utcDateTime) {
  return utcDateTime == null ? DateTime.now() : utcDateTime.toLocal();
}

Color getColorForStatus(int orderStatusNo) {
  switch (orderStatusNo) {
    case 0: // Pending
      return universalColorPrimaryDefault;
    case 1: // Declined
      return Colors.red;
    case 2: // In Progress
      return Colors.blue;
    case 3: // Completed
      return Colors.green;
    case 4: // Canceled
      return Colors.grey;
    default:
      return Colors.black;
  }
}

bool containsUpperCase(String str) {
  for (int i = 0; i < str.length; i++) {
    if (str[i].isAlphabetOnly && str[i] == str[i].toUpperCase()) {
      return true;
    }
  }
  return false;
}
