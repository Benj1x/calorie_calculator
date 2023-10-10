import 'dart:collection';

import 'package:mysql_client/mysql_client.dart';
import 'package:calorie_calculator/tempUtils.dart';

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

class doDB{

  void SignUp(String email, String username, String password) async {
    bool UserExists = await CheckUserExists(email, password);

    if (UserExists) {
      //Display error
      return;
    }

    CreateNewUser(email, username, password);

    //bool test = await TryLogin(username, password);

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
    //return await TryLogin(Email, password);
    return false;
  }

  /**
   * Attempts to login the user, on success saves the UserID (Should also save username), and stores it for later use
   */
  Future<List<String>> TryLogin(String email, String password) async
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

    UserData userData = new UserData();

    res.rowsStream.listen((row) {
      String cRow = row.assoc().toString();
      final SplitString = cRow.split(", ");
      final SplitNum = SplitString[0].split(": ");

      userData.ID = SplitNum[1];

      final usernameSubString = SplitString[2].split("Username: ");
      userData.Username = usernameSubString[1];

      final calorieSubString = SplitString[4].split("CalorieGoal: ");
      userData.CalorieGoal = calorieSubString[1].replaceAll("}", "");
      loginSucces = true;
    });

    conn.close();

    return userData.GetAsList();
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



  /**
   * Getter function for showing all calorie data for the user
   * TODO: alternate functions would be [main.GetCaloriesDay] and a delete function
   */
  Future<Map<String, String>> GetAllCalories(/*String UserID*/) async{
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

  final Map<String, String> Calories = HashMap();

  int i = 0;

  res.rowsStream.listen((row) {
  String cRow = row.assoc().toString();
  final SplitString = cRow.split(", ");

  String recordedAt = "";
  String CalorieID = "";
  String ConsumedCalories = "";

  CalorieID = SplitString[0].split("{CalorieID: ").toString();

  ConsumedCalories = SplitString[2].split(", CaloriesConsumed: ").toString();

  final RecordedSubstring = SplitString[3].split(", Time: ").toString();

  recordedAt = RecordedSubstring[1].replaceAll("}", "").toString();

  Calories[recordedAt] = ConsumedCalories;
  i++;
  });

  await conn.close();
  return Calories;
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
  "SELECT * FROM recipes WHERE RecipeID="+RecipeID+";", {}, true);

  res.rowsStream.listen((row) {
  String cRow = row.assoc().toString();

  final RecipeID = cRow.split("RecipeID: ")[1].split(", RecipeTitle")[0]; //This is fucking disgusting, but I love it
  final RecipeTitle = cRow.split(", RecipeTitle: ")[1].split(", Categories:")[0];
  final RecipeCategories = cRow.split(", Categories: ")[1].split(", Description:")[0];
  final RecipeDescription = cRow.split(", Description: ")[1].split(", Nutrition:")[0];
  final RecipeNutrition = cRow.split(", Nutrition: ")[1].split(", Ingredients:")[0];
  final RecipeIngredients = cRow.split(", Ingredients: ")[1].split(", CourseOfAction:")[0];
  final RecipeAction = cRow.split(", CourseOfAction: ")[1].split(", StandardServing:")[0];
  final RecipeStandardServing = cRow.split(", StandardServing:")[1].split(", CookTime")[0];
  final RecipeCookTime = cRow.split(", CookTime: ")[1].split(", TotalTime:")[0];
  final RecipeTotalTime = cRow.split(", TotalTime: ")[1].split(", DateAdded:")[0];
  final RecipeDateAdded = cRow.split(", DateAdded: ")[1].split("}")[0];

  });
  /* ADD RECIPE
  INSERT INTO recipes
  (RecipeTitle, Categories, Description, Nutrition, Ingredients, CourseOfAction, StandardServing, CookTime, TotalTime, DateAdded)
  VALUES ('Spaghetti m. Grønkål og Ricotta sovs', 'Lunch', 'nem og lækker placeholder', '831,5 Kcal per. potion', '150g spaghetti, 125g ricotta, 100g grønkål', 'Kog pasta, blend ricotta og grønkål i en gryde under opvarmning, når sovsen er varmet, tages den af blusset. Bland med spaghetti når den er færdig. Kryder som ønsket', '1', '8.5', '9.5', NOW());
*/

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
