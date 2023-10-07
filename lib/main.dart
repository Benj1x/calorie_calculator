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

  /**
   * Creates a new users with [email], [username], and a hashed version of [password]
   */
  void CreateNewUser(String email, String username, String password) async {
    final conn = await MySQLConnection.createConnection(
      host: '127.0.0.1',
      port: 3306,
      userName: 'root',
      password: '1234',
      databaseName: 'calorieCal', // optional,
    );

    await conn.connect();

    var res = await conn.execute(
        "INSERT INTO users (Email, Username, Password) VALUE ('" + email + "', '" + username + "', MD5('"+ password + "'));");
    print(res.affectedRows);
    await conn.close();
  }

  void SignUp(String email, String username, String password) async {
    bool UserExists = await CheckUserExists(email, password);

    if (UserExists) {
      //Display error
      return;
    }

    CreateNewUser(email, username, password);

    UserID = await TryLogin(username, password);

    notifyListeners();
  }

  /**
   * Verifies that a user has an account with the [email], since the username can be the same for multiple users
   */
  Future<bool> CheckUserExists(String email, String password) async{
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
        "SELECT * FROM users WHERE Email='" + email + "'", {}, true);
    conn.close();

    //A very digusting way of returning TRUE if there is a user, and FALSE if there isn't
    if (await res.rowsStream.isEmpty){
      return false;
    } {
      return true;
    }
  }

  /**
   * Log in, what else is there to say
   */
  void Login(String username, String password) async {
    UserID = await TryLogin(username, password);
    notifyListeners();
  }

  /**
   * Attempts to login the user, on success saves the UserID (Should also save username), and stores it for later use
   */
  Future<int> TryLogin(String email, String password) async
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
        "SELECT * FROM users WHERE Email='" + email + "' AND Password=MD5('"+password+"')", {}, true);

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

  /**
   * Adds calories for a meal using the [UserID] & [CaloriesToAdd] variables
   * Function also creates a DateTime.now variable, to use for tracking the time,
   * this way we can use the users local time, instead of the server local time
   */
  void AddCalories(String UserID, String CaloriesToAdd) async{
    final conn = await MySQLConnection.createConnection(
      host: '127.0.0.1',
      port: 3306,
      userName: 'root',
      password: '1234',
      databaseName: 'calorieCal', // optional,
    );
    final DTNow = DateTime.now().toString();
    await conn.connect();
    var res = await conn.execute(
    "INSERT INTO Calories (UserID, CaloriesConsumed, Time) VALUES ('"+UserID+"', '"+ CaloriesToAdd +"', "+ DTNow +");");

    await conn.close();
  }

  /**
   * Getter function for showing all calorie data for the user
   * TODO: alternate functions would be [main.GetCaloriesDay] and a delete function
   */
  void GetAllCalories(String UserID) async{
    final conn = await MySQLConnection.createConnection(
      host: '127.0.0.1',
      port: 3306,
      userName: 'root',
      password: '1234',
      databaseName: 'calorieCal', // optional,
    );
    final DTNow = DateTime.now().toString();
    await conn.connect();
    var res = await conn.execute(
        "SELECT * FROM Calories WHERE UserID='"+UserID+"');");

    await conn.close();
  }

  /**
   * Adds a recipe to the users favorites using the user and recipe ID
   */
  void AddRecipeToFavorites(String UserID, String RecipeID) async{
    final conn = await MySQLConnection.createConnection(
      host: '127.0.0.1',
      port: 3306,
      userName: 'root',
      password: '1234',
      databaseName: 'calorieCal', // optional,
    );

    await conn.connect();
    var res = await conn.execute(
        "INSERT INTO favorites (UserID, RecipeID) VALUES ('"+UserID+"', '"+ RecipeID+"');");

    await conn.close();
  }

  /**
   * Gets a users favorite recipes to the users favorites using the user and recipe ID
   */
  void GetFavorites(String UserID, String RecipeID) async{
    final conn = await MySQLConnection.createConnection(
      host: '127.0.0.1',
      port: 3306,
      userName: 'root',
      password: '1234',
      databaseName: 'calorieCal', // optional,
    );

    await conn.connect();
    var res = await conn.execute(
        "SELECT * FROM favorites WHERE UserID='"+UserID+"');");

    await conn.close();
  }

  /**
   * Removes a users favorite recipe
   */
  void RemoveFavorites(String UserID, String RecipeID) async{
    final conn = await MySQLConnection.createConnection(
      host: '127.0.0.1',
      port: 3306,
      userName: 'root',
      password: '1234',
      databaseName: 'calorieCal', // optional,
    );

    await conn.connect();
    var res = await conn.execute(
        "DELETE FROM favorites WHERE UserID='"+UserID+"' AND RecipeID='"+RecipeID+"');");

    await conn.close();
  }

  /**
   * A general getter function for getting all info
   */
  void GetRecipeFromID(String RecipeID) async{
    final conn = await MySQLConnection.createConnection(
      host: '127.0.0.1',
      port: 3306,
      userName: 'root',
      password: '1234',
      databaseName: 'calorieCal', // optional,
    );

    await conn.connect();
    var res = await conn.execute(
        "SELECT * recipes WHERE RecipeID='"+RecipeID+"');");

    await conn.close();
  }

  /**
   * A general getter function for getting all info
   */
  void GetRecipeFromSkeleton(String RecipeID) async{
    final conn = await MySQLConnection.createConnection(
      host: '127.0.0.1',
      port: 3306,
      userName: 'root',
      password: '1234',
      databaseName: 'calorieCal', // optional,
    );

    await conn.connect();
    var res = await conn.execute(
        "SELECT RecipeTitle, Categories, Description FROM recipes WHERE RecipeID='"+RecipeID+"');");

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
    //+appState.CreateNewUser("Some@email.com", "TestUser", "abc123");
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = Login();
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
