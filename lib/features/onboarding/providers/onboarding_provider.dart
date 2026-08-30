import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/core_providers.dart';

final onboardingCompletedProvider = StateNotifierProvider<OnboardingNotifier, bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return OnboardingNotifier(prefs);
});

class OnboardingNotifier extends StateNotifier<bool> {
  final dynamic _prefs;

  OnboardingNotifier(this._prefs)
      : super(_prefs.getBool(AppConstants.keyHasCompletedOnboarding) ?? false);

  Future<void> completeOnboarding() async {
    await _prefs.setBool(AppConstants.keyHasCompletedOnboarding, true);
    state = true;
  }
}
