String concatByRange(String str, int start, int end) => _removeLastChars(str, start, end);

String _removeLastChars(String str, int start, int end) => str.substring(start, end);
