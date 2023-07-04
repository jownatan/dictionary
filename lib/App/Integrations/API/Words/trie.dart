import 'package:collection/collection.dart'; // Import the 'collection' package

class TrieNode {
  final Map<String, TrieNode> children;
  bool isWord;

  TrieNode()
      : children = {},
        isWord = false;
}

class Trie {
  final TrieNode root;

  Trie() : root = TrieNode();

  void insert(String word) {
    TrieNode node = root;
    for (int i = 0; i < word.length; i++) {
      final char = word[i];
      if (!node.children.containsKey(char)) {
        node.children[char] = TrieNode();
      }
      node = node.children[char]!;
    }
    node.isWord = true;
  }

  List<String> search(String query) {
    TrieNode node = root;
    for (int i = 0; i < query.length; i++) {
      final char = query[i];
      if (!node.children.containsKey(char)) {
        return [];
      }
      node = node.children[char]!;
    }
    final List<String> results = [];
    _traverse(node, query, results);
    return results;
  }

  void _traverse(TrieNode node, String prefix, List<String> results) {
    if (node.isWord) {
      results.add(prefix);
    }
    for (final entry in node.children.entries) {
      final char = entry.key;
      final childNode = entry.value;
      _traverse(childNode, prefix + char, results);
    }
  }
}
