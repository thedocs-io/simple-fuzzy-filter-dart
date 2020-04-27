import 'package:simple_fuzzy_filter/simple_fuzzy_filter_domain.dart';
import 'package:simple_fuzzy_filter/simple_fuzzy_filter_result.dart';

export 'simple_fuzzy_filter_domain.dart';
export 'simple_fuzzy_filter_result.dart';

class SimpleFuzzyFilter<T> {
  final SimpleFuzzyFilterItemTextProvider<T> _textProvider;

  SimpleFuzzyFilter({SimpleFuzzyFilterItemTextProvider<T> textProvider}) : _textProvider = textProvider;

  List<SimpleFuzzyFilterMatchedItem<T>> filter(String query) {

  }
}
