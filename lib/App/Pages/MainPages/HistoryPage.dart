import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Misc/hexcolor.dart';
import 'WordDetailsScreen.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<String> history = [];

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString('history');
    if (historyJson != null) {
      final List<dynamic> historyList = json.decode(historyJson);
      history = historyList.cast<String>().toList().reversed.toList();
    }
    setState(() {});
  }

  void addToHistory(String word) {
    setState(() {
      history.insert(0, word);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: history.length,
        itemBuilder: (context, index) {
          final word = history[index];

          return ListTile(
            title: Container(
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(25),
                ),
                color: HexColor("#0e0916"),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    word,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WordDetailsScreen(
                    word: word,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
