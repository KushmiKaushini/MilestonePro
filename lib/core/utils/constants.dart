import 'package:flutter/material.dart';

abstract final class AppConstants {
  static const String appName = 'Milestone Pro';
  static const String dbName = 'milestone_pro';

  // SharedPreferences keys
  static const String onboardingCompleteKey = 'onboarding_complete';
  static const String userNameKey = 'user_name';

  // Notification channel IDs
  static const String reminderChannelId = 'milestone_reminders';
  static const String streakChannelId = 'streak_alerts';
  static const String criticalChannelId = 'critical_alarms';

  // Goal categories
  static const List<String> goalCategories = [
    'Health & Fitness',
    'Career',
    'Education',
    'Finance',
    'Relationships',
    'Personal Growth',
    'Travel',
    'Creative',
    'Spirituality',
    'Other',
  ];

  // Goal icon options (Material icon code points)
  static const List<int> goalIconCodes = [
    0xe25a, // fitness_center
    0xe0af, // work_outline
    0xe80c, // school
    0xe263, // savings
    0xe7fb, // people_outline
    0xe7fd, // self_improvement
    0xe513, // flight_takeoff
    0xe40a, // palette
    0xef55, // spa
    0xe87d, // star_outline
    0xe8b6, // trending_up
    0xf0f5, // rocket_launch
  ];

  // Icon labels matching above codes
  static const List<String> goalIconLabels = [
    'Fitness',
    'Work',
    'Education',
    'Finance',
    'People',
    'Mindfulness',
    'Travel',
    'Creative',
    'Wellness',
    'Goals',
    'Growth',
    'Launch',
  ];

  // Priority labels (index = priority level)
  static const List<String> priorityLabels = ['Low', 'Medium', 'High', 'Critical'];

  // Padding & spacing
  static const double paddingXS = 4;
  static const double paddingS = 8;
  static const double paddingM = 16;
  static const double paddingL = 24;
  static const double paddingXL = 32;

  // Border radius
  static const double radiusS = 8;
  static const double radiusM = 12;
  static const double radiusL = 16;
  static const double radiusXL = 24;

  // Animation durations
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 250);
  static const Duration animationSlow = Duration(milliseconds: 400);

  // Icon helper
  static IconData iconFromCode(int code) =>
      IconData(code, fontFamily: 'MaterialIcons');
}
