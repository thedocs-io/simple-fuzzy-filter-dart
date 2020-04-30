import 'dart:collection';

import 'package:simple_fuzzy_filter/simple_fuzzy_filter_items_index.dart';
import 'package:simple_fuzzy_filter/simple_fuzzy_filter_text_provider.dart';
import 'package:simple_fuzzy_filter/simple_fuzzy_filter_result.dart';
import 'package:simple_fuzzy_filter/simple_fuzzy_filter_tokenizer.dart';

export 'simple_fuzzy_filter_text_provider.dart';
export 'simple_fuzzy_filter_result.dart';

class SimpleFuzzyFilterInitConfigTokenizer {
  final Set<String> splitSymbols;
  final bool isSplitByCase;

  const SimpleFuzzyFilterInitConfigTokenizer({this.splitSymbols = const {" ", "\t", ".", "-", "_", ","}, this.isSplitByCase = true});
}

class SimpleFuzzyFilterInitConfigFilter {
  final bool isSameOrderFirst;
  final bool isSameOrderStrict;

  const SimpleFuzzyFilterInitConfigFilter({this.isSameOrderFirst = false, this.isSameOrderStrict = false});
}

class SimpleFuzzyFilterInitConfig<T> {
  List<T> items;
  bool isInitIndexOnConstruct;
  SimpleFuzzyFilterInitConfigTokenizer tokenizer;
  SimpleFuzzyFilterInitConfigFilter filter;

  SimpleFuzzyFilterInitConfig({
    this.items,
    this.isInitIndexOnConstruct = false,
    this.tokenizer = const SimpleFuzzyFilterInitConfigTokenizer(),
    this.filter = const SimpleFuzzyFilterInitConfigFilter(),
  });
}

class _SimpleFuzzyFilterTokenizedTextFilterResult {
  Set<String> queryTokensMatched;
  List<SimpleFuzzyFilterHighlightItem> highlight;
  bool isSameOrder;

  _SimpleFuzzyFilterTokenizedTextFilterResult(this.queryTokensMatched, this.highlight, this.isSameOrder);
}

class SimpleFuzzyFilter<T> {
  final SimpleFuzzyFilterItemTextProvider<T> _textProvider;
  final SimpleFuzzyFilterTokenizer _tokenizer;
  final SimpleFuzzyFilterInitConfig<T> _config;
  final SimpleFuzzyFilterItemsIndex<T> index;

  SimpleFuzzyFilter._(this._textProvider, this._tokenizer, this.index, this._config) {
    if (this._config.isInitIndexOnConstruct) {
      this.index.indexedItems;
    }
  }

  factory SimpleFuzzyFilter({SimpleFuzzyFilterItemTextProvider<T> textProvider, SimpleFuzzyFilterInitConfig<T> config}) {
    config = config ?? new SimpleFuzzyFilterInitConfig<T>();
    SimpleFuzzyFilterTokenizer tokenizer = new SimpleFuzzyFilterTokenizer(splitSymbols: config.tokenizer.splitSymbols, isSplitByCase: config.tokenizer.isSplitByCase);
    SimpleFuzzyFilterItemsIndex<T> index = new SimpleFuzzyFilterItemsIndex(textProvider, tokenizer, config.items ?? []);

    return new SimpleFuzzyFilter._(textProvider, tokenizer, index, config);
  }

  List<SimpleFuzzyFilterMatchedItem<T>> filter(String query) {
    final answer = <SimpleFuzzyFilterMatchedItem<T>>[];
    final answerRandomOrder = <SimpleFuzzyFilterMatchedItem<T>>[];
    final queryTokens = this._getQueryTokens(query);
    final items = this.index.indexedItems;

    for (var item in items) {
      var matched = this.doFilterItem(item, queryTokens);

      if (matched != null) {
        if (matched.isSameOrder) {
          answer.add(matched);
        } else {
          if (!this._config.filter.isSameOrderStrict) {
            if (this._config.filter.isSameOrderFirst) {
              answerRandomOrder.add(matched);
            } else {
              answer.add(matched);
            }
          }
        }
      }
    }

    for (var item in answerRandomOrder) {
      answer.add(item);
    }

    return answer;
  }

  List<String> _getQueryTokens(String query) {
    final answer = <String>[];
    final tokenizedItems = this._tokenizer.tokenize(query);

    for (var item in tokenizedItems) {
      if (item.isToken) {
        answer.add(item.text.toUpperCase());
      }
    }

    return answer;
  }

  SimpleFuzzyFilterMatchedItem<T> doFilterItem(SimpleFuzzyFilterItemData<T> item, List<String> queryTokens) {
    final queryTokensMatched = <String>{};
    final queryTokensLength = queryTokens.length;

    var isAnySameOrder = false;
    var highlight = new HashMap<String, List<SimpleFuzzyFilterHighlightItem>>();

    for (var e in item.textTokenized.entries) {
      final filterResult = this._doFilterItemTokenizedText(e.value, queryTokens);
      var queryTokensMatchedCount = 0;

      filterResult.queryTokensMatched.forEach((token) {
        queryTokensMatched.add(token);
        queryTokensMatchedCount++;
      });

      if (filterResult.isSameOrder && queryTokensLength == queryTokensMatchedCount) {
        isAnySameOrder = true;
      }

      highlight[e.key] = filterResult.highlight;
    }

    if (queryTokensMatched.length == queryTokensLength) {
      return new SimpleFuzzyFilterMatchedItem<T>(item: item.item, highlight: this._getHighlightResult(highlight, item.textOriginal.textType), isSameOrder: isAnySameOrder);
    } else {
      return null;
    }
  }

  _SimpleFuzzyFilterTokenizedTextFilterResult _doFilterItemTokenizedText(List<SimpleFuzzyFilterTokenizedItem> tokenizedText, List<String> queryTokens) {
    final queryTokensMatched = <String>{};
    final highlight = <SimpleFuzzyFilterHighlightItem>[];
    var currentText = "";
    var lastMatchedToken = "";
    var isSameOrder = false;

    for (var text in tokenizedText) {
      if (text.isToken) {
        var isTokenMatched = false;
        var tokenPrev = "";

        for (var token in queryTokens) {
          if (!isTokenMatched) {
            if (text.text.toUpperCase().startsWith(token)) {
              if (lastMatchedToken != tokenPrev) {
                isSameOrder = false;
              }

              isTokenMatched = true;
              queryTokensMatched.add(token);

              if (currentText.isNotEmpty) {
                highlight.add(new SimpleFuzzyFilterHighlightItem(
                  text: currentText,
                  isMatched: false,
                ));
              }

              highlight.add(new SimpleFuzzyFilterHighlightItem(
                text: text.text.substring(0, token.length),
                isMatched: true,
              ));

              highlight.add(new SimpleFuzzyFilterHighlightItem(
                text: text.text.substring(token.length),
                isMatched: false,
              ));

              currentText = "";
              lastMatchedToken = token;
            }
          }

          tokenPrev = token;
        }

        if (!isTokenMatched) {
          highlight.add(new SimpleFuzzyFilterHighlightItem(
            text: currentText + text.text,
            isMatched: false,
          ));

          currentText = "";
        }
      } else {
        currentText += text.text;
      }
    }

    if (currentText.isNotEmpty) {
      highlight.add(new SimpleFuzzyFilterHighlightItem(
        text: currentText,
        isMatched: false,
      ));
    }

    return new _SimpleFuzzyFilterTokenizedTextFilterResult(queryTokensMatched, highlight, isSameOrder);
  }

  SimpleFuzzyFilterHighlightResult _getHighlightResult(HashMap<String, List<SimpleFuzzyFilterHighlightItem>> highlight, SimpleFuzzyFilterItemTextType textType) {
    final keys = highlight.keys;

    switch (textType) {
      case SimpleFuzzyFilterItemTextType.SINGLE:
        return new SimpleFuzzyFilterHighlightResult(single: highlight[keys.first]);
      case SimpleFuzzyFilterItemTextType.LIST:
        return new SimpleFuzzyFilterHighlightResult(list: keys.map((k) => highlight[k]).toList());
      case SimpleFuzzyFilterItemTextType.MAP:
        return new SimpleFuzzyFilterHighlightResult(map: {...highlight});
      default:
        throw new UnsupportedError("");
    }
  }
}
