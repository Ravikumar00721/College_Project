import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreenState {
  final String? selectedCategory;
  final String? selectedSubCategory;
  final String? selectedSubject;
  final String? inputText;
  final String? inputSource;
  final List<String> subCategoryOptions;
  final List<String> subjectOptions;

  HomeScreenState({
    this.selectedCategory,
    this.selectedSubCategory,
    this.selectedSubject,
    this.inputText,
    this.inputSource,
    this.subCategoryOptions = const [],
    this.subjectOptions = const [],
  });

  HomeScreenState clear() {
    return HomeScreenState();
  }
}

class HomeScreenNotifier extends StateNotifier<HomeScreenState> {
  HomeScreenNotifier() : super(HomeScreenState());

  void clearAll() {
    state = state.clear();
  }

  void updateInputText(String text) {
    state = HomeScreenState(
      inputText: text,
      selectedCategory: state.selectedCategory,
      selectedSubCategory: state.selectedSubCategory,
      selectedSubject: state.selectedSubject,
      inputSource: state.inputSource,
      subCategoryOptions: state.subCategoryOptions,
      subjectOptions: state.subjectOptions,
    );
  }
}

final homeScreenProvider =
    StateNotifierProvider<HomeScreenNotifier, HomeScreenState>((ref) {
  return HomeScreenNotifier();
});
