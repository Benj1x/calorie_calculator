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
