bool loginSucces = false;
void updateLoggedIn(Future<bool> suc) async {

  loginSucces = suc as bool;

}

bool GetLoggedIn(){

  return loginSucces;

}