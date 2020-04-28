import 'dart:collection';

enum SimpleFuzzyFilterItemTextType { SINGLE, LIST, MAP }

typedef String SimpleFuzzyFilterItemTextSingleProvider<T>(T item);

typedef List<String> SimpleFuzzyFilterItemTextListProvider<T>(T item);

typedef Map<String, String> SimpleFuzzyFilterItemTextMapProvider<T>(T item);

class SimpleFuzzyFilterItemText {
  final LinkedHashMap<String, String> text;
  final SimpleFuzzyFilterItemTextType textType;

  SimpleFuzzyFilterItemText(this.text, this.textType);
}

class SimpleFuzzyFilterItemTextProvider<T> {
  final SimpleFuzzyFilterItemTextSingleProvider<T> _single;
  final SimpleFuzzyFilterItemTextListProvider<T> _list;
  final SimpleFuzzyFilterItemTextMapProvider<T> _map;

  SimpleFuzzyFilterItemTextProvider._(this._single, this._list, this._map);

  SimpleFuzzyFilterItemText getText(T item) {
    LinkedHashMap<String, String> text = new LinkedHashMap<String, String>();
    SimpleFuzzyFilterItemTextType textType = null;

    if (this._single != null) {
      textType = SimpleFuzzyFilterItemTextType.SINGLE;
      text["single"] = this._single(item);
    } else if (this._list != null) {
      textType = SimpleFuzzyFilterItemTextType.LIST;
      this._list(item).asMap().forEach((i, textItem) {
        text["a" + i.toString()] = textItem;
      });
    } else if (this._map != null) {
      textType = SimpleFuzzyFilterItemTextType.LIST;
      this._map(item).forEach((k, textItem) {
        text[k] = textItem;
      });
    }

    return new SimpleFuzzyFilterItemText(text, textType);
  }

  factory SimpleFuzzyFilterItemTextProvider.single(SimpleFuzzyFilterItemTextSingleProvider<T> func) {
    return new SimpleFuzzyFilterItemTextProvider<T>._(func, null, null);
  }

  factory SimpleFuzzyFilterItemTextProvider.list(SimpleFuzzyFilterItemTextListProvider<T> func) {
    return new SimpleFuzzyFilterItemTextProvider<T>._(null, func, null);
  }

  factory SimpleFuzzyFilterItemTextProvider.map(SimpleFuzzyFilterItemTextMapProvider<T> func) {
    return new SimpleFuzzyFilterItemTextProvider<T>._(null, null, func);
  }
}
