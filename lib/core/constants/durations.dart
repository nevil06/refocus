class PresetDuration {
  final int minutes;
  final String label;

  const PresetDuration({required this.minutes, required this.label});

  int get seconds => minutes * 60;
}

const List<PresetDuration> presetDurations = [
  PresetDuration(minutes: 15, label: '15m'),
  PresetDuration(minutes: 25, label: '25m'),
  PresetDuration(minutes: 45, label: '45m'),
  PresetDuration(minutes: 60, label: '1h'),
  PresetDuration(minutes: 90, label: '1h 30m'),
  PresetDuration(minutes: 120, label: '2h'),
];
