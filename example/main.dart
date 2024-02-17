import 'package:flutter/material.dart';
import 'package:flutter_easy_login/flutter_easy_login.dart';
import 'package:flutter_easy_login/models/auth_provider.dart';
import 'package:provider/provider.dart';

String? userId;
String? userName;
String? userEmail;

void main(){
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthenticationProvider>(
    create: (context) => AuthenticationProvider((
      initializeLoginState
  )))
      ],
      child: const MyApp()
    )
  );
}

void initializeLoginState(AuthenticationProvider authProvider){
  bool isLoggedIn = checkUserIsLoggedInOrNot();
  if(isLoggedIn){
    authProvider.authState = AuthState.loggedIn;
    authProvider.userName = userName;//optional
    authProvider.email = userEmail;//optional
    authProvider.notify();
  }else {
    authProvider.email = null; //optional
    authProvider.authState = AuthState.loggedOut;
    authProvider.notify();
  }
}

bool checkUserIsLoggedInOrNot(){
  return userId != null;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginPage(
          appName: "My App",
          passwordRegex: r"^.{6,32}$",

          // if you want to user firebase Auth then make [isUsingFirebaseAuth] to true
          // isUsingFirebaseAuth: true,

          // if you have your own authentication service then use your own
          checkEmail: AuthBackend().checkEmail,
          login: AuthBackend().loginWithEmailPassword,
          register: AuthBackend().registerWithEmailPasswordName,
          sendPasswordResetEmail: AuthBackend().sendPasswordResetEmail,
          signOut: AuthBackend().signOut,
          
          child: const MyHomePage()),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("App Bar"),
      ),
      body: const Center(
        child: Text("MY APP"),
      ),
    );
  }
}

class AuthBackend{
  Future<bool> checkEmail(String email, AuthenticationProvider authProvider)async{
    /* calls the backend to check any account exist with this email id */
    final matchedUsers = userDataBase.where((user) => user["email"] == email);
    if(matchedUsers.isNotEmpty){
      return true;
    }else{
      return false;
    }
  }

  Future<bool> loginWithEmailPassword(String email, String password, AuthenticationProvider authProvider)async{
    final matchedUsers = userDataBase.where((user) => user["email"] == email).toList();
    if(matchedUsers.isNotEmpty && matchedUsers[0]["password"] == password){
      return true;
    }else{
      return false;
    }
  }

  Future<bool> registerWithEmailPasswordName(String email, String password, String name, AuthenticationProvider authProvider) async {
    userDataBase.add(
      {
        "id": UniqueKey().toString(),
        "email": email,
        "name": name,
        "password": password
    });
    return await checkEmail(email, authProvider);
  }

  Future<bool> sendPasswordResetEmail(String email, AuthenticationProvider authProvider) async {
    // Todo implement the send password reset email
    return true;
  }

  Future<bool> updatePassword(String resetCode, String newPassword, AuthenticationProvider authProvider) async {
    // Todo implement for checking resetCode
    // if resetCode is correct
    final currentUserEmail = userEmail;
    final getUser = userDataBase.where((user) => user["email"] == currentUserEmail).toList();
    if(getUser.isNotEmpty){
      getUser[0]["password"] = newPassword;
    }
    return true;
  }

  Future<void> signOut(AuthenticationProvider authProvider) async {
    userEmail = null;
    userName = null;
    userId = null;
    authProvider.userName = null;
    authProvider.email = null;
    authProvider.notify();
  }
}

List<Map<String, String>> userDataBase = [
  {
    "id": "user1",
    "email": "asdf@gmail.com",
    "name": "asdf",
    "password": "1234"
  },
  {
    "id": "user2",
    "email": "johny@gmail.com",
    "name": "johny",
    "password": "sdjflsfs"
  },
  {
    "id": "user3",
    "email": "honey@gmail.com",
    "name": "honey",
    "password": "sldkfjsldfsldij"
  },

];



