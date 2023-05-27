import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:developer';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mysql_client/mysql_client.dart';

//https://docs.flutter.dev/cookbook/forms/retrieve-input?gclid=CjwKCAjwscGjBhAXEiwAswQqNNMncqgxm4z0UjIb3vNB7dsvuoK1BDAt0j2WMhvTdjqQGuLyOQnGrhoCKwIQAvD_BwE&gclsrc=aw.ds
//https://api.flutter.dev/flutter/material/TextField-class.html
//https://flutterawesome.com/mysql-client-for-dart-written-in-dart/

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
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  var Calories= <Map>[];

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

  void GetCalHistory() async {
    Calories = await GetHistory();
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
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = CalorieHistoryPage();
        break;
      case 2:
        page = SettingsPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: constraints.maxWidth >= 600,
                  destinations: [
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.favorite),
                      label: Text('History'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.settings),
                      label: Text('Settings'),
                    ),
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) {
                    setState(() {
                      selectedIndex = value;
                      if (selectedIndex == 1){
                        appState.GetCalHistory();
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

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var word = appState.current;

    IconData icon;
    if (appState.favorites.contains(word)){
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('A gamer idea:'),
            BigCard(word: word),
            SizedBox(height: 10),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () {
                    appState.getNext();
                  },
                  child: Text("Next word"),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    appState.toggleFavorites();
                  },
                  icon: Icon(icon),
                  label: Text("History"),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CalorieHistoryPage extends StatelessWidget
{
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    var calories = appState.Calories;
    print(calories);
    //for(var i = 0; i < result.length; i++){
    //  print(result[i]);
    //}

    if (calories.isEmpty) {
      return Center(
        child: Text('No favorites yet.'),
      );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('You have '
              '${calories.length} tracked days:'),
        ),
        for (var i = 0; i < calories.length; i++)

          ListTile(
            title: Text(calories[i]["Calories"].toString() + " "+ calories[i]["Date"].toString()),
          ),
      ],
    );
  }
}

/*Future<List> SendData() async{
  await conn.connect();
  var res = await conn.execute(
    "INSERT INTO Calories VALUES (NULL, 0, NOW(), 1);");

  await conn.close();
}*/

class SettingsPage extends StatelessWidget{
  @override

  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var loginState = appState.current;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('A gamer idea:'),
            //BigCard(word: word),
            SizedBox(height: 10),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () {

                    //appState = Trylogin();
                  },
                  child: Text("Save"),
                ),
                SomeTextField(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/*(bool, int) TryLogin(String username, String password){

  return (false, 0);
}
*/
class SomeTextField extends StatelessWidget {
  const SomeTextField({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 250,
      child: TextField(
        obscureText: false,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Username',
        ),
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.word,
  });

  final WordPair word;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(color: theme.colorScheme.onPrimary,);
    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Text(word.asLowerCase, style: style, semanticsLabel: "${word.first} ${word.second}"),
      ),
    );
  }
}

Future<List<Map>> GetHistory() async{
final conn = await MySQLConnection.createConnection(
    host: '127.0.0.1',
    port: 3306,
    userName: 'root',
    password: '1234',
    databaseName: 'calorieCal', // optional,
  );

  await conn.connect();
  var res = await conn.execute(
    "SELECT * FROM Calories WHERE UserID=1", {}, true);

  var CalHistory = <Map>[];

  res.rowsStream.listen((row) {
    String cRow = row.assoc().toString();
    var map = {};
    final SplitString = cRow.split(", ");
    map["Calories"] = SplitString[1];
    map["Date"] = SplitString[2];
    CalHistory.add(map);

  });
  await conn.close();

  return CalHistory;
}