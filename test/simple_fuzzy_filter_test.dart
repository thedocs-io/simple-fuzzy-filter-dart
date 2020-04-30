import 'package:simple_fuzzy_filter/simple_fuzzy_filter.dart';
import 'package:test/test.dart';

class SimpleNote {
  final String name;

  SimpleNote(this.name);
}

class DataSetToCheckExpectItem {
  String highlight;
  bool isSameOrder;

  DataSetToCheckExpectItem(this.highlight, [this.isSameOrder = false]);
}

class DataSetToCheck {
  List<String> keys;
  String query;
  List<DataSetToCheckExpectItem> expect;

  DataSetToCheck({this.keys, this.query, List<Map<String, dynamic>> expect})
      : this.expect = expect.map((e) => new DataSetToCheckExpectItem(e["highlight"], e["isSameOrder"] ?? false)).toList();
}

main() {
  String _highlightToString(List<SimpleFuzzyFilterHighlightItem> highlight) {
    return highlight.map((h) => (h.isMatched) ? "[" + h.text + "]" : h.text).join("");
  }

  void _assert(DataSetToCheck dataSetToCheck, {SimpleFuzzyFilterInitConfig<SimpleNote> config = null}) {
    //when
    var notes = dataSetToCheck.keys.map((k) => new SimpleNote(k)).toList();
    var textProvider = SimpleFuzzyFilterItemTextProvider.single((n) => n.name);
    config = config ?? new SimpleFuzzyFilterInitConfig();
    config.items = notes;

    var filter = new SimpleFuzzyFilter(textProvider: textProvider, config: config);
    var query = dataSetToCheck.query;
    var answer = filter.filter(query);

    //then
    var actual = query + ":" + answer.map((item) => _highlightToString(item.highlight.single) + ":" + item.isSameOrder.toString()).join(", ");
    var expected = query + ":" + dataSetToCheck.expect.map((item) => item.highlight + ":" + ((item.isSameOrder == null) ? true : item.isSameOrder.toString())).join(", ");

    expect(actual, equals(expected));
  }

  test("query not matches: simple case", () {
    var itemsToCheck = [
      new DataSetToCheck(keys: ["hello world"], query: "hellow", expect: []),
      new DataSetToCheck(keys: ["hello world"], query: "word", expect: []),
      new DataSetToCheck(keys: ["helloworld"], query: "hello world", expect: []),
      new DataSetToCheck(keys: ["helloWorld"], query: "helloworld", expect: []),
      new DataSetToCheck(keys: ["helloWorld"], query: "hel orld", expect: []),
      new DataSetToCheck(keys: ["helloWorld"], query: "l", expect: []),
      new DataSetToCheck(keys: ["hello world"], query: "hello again", expect: []),
      new DataSetToCheck(keys: ["hello world"], query: "justWord", expect: []),
      new DataSetToCheck(keys: ["hello world"], query: "ello world", expect: []),
    ];

    itemsToCheck.forEach((item) {
      _assert(item);
    });
  });

  test("query matches: single word", () {
    var itemsToCheck = [
      new DataSetToCheck(
        keys: ["hello world"],
        query: "hel",
        expect: [
          {"highlight": "[hel]lo world"}
        ],
      ),
      new DataSetToCheck(
        keys: ["hello world"],
        query: "Hel",
        expect: [
          {"highlight": "[hel]lo world"}
        ],
      ),
      new DataSetToCheck(
        keys: ["helloworld"],
        query: "hel",
        expect: [
          {"highlight": "[hel]loworld"}
        ],
      ),
      new DataSetToCheck(
        keys: ["helloWorld"],
        query: "hel",
        expect: [
          {"highlight": "[hel]loWorld"}
        ],
      ),
      new DataSetToCheck(
        keys: ["helloWorld"],
        query: "hello",
        expect: [
          {"highlight": "[hello]World"}
        ],
      ),
      new DataSetToCheck(
        keys: ["helloWorld"],
        query: "wo",
        expect: [
          {"highlight": "hello[Wo]rld"}
        ],
      ),
      new DataSetToCheck(
        keys: ["hello-world"],
        query: "wo",
        expect: [
          {"highlight": "hello-[wo]rld"}
        ],
      ),
      new DataSetToCheck(
        keys: ["hello world"],
        query: "wo",
        expect: [
          {"highlight": "hello [wo]rld"}
        ],
      ),
      new DataSetToCheck(
        keys: ["HELLO WORLD"],
        query: "hel",
        expect: [
          {"highlight": "[HEL]LO WORLD"}
        ],
      ),
      new DataSetToCheck(
        keys: ["HELLO WORLD"],
        query: "wo",
        expect: [
          {"highlight": "HELLO [WO]RLD"}
        ],
      ),
      new DataSetToCheck(
        keys: ["HELLO_WORLD"],
        query: "hel",
        expect: [
          {"highlight": "[HEL]LO_WORLD"}
        ],
      ),
      new DataSetToCheck(
        keys: ["HELLO-WORLD"],
        query: "wo",
        expect: [
          {"highlight": "HELLO-[WO]RLD"}
        ],
      ),
      new DataSetToCheck(
        keys: ["HELLO-WORLD"],
        query: "world",
        expect: [
          {"highlight": "HELLO-[WORLD]"}
        ],
      ),
      new DataSetToCheck(
        keys: ["helloWorld"],
        query: "HELLO",
        expect: [
          {"highlight": "[hello]World"}
        ],
      ),
    ];

    itemsToCheck.forEach((item) {
      _assert(item);
    });
  });
}
