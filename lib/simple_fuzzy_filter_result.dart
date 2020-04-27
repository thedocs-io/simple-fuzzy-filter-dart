
class SimpleFuzzyFilterHighlightItem {
  final String text;
  final bool isMatched;

  SimpleFuzzyFilterHighlightItem({this.text, this.isMatched});
}

class SimpleFuzzyFilterHighlightResult {
  final List<SimpleFuzzyFilterHighlightItem> simple;
  final List<List<SimpleFuzzyFilterHighlightItem>> list;
  final Map<String, List<SimpleFuzzyFilterHighlightItem>> map;

  SimpleFuzzyFilterHighlightResult({this.simple, this.list, this.map});

  bool isSimple() {
    return this.simple != null;
  }

  bool isList() {
    return this.list != null;
  }

  bool isMap() {
    return this.map != null;
  }
}

class SimpleFuzzyFilterMatchedItem<T> {
  final T item;
  final SimpleFuzzyFilterHighlightResult highlight;
  final bool isSameOrder;

  SimpleFuzzyFilterMatchedItem({this.item, this.highlight, this.isSameOrder});
}
