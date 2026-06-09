import 'package:flutter/material.dart';

class LecturerFeature {
  const LecturerFeature({
    required this.title,
    required this.icon,
  });

  final String title;
  final IconData icon;
}

class LecturerScheduleItem {
  const LecturerScheduleItem({
    required this.start,
    required this.end,
    required this.title,
    required this.location,
  });

  final String start;
  final String end;
  final String title;
  final String location;
}

class LecturerDueItem {
  const LecturerDueItem({
    required this.title,
    required this.course,
    required this.date,
    required this.daysLeft,
  });

  final String title;
  final String course;
  final String date;
  final int daysLeft;
}
