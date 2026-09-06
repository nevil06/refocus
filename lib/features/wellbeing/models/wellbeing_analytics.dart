import '../../../core/models/focus_session.dart';

class DailyFocusBarData {
  final DateTime date;
  final String dayLabel; // "Mon", "Tue", etc.
  final int focusMinutes;
  final int sessionCount;
  final bool isToday;

  DailyFocusBarData({
    required this.date,
    required this.dayLabel,
    required this.focusMinutes,
    required this.sessionCount,
    required this.isToday,
  });
}

class HourlyDistribution {
  final int morningMinutes; // 06:00 - 12:00
  final int afternoonMinutes; // 12:00 - 18:00
  final int eveningMinutes; // 18:00 - 24:00
  final int nightMinutes; // 00:00 - 06:00

  HourlyDistribution({
    required this.morningMinutes,
    required this.afternoonMinutes,
    required this.eveningMinutes,
    required this.nightMinutes,
  });

  int get totalMinutes =>
      morningMinutes + afternoonMinutes + eveningMinutes + nightMinutes;

  String get peakPeriodName {
    if (totalMinutes == 0) return 'Morning';
    if (morningMinutes >= afternoonMinutes &&
        morningMinutes >= eveningMinutes &&
        morningMinutes >= nightMinutes) {
      return 'Morning (6 AM - 12 PM)';
    }
    if (afternoonMinutes >= morningMinutes &&
        afternoonMinutes >= eveningMinutes &&
        afternoonMinutes >= nightMinutes) {
      return 'Afternoon (12 PM - 6 PM)';
    }
    if (eveningMinutes >= morningMinutes &&
        eveningMinutes >= afternoonMinutes &&
        eveningMinutes >= nightMinutes) {
      return 'Evening (6 PM - 12 AM)';
    }
    return 'Night (12 AM - 6 AM)';
  }
}

class WellbeingSummary {
  final List<DailyFocusBarData> last7Days;
  final int totalWeeklyMinutes;
  final int dailyAverageMinutes;
  final int todayMinutes;
  final int dailyGoalMinutes;
  final int totalCompletedSessions;
  final int totalInterruptedSessions;
  final int currentStreakDays;
  final int wellbeingScore; // 0 - 100
  final HourlyDistribution hourlyDistribution;
  final List<FocusSessionModel> recentSessions;
  final int totalProtectedApps;

  WellbeingSummary({
    required this.last7Days,
    required this.totalWeeklyMinutes,
    required this.dailyAverageMinutes,
    required this.todayMinutes,
    required this.dailyGoalMinutes,
    required this.totalCompletedSessions,
    required this.totalInterruptedSessions,
    required this.currentStreakDays,
    required this.wellbeingScore,
    required this.hourlyDistribution,
    required this.recentSessions,
    required this.totalProtectedApps,
  });

  double get goalProgress {
    if (dailyGoalMinutes <= 0) return 1.0;
    return (todayMinutes / dailyGoalMinutes).clamp(0.0, 1.0);
  }

  String get scoreTitle {
    if (wellbeingScore >= 85) return 'Laser Focused';
    if (wellbeingScore >= 70) return 'Consistent Master';
    if (wellbeingScore >= 50) return 'Building Momentum';
    if (wellbeingScore >= 25) return 'Gaining Focus';
    return 'Starting Journey';
  }
}
