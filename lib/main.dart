import 'package:calorie_calculator/scenes/CalorieHistory.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:developer';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:calorie_calculator/Scenes/Home.dart';
import 'package:calorie_calculator/Scenes/Login.dart';
import 'package:calorie_calculator/Scenes/Recipes.dart';
import 'package:calorie_calculator/Scenes/CustomRecipe.dart';
import 'package:calorie_calculator/Scenes/ManualCalories.dart';
import 'package:mysql_client/mysql_client.dart';

//https://docs.flutter.dev/cookbook/forms/retrieve-input?gclid=CjwKCAjwscGjBhAXEiwAswQqNNMncqgxm4z0UjIb3vNB7dsvuoK1BDAt0j2WMhvTdjqQGuLyOQnGrhoCKwIQAvD_BwE&gclsrc=aw.ds
//https://api.flutter.dev/flutter/material/TextField-class.html
//https://flutterawesome.com/mysql-client-for-dart-written-in-dart/

class Data {
  var UserID;
  //int counter;
  //String dateTime;
  Data({this.UserID});
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Calorie Calculator',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.tealAccent),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  var Calories= <Map>[];
  var UserID = 0;

  void getNext(){
    current = WordPair.random();
    notifyListeners();
  }

  var favorites = <WordPair>[];

  void toggleFavorites() {
    if (favorites.contains(current)){
      favorites.remove(current);
    } else{
      favorites.add(current);
    }
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  var selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    //+appState.CreateNewUser("Some@email.com", "TestUser", "abc123");
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = LoginPage();
        break;
      case 1:
        page = Recipes();
        break;
      case 2:
        page = CustomRecipe();
        break;
      case 3:
        page = ManualCalories();
        break;
      case 4:
        page = CalorieHistory();
        break;
      default:
        page = Home();
        //throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  backgroundColor: Color(0xff121212),
                  extended: constraints.maxWidth >= 600,
                  destinations: [
                    NavigationRailDestination(
                      icon: Icon(Icons.home, color: Color(0xff05dfc9)),
                      label: Text('Home',
                        style: TextStyle(
                        color: Color(0xffffffff),
                      ),
                      ),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.article, color: Color(0xff05dfc9)),
                      label: Text('Recipes',
                        style: TextStyle(
                          color: Color(0xffffffff),
                        ),),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.add_circle, color: Color(0xff05dfc9)),
                      label: Text('Add Recipe',
                        style: TextStyle(
                          color: Color(0xffffffff),
                        ),),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.edit, color: Color(0xff05dfc9)),
                      label: Text('Manual calories',
                        style: TextStyle(
                          color: Color(0xffffffff),
                        ),),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.history, color: Color(0xff05dfc9)),
                      label: Text('Calories history',
                        style: TextStyle(
                          color: Color(0xffffffff),
                        ),),
                    ),
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) {
                    setState(() {
                      selectedIndex = value;
                      if (selectedIndex == 1){
                          //appState.GetCalHistory();
                      }
                    });
                  },
                ),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page,
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}
