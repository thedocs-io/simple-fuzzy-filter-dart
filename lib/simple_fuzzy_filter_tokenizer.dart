class SimpleFuzzyFilterTokenizedItem {
  final String text;
  final bool isToken;

  SimpleFuzzyFilterTokenizedItem({this.text, this.isToken});
}

class SimpleFuzzyFilterTokenizer {
  final Set<String> splitSymbols;
  final bool isSplitByCase;

  SimpleFuzzyFilterTokenizer({this.splitSymbols = const {" ", "\t", ".", "-", "_", ","}, this.isSplitByCase = false});

  List<SimpleFuzzyFilterTokenizedItem> tokenize(String text) {
    var answer = [] as List<SimpleFuzzyFilterTokenizedItem>;
    var letters = text.split("");
    var currentToken = '';
    var prevTokenByCase = false;

    var saveToken = (String token) {
      if (token != null && token.isNotEmpty) {
        answer.add(new SimpleFuzzyFilterTokenizedItem(text: token, isToken: true));
      }
    };

    var saveSymbol = (String symbol) {
      if (symbol != null && symbol.isNotEmpty) {
        answer.add(new SimpleFuzzyFilterTokenizedItem(text: symbol, isToken: false));
      }
    };

    for (var letter in letters) {
      if (this.splitSymbols.contains(letter)) {
        saveToken(currentToken);
        saveSymbol(letter);

        currentToken = "";
        prevTokenByCase = false;
      } else if (this.isSplitByCase && letter.toUpperCase() == letter) {
        if (prevTokenByCase) {
          currentToken += letter;
        } else {
          saveToken(currentToken);
          currentToken = letter;
          prevTokenByCase = true;
        }
      } else {
        currentToken += letter;
        prevTokenByCase = false;
      }
    }

    saveToken(currentToken);

    return answer;
  }
}
