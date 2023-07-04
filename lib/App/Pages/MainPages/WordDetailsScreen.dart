import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Integrations/API/Words/words_api.dart';
import '../../Misc/hexcolor.dart';
import 'package:words/App/Misc/loadwordjson.dart';

class WordDetailsScreen extends StatefulWidget {
  final String word;

  const WordDetailsScreen({
    Key? key,
    required this.word,
  }) : super(key: key);

  @override
  _WordDetailsScreenState createState() => _WordDetailsScreenState();
}

class _WordDetailsScreenState extends State<WordDetailsScreen> {
  bool _isFavorite = false;
  List<String> history = [];

  final wordsApi = WordsApi();

  late Future<String> _fetchPhonetics;
  late Future<String> _fetchMeaning;

  @override
  void initState() {
    super.initState();
    loadFavorites();

    _fetchPhonetics = fetchPhonetics();
    _fetchMeaning = fetchMeaning();
    loadHistory();
  }

  Future<void> loadHistory() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString('history');
    setState(() {
      history = List<String>.from(json.decode(historyJson ?? '[]'));
    });
    saveHistory();
  }

  Future<void> saveHistory() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final updatedHistory = [...history, widget.word];
    final historyJson = json.encode(updatedHistory);
    await prefs.setString('history', historyJson);
    setState(() {
      history = updatedHistory;
    });
  }

  Future<String> fetchPhonetics() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final cachedPhonetics = prefs.getString('${widget.word}_phonetics');
    if (cachedPhonetics != null) {
      print('Using cached phonetics');
      return cachedPhonetics;
    } else {
      try {
        final pronunciation = await wordsApi.fetchPronunciation(widget.word);
        prefs.setString('${widget.word}_phonetics', pronunciation);
        return pronunciation;
      } catch (e) {
        return 'Sem Fonetica (api)';
      }
    }
  }

  Future<String> fetchMeaning() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final cachedMeaning = prefs.getString('${widget.word}_meaning');
    if (cachedMeaning != null) {
      print('Using cached meaning');
      return cachedMeaning;
    } else {
      try {
        final wordMeaning = await wordsApi.fetchMeaning(widget.word);
        prefs.setString('${widget.word}_meaning', wordMeaning);
        return wordMeaning;
      } catch (e) {
        return 'Sem significado (api)';
      }
    }
  }

  Future<void> loadFavorites() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favorites');
    setState(() {
      _isFavorite = favorites?.contains(widget.word) ?? false;
    });
  }

  Future<void> toggleFavorite() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    bool newIsFavorite = !_isFavorite; // Calculate the new value of _isFavorite

    final List<String> favorites = prefs.getStringList('favorites') ?? [];

    if (newIsFavorite) {
      favorites.add(widget.word);
    } else {
      favorites.remove(widget.word);
    }

    await prefs.setStringList('favorites', favorites);

    // Update the state only if the widget is still mounted
    if (mounted) {
      setState(() {
        _isFavorite = newIsFavorite;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Word Details'),
        backgroundColor: HexColor("#0e0916"),
      ),
      body: FutureBuilder<List<String>>(
        future: Future.wait([_fetchPhonetics, _fetchMeaning]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error loading data.'),
            );
          } else {
            final phonetics = snapshot.data?[0] ?? '';
            final meaning = snapshot.data?[1] ?? '';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    height: 300,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(25),
                      ),
                      color: Colors.black,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            widget.word,
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'code',
                              fontSize: 25,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            phonetics,
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'code',
                              fontSize: 25,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        "Meanings",
                        style: TextStyle(
                          color: HexColor("#ce963b"),
                          fontFamily: 'code',
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Spacer(),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: IconButton(
                        onPressed: toggleFavorite,
                        icon: Icon(
                          _isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: _isFavorite ? Colors.red : null,
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    meaning,
                    style: TextStyle(
                      fontFamily: 'code',
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Spacer(),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 20.0, right: 20.0, bottom: 8.0, top: 8.0),
                  child: Row(
                    children: [
                      Container(
                        width: 150.0,
                        height: 50.0,
                        decoration: BoxDecoration(
                          color: Color(0xFF0e0916),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              elevation: 0,
                            ),
                            onPressed: () {
                              Future.delayed(Duration(milliseconds: 100), () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Loadwordjson(
                                      word: widget.word,
                                      base: "previous",
                                    ),
                                  ),
                                );
                              });
                            },
                            child: Text(
                              'Voltar',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Spacer(),
                      Container(
                        width: 150.0,
                        height: 50.0,
                        decoration: BoxDecoration(
                          color: Color(0xFF0e0916),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              elevation: 0,
                            ),
                            onPressed: () {
                              Future.delayed(Duration(milliseconds: 100), () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Loadwordjson(
                                      word: widget.word,
                                      base: "next",
                                    ),
                                  ),
                                );
                              });
                            },
                            child: Text(
                              'Proximo',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
