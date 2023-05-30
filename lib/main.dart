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

  void GetCalHistory() async {
    Calories = await GetHistory();
    notifyListeners();
  }

  void Login(String username, String password) async {
    UserID = await TryLogin(username, password);
    notifyListeners();
  }

  Future<int> TryLogin(String username, String password) async
  {
    Future<int> UserID = Future<int>.value(0);
    final conn = await MySQLConnection.createConnection(
      host: '127.0.0.1',
      port: 3306,
      userName: 'root',
      password: '1234',
      databaseName: 'calorieCal', // optional,
    );

    await conn.connect();
    var res = await conn.execute(
        "SELECT * FROM users WHERE Username='" + username + "'", {}, true);

    res.rowsStream.listen((row) {
      String cRow = row.assoc().toString();
      final SplitString = cRow.split(", ");
      final SplitNum = SplitString[0].split(": ");
      print(SplitNum[1]);
      var intID = int.parse(SplitNum[1]);
      UserID = Future<int>.value(intID);
    });

    conn.close();

    return UserID;


  }

  void SignUp(String username, String password) async {
    bool UserExists = await CheckUserExists(username, password);

    if (UserExists) {
      //Display error
      return;
    }

    CreateNewUser(username, password);

    UserID = await TryLogin(username, password);

    notifyListeners();
  }

  Future<bool> CheckUserExists(String username, String password) async{
    Future<int> UserID = Future<int>.value(0);
    final conn = await MySQLConnection.createConnection(
      host: '127.0.0.1',
      port: 3306,
      userName: 'root',
      password: '1234',
      databaseName: 'calorieCal', // optional,
    );

    await conn.connect();
    var res = await conn.execute(
        "SELECT * FROM users WHERE Username='" + username + "'", {}, true);
    conn.close();

    //A very digusting way of returning TRUE if there is a user, and FALSE if there isn't
    if (await res.rowsStream.isEmpty){
      return false;
    } {
      return true;
    }
  }

  /**
   * Won't work until DB has been updated to use passwords and auto set userIDs (Statement does work though)
   */
  void CreateNewUser(String username, String password) async {
    final conn = await MySQLConnection.createConnection(
      host: '127.0.0.1',
      port: 3306,
      userName: 'root',
      password: '1234',
      databaseName: 'calorieCal', // optional,
    );

    await conn.connect();

    var res = await conn.execute(
      "INSERT INTO users VALUES (NULL, '" + username +"', '"+ password+"', 0)");

    print(res.affectedRows);
    await conn.close();
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
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPage();
}

class _SettingsPage extends State<SettingsPage>{
  @override

  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    final myUserController = TextEditingController();
    final myPassController = TextEditingController();

    @override
    void dispose(){
      myUserController.dispose();
      myPassController.dispose();
      super.dispose();
    }

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Login'),
            //BigCard(word: word),
            SizedBox(height: 10),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [SizedBox(
              width: 250,
              child: TextField(
                controller: myUserController,
                obscureText: false,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Username',
                ),
              ),
            ),
            SizedBox(
            width: 250,
            child: TextField(
              controller: myPassController,
              obscureText: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'password',
              ),
            ),
          ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                    ElevatedButton(
                      onPressed: () async {
                        //print(myUserController.text +" " + myPassController.text);
                        appState.Login(myUserController.text, myPassController.text);//.timeout(Duration(seconds: 5), onTimeout: () {
                      },
                      child: Text("Log In")
                    ),
                      ElevatedButton(
                          onPressed: () async {

                            appState.SignUp(myUserController.text, myPassController.text);
                          },
                          child: Text("Sign Up")
                      )
                    ]
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
/*
Future<int> TryLogin(String username, String password) async
{
  Future<int> UserID = Future<int>.value(0);
  final conn = await MySQLConnection.createConnection(
    host: '127.0.0.1',
    port: 3306,
    userName: 'root',
    password: '1234',
    databaseName: 'calorieCal', // optional,
  );

  await conn.connect();
  var res = await conn.execute(
      "SELECT * FROM users WHERE Username='"+username+"'", {}, true);

  res.rowsStream.listen((row) {
    String cRow = row.assoc().toString();
    final SplitString = cRow.split(", ");
    final SplitNum = SplitString[0].split(": ");
    print(SplitNum[1]);
    var intID = int.parse(SplitNum[1]);
    UserID = Future<int>.value(intID);
  });

  return UserID;

}
*/
class UserNameTextField extends StatelessWidget {
  const UserNameTextField({super.key});

  //final myController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 250,
      child: TextField(
        //controller: myController,
        obscureText: false,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Username',
        ),
      ),
    );
  }
}

class ObscureTextField extends StatelessWidget {
  const ObscureTextField({super.key});

  final label = "";

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 250,
      child: TextField(
        obscureText: true,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'password',
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