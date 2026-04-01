part of 'package:setting/presentation/view_models/setting.vm.dart';

mixin _SettingHelpViewModelMixin on _SettingViewModelScope {
  void setFaqExpanded(int index, bool isExpanded) {
    final updatedFaqs = state.help.faqs.asMap().entries.map((entry) {
      if (entry.key == index) {
        return entry.value.copyWith(isExpanded: isExpanded);
      }

      return entry.value.copyWith(isExpanded: false);
    }).toList();

    state = state.copyWith(
      help: state.help.copyWith(faqs: updatedFaqs),
    );
  }
}
