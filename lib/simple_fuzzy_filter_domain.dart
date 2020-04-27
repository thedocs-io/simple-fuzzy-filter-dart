typedef String SimpleFuzzyFilterItemTextStringProvider<T>(T item);

typedef List<String> SimpleFuzzyFilterItemTextListProvider<T>(T item);

typedef Map<String, String> SimpleFuzzyFilterItemTextMapProvider<T>(T item);

class SimpleFuzzyFilterItemTextProvider<T> {


  factory SimpleFuzzyFilterItemTextProvider.simple(SimpleFuzzyFilterItemTextStringProvider<T> func) {

  }

  factory SimpleFuzzyFilterItemTextProvider.list(SimpleFuzzyFilterItemTextListProvider<T> func) {

  }

  factory SimpleFuzzyFilterItemTextProvider.map(SimpleFuzzyFilterItemTextMapProvider<T> func) {

  }
}
