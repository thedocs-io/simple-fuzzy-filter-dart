import 'dart:collection';

import 'package:simple_fuzzy_filter/simple_fuzzy_filter.dart';
import 'package:simple_fuzzy_filter/simple_fuzzy_filter_tokenizer.dart';

class SimpleFuzzyFilterItemData<T> {
  final T item;
  final SimpleFuzzyFilterItemText textOriginal;
  final LinkedHashMap<String, List<SimpleFuzzyFilterTokenizedItem>> textTokenized;

  SimpleFuzzyFilterItemData(this.item, this.textOriginal, this.textTokenized);
}

class SimpleFuzzyFilterItemsIndex<T> {
  List<SimpleFuzzyFilterItemData<T>> _items;
  final SimpleFuzzyFilterItemTextProvider<T> _textProvider;
  final SimpleFuzzyFilterTokenizer _tokenizer;
  final List<T> _itemsCached;

  SimpleFuzzyFilterItemsIndex(this._textProvider, this._tokenizer, List<T> _items)
      : _itemsCached = [..._items],
        _items = null;

  List<T> get items {
    if (this._items != null) {
      return this._items.map((i) => i.item);
    } else {
      return [...this._itemsCached];
    }
  }

  List<SimpleFuzzyFilterItemData<T>> get indexedItems {
    if (this._items == null) {
      this._items = this._initIndex();
    }

    return this._items;
  }

  void set(List<T> items) {
    this.reset();
    this.addAll(items);
  }

  void reset() {
    if (this._items != null) this._items.clear();
    if (this._itemsCached != null) this._itemsCached.clear();
  }

  void add(T item) {
    if (this._items != null) {
      var textOriginal = this._textProvider.getText();
      var textTokenized = this._tokenize(textOriginal);

      this._items.add(new SimpleFuzzyFilterItemData<T>(item, textOriginal, textTokenized));
    } else {
      this._itemsCached.add(item);
    }
  }

  void addAll(List<T> items) {
    for (var item in items) {
      this.add(item);
    }
  }

  void remove(T item) {
    if (this._items != null) {
      this._items.removeWhere((i) => i.item == item);
    } else {
      this._itemsCached.remove(item);
    }
  }

  void removeAll(List<T> items) {
    for (var item in items) {
      this.remove(item);
    }
  }

  List<SimpleFuzzyFilterItemData<T>> _initIndex() {
    this._items = [];
    this._itemsCached.forEach((item) => this.add(item));
    this._itemsCached.clear();

    return this._items;
  }

  LinkedHashMap<String, List<SimpleFuzzyFilterTokenizedItem>> _tokenize(SimpleFuzzyFilterItemText text) {
    LinkedHashMap<String, List<SimpleFuzzyFilterTokenizedItem>> answer = new LinkedHashMap<String, List<SimpleFuzzyFilterTokenizedItem>>();

    text.text.forEach((k, v) {
      answer[k] = this._tokenizer.tokenize(v);
    });

    return answer;
  }
}
