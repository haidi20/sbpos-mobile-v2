import 'package:setting/presentation/view_models/setting.state.dart';

class SettingHelpViewModelActions {
  SettingHelpViewModelActions({
    required SettingState Function() getState,
    required void Function(SettingState) setState,
  })  : _getState = getState,
        _setState = setState;

  final SettingState Function() _getState;
  final void Function(SettingState) _setState;

  void setFaqExpanded(int index, bool isExpanded) {
    final state = _getState();
    final updatedFaqs = state.help.faqs.asMap().entries.map((entry) {
      if (entry.key == index) {
        return entry.value.copyWith(isExpanded: isExpanded);
      }

      return entry.value.copyWith(isExpanded: false);
    }).toList();

    _setState(
      state.copyWith(
        help: state.help.copyWith(faqs: updatedFaqs),
      ),
    );
  }
}
