import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:words/App/Pages/MainPages/WordDetailsScreen.dart';

class Loadwordjson extends StatefulWidget {
  final String word;
  final String base;

  const Loadwordjson({
    Key? key,
    required this.word,
    required this.base,
  }) : super(key: key);

  @override
  State<Loadwordjson> createState() => _LoadwordjsonState();
}

class _LoadwordjsonState extends State<Loadwordjson> {
  String previous = '';
  String next = '';
  List<String> searchedData = [];
  Map<String, dynamic> jsonData = {};

  @override
  void initState() {
    super.initState();
    // Delay the loading of JSON data to allow time for widget initialization
    Future.delayed(const Duration(milliseconds: 1500), loadJsonData);
  }

  Future<void> loadJsonData() async {
    // Load JSON data from assets
    String jsonString =
        await rootBundle.loadString('assets/json/words_dictionary.json');
    jsonData = json.decode(jsonString);
    findPreviousAndNext(widget.word);
  }

  void onSearchTextChanged(String text) {
    searchedData.clear();
    // Find keys that contain the search text
    searchedData.addAll(jsonData.keys
        .where((key) => key.contains(text))
        .map((key) => key.toString())
        .toList());
    findPreviousAndNext(text);
  }

  void findPreviousAndNext(String text) {
    if (jsonData.containsKey(text)) {
      List<String> keys = jsonData.keys.toList();
      int currentIndex = keys.indexOf(text);

      setState(() {
        // Update previous and next based on the current index
        previous = currentIndex > 0 ? keys[currentIndex - 1] : '';
        next = currentIndex < keys.length - 1 ? keys[currentIndex + 1] : '';

        // Navigate to the next or previous word details screen based on the widget's base parameter
        if (widget.base == "next") {
          if (next.isEmpty) {
            Navigator.pop(context);
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => WordDetailsScreen(
                  word: next,
                ),
              ),
            );
          }
        } else {
          if (previous.isEmpty) {
            Navigator.pop(context);
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => WordDetailsScreen(
                  word: previous,
                ),
              ),
            );
          }
        }
      });
    } else {
      setState(() {
        previous = '';
        next = '';
        print("error");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
