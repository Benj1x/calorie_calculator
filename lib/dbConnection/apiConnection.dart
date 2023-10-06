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

//SELECT * FROM calories WHERE userID=SomeID;

//login
//SELECT * FROM users WHERE users.Email = '" + loginEmail (check if pass matches)
//Save user ID

//Get recipes
//SELECT recipes.title, recipes.price, recipes.category FROM recipes;

//Add to calories
//INSERT INTO Calories VALUES (4, 0, NOW(), 1);

//Add to users
//INSERT INTO users VALUES (*ID*, username/email, password, caloriegoal);