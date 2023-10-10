import 'package:mysql_client/mysql_client.dart';
class DB{
  static const hostConnect = "localhost:33062";
}


final pool = MySQLConnectionPool(
  host: '127.0.0.1',
  port: 3306,
  userName: 'root',
  password: '1234',
  maxConnections: 1,
  databaseName: 'calorieCal', // optional,
);
void SignUp(String email, String username, String password) async {
  bool UserExists = await CheckUserExists(email, password);

  if (UserExists) {
    //Display error
    return;
  }

  CreateNewUser(email, username, password);

  bool test = await TryLogin(username, password);

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

String UserID = "1";
String Username = "";
String CalorieGoal = "";
/**
 * Log in, what else is there to say
 */
Future<bool> Login(String Email, String password) async
{
  return await TryLogin(Email, password);
}
/**
 * Attempts to login the user, on success saves the UserID (Should also save username), and stores it for later use
 */

Future<bool> TryLogin(String email, String password) async
{
  bool loginSucces = false;
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

    UserID = SplitNum[1];

    final usernameSubString = SplitString[2].split("Username: ");
    Username = usernameSubString[1];

    final calorieSubString = SplitString[4].split("CalorieGoal: ");
    CalorieGoal = calorieSubString[1].replaceAll("}", "");
    loginSucces = true;
  });

  conn.close();

  return loginSucces;
}
/**
 * Adds calories for a meal using the [UserID] & [CaloriesToAdd] variables
 * Function also creates a DateTime.now variable, to use for tracking the time,
 * this way we can use the users local time, instead of the server local time
 */

void AddCalories(/*String UserID, */String CaloriesToAdd) async{
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
      "INSERT INTO Calories (UserID, CaloriesConsumed, Time) VALUES ('"+UserID+"', '"+ CaloriesToAdd +"', '"+ DTNow +"');");

  await conn.close();
}

class Calories{
  String ID = "";
  String consumed = "";
  String Date = "";
}

/**
 * Getter function for showing all calorie data for the user
 * TODO: alternate functions would be [main.GetCaloriesDay] and a delete function
 */
<Calories>{} GetAllCalories(/*String UserID*/) async{
  final conn = await MySQLConnection.createConnection(
    host: '127.0.0.1',
    port: 3306,
    userName: 'root',
    password: '1234',
    databaseName: 'calorieCal', // optional,
  );

  await conn.connect();
  var res = await conn.execute(
      "SELECT * FROM Calories WHERE UserID='"+UserID+"';", {}, true);

  var Records = <Calories>{};
  String recordedAt = "";
  String CalorieID = "";
  String ConsumedCalories = "";

  res.rowsStream.listen((row) {
    String something = row.toString();
    String cRow = row.assoc().toString();
    final SplitString = cRow.split(", ");

    CalorieID = SplitString[0].split("{CalorieID: ").toString();

    ConsumedCalories = SplitString[2].split(", CaloriesConsumed: ").toString();

    final RecordedSubstring = SplitString[3].split(", Time: ").toString();

    ConsumedCalories = RecordedSubstring[1].replaceAll("}", "").toString();


  });

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