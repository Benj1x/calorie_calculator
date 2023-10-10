bool loginSucces = false;
void updateLoggedIn(Future<bool> suc) async {

  loginSucces = suc as bool;

}

bool GetLoggedIn(){

  return loginSucces;

}

CalorieData CalorieDatas = new CalorieData();

class CalorieData{
  String ID = "";
  String consumed = "";
  String Date = "";
}

UserData userData = new UserData();

class UserData{
  String ID = "";
  String Username = "";
  String CalorieGoal = "";

  void SetUserID(String uID){
    ID = uID;
  }
  void SetUsername(String uname){
    Username = uname;
  }
  void SetCalorieGoal(String goal)
  {
    CalorieGoal = goal;
  }

  String GetUserID(){
    return ID;
  }
  String GetUsername(){
    return Username;
  }
  String GetCalorieGoal()
  {
    return CalorieGoal;
  }

  List<String> GetAsList()
  {
    final fixedLengthList = List<String>.filled(3, "");
    fixedLengthList[0] = ID;
    fixedLengthList[1] = Username;
    fixedLengthList[2] = CalorieGoal;
    return fixedLengthList;
  }

}
