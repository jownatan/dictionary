import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Misc/hexcolor.dart';
import 'WordDetailsScreen.dart';

class SavePage extends StatefulWidget {
  const SavePage({Key? key}) : super(key: key);

  @override
  State<SavePage> createState() => _SavePageState();
}

class _SavePageState extends State<SavePage> {
  List<String> favorites = [];

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final favoritesJson = prefs.getStringList('favorites');
    if (favoritesJson != null) {
      favorites = favoritesJson.toList().reversed.toList();
    }
    setState(() {});
  }

  void addToFavorites(String word) {
    setState(() {
      favorites.insert(0, word);
    });
  }

  void removeFromFavorites(String word) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      favorites.remove(word);
    });

    final updatedFavoritesJson = json.encode(favorites);
    await prefs.setStringList('favorites', favorites);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: favorites.length,
        itemBuilder: (context, index) {
          final word = favorites[index];

          return ListTile(
            title: Row(
              children: [
                Expanded(
                  child: Container(
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
                ),
                IconButton(
                  icon: Icon(Icons.favorite),
                  color: Colors.red,
                  onPressed: () {
                    removeFromFavorites(word);
                  },
                ),
              ],
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
