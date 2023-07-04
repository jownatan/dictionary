import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:words/App/Misc/hexcolor.dart';
import 'package:words/App/Integrations/API/Words/trie.dart';

import 'WordDetailsScreen.dart';
import 'SavePage.dart';
import 'HistoryPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  List<String> words = [];
  late TabController _tabController;
  late TextEditingController _searchController;
  List<String> filteredWords = [];
  Trie trie = Trie();
  bool isLoading = false;
  bool isLoaded = false;
  Map<String, dynamic> jsonData = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabSelection);
    _searchController = TextEditingController();
    isLoaded = false;
    _handleTabSelection();
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    if (_tabController.index == 0 && !isLoaded) {
      setState(() {
        isLoading = true;
      });
      loadWords().then((_) {
        Future.delayed(const Duration(seconds: 1), () {
          setState(() {
            isLoading = false;
            isLoaded = true;
          });
        });
      });
    } else {
      setState(() {
        _searchController.clear();
      });
    }
  }

  Future<void> loadWords() async {
    String data =
        await rootBundle.loadString('assets/json/words_dictionary.json');
    jsonData = json.decode(data);
    words = jsonData.keys.toList();
    filteredWords = List.from(words);

    for (final word in words) {
      trie.insert(word.toLowerCase());
    }
  }

  void _performSearch(String query) {
    setState(() {
      filteredWords = trie.search(query.toLowerCase());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text(''),
        backgroundColor: HexColor("#0e0916"),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.blue,
          tabs: const [
            Tab(text: 'Words'),
            Tab(text: 'History'),
            Tab(text: 'Favorites'),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Visibility(
            visible: _tabController.index == 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: const Text(
                    "Words",
                    style: TextStyle(
                      fontFamily: 'code',
                      fontSize: 35,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _performSearch,
                    decoration: InputDecoration(
                      labelText: 'Search',
                      prefixIcon:
                          Icon(Icons.search, color: HexColor('#f64c09')),
                      labelStyle: TextStyle(color: HexColor('#ce963b')),
                      disabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: HexColor('#ce963b')),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: HexColor('#ce963b')),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: TabBarView(
                controller: _tabController,
                children: [
                  isLoading ? _buildLoadingView() : _buildWordsListView(),
                  HistoryPage(),
                  SavePage(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildWordsListView() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 5,
        crossAxisSpacing: 5,
      ),
      itemCount: filteredWords.length,
      itemBuilder: (context, index) {
        final word = filteredWords[index];
        return GestureDetector(
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
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(const Radius.circular(25)),
              color: HexColor("#0e0916"),
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Text(
                  word,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
