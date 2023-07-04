// ignore_for_file: public_member_api_docs, sort_constructors_first
class TimeOfDay {
  final int min;
  final int hour;
  TimeOfDay({
    required this.min,
    required this.hour,
  }) {}
  bool greaterThan(TimeOfDay otherTime) {
    if (hour > otherTime.hour) {
      return true;
    } else if (hour == otherTime.hour && min > otherTime.min) {
      return true;
    }
    return false;
  }

  bool lessThan(TimeOfDay otherTime) {
    if (hour < otherTime.hour) {
      return true;
    } else if (hour == otherTime.hour && min < otherTime.min) {
      return true;
    }
    return false;
  }

  bool equalsTo(TimeOfDay otherTime) {
    if (hour == otherTime.hour && min == otherTime.min) {
      return true;
    }
    return false;
  }

  TimeOfDay addTime(TimeOfDay other) {
    var t_min = min + other.min;
    var t_hour = hour + other.hour;
    if (min > 60) {
      t_min %= 60;
      t_hour++;
    }
    return TimeOfDay(min: t_min, hour: t_hour);
  }

  @override
  String toString() => '($hour: $min )';
}

class TimeSlot {
  final TimeOfDay from;
  final TimeOfDay to;
  final double nominalUsage;
  double accumulatedUsage = 0;
  TimeSlot.o(
      {required this.from, required this.to, required this.nominalUsage});

  // // TimeSlot() = default;
  // TimeSlot(TimeOfDay from, int durationHour, int durationMin, int nominalUsage){

  // }

  TimeSlot(
      TimeOfDay t_from, int durationHour, int durationMin, double t_nominalUsage)
      : from = (t_from),
        to = TimeOfDay(
            hour: t_from.hour + durationHour, min: t_from.min + durationMin),
        nominalUsage = (t_nominalUsage) {}
  bool timeInTimeSlot(TimeOfDay time) {
    if ((from.lessThan(time) || from.equalsTo(time)) &&
        (to.greaterThan(time) || to.equalsTo(time))) {
      return true;
    }
    return false;
  }

  void increaseUsage(double current) {
    accumulatedUsage += current * 1 * 220 / 3600000.0;
  }

  // void checkUsage();

  @override
  String toString() {
    return '( $from - $to, usage: $accumulatedUsage)';
  }
}

List<TimeSlot> timeSlots = [
  TimeSlot(TimeOfDay(hour: 14, min: 47), 0, 1, 1000),
  TimeSlot(TimeOfDay(hour: 14, min: 48), 0, 1, 1000),
  TimeSlot(TimeOfDay(hour: 14, min: 49), 0, 1, 1000),
  TimeSlot(TimeOfDay(hour: 14, min: 50), 0, 1, 1000),
  TimeSlot(TimeOfDay(hour: 14, min: 51), 0, 1, 1000),
  TimeSlot(TimeOfDay(hour: 14, min: 52), 0, 1, 1000),
];
