# Flutter Easy Login
An Easy and Simple UI for Authentication.
* Login with email and password.
* Register with Email, Name and Password.
* Password reset.
* Works with Firebase or your Authentication Service.

## Features

![Registration screen shot](../assets/start.png?raw=true)
![Registration screen shot](../assets/login.png?raw=true)
![Registration screen shot](../assets/register.png?raw=true)

## Usage

Implementation of this easy.
* First in the main() method add this statement("WidgetsFlutterBinding.ensureInitialized();") at the start.
* If you are using firebase then initialize firebase("await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);").
* Then in the runApp() method create the AuthProvider passing the method "initializeLoginState()" in its constructor.

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(ChangeNotifierProvider(create: (context) => AuthProvider(
      FirebaseManageUsers.listenToFirebaseAuthStateChanges
  ),
    child: const MyApp(),));
}
```
** FirebaseManageUser is a class that has all the required implementations for firebase auth **

* If you are not using Firebase then no need to initialize Firebase
* but in the AuthProvider constructor need to pass the method "initializeLoginState" that has the parameter of AuthProvider
* and that checks for the login state then update the authState field in the AuthProvider to appropriate State
```dart
void initializeLoginState(AuthProvider authProvider){
  bool isLoggedIn = checkUserIsLoggedInOrNot();
  if(isLoggedIn){
    authProvider.authState = AuthState.loggedIn;
    authProvider.userName = userName;//optional
    authProvider.email = email;//optional
    authProvider.notify();
  }else {
    authProvider.email = null; //optional
    authProvider.authState = AuthState.loggedOut;
    authProvider.notify();
  }
}
```
* After the above implementation you need to use LoginPage widget as the first screen and need to pass all the required arguments as mentioned below:
    * appName: The Name Of Your App to show in all login, Register pages
    * child: The First screen user will see if logged in
    * passwordRegex: The Regex pattern that password must meet i.e password pattern
    * invalidPasswordMessage: A message to be displayed to the user when the password does not match with [passwordRegex] this should not be null if [passwordRequirements] is null and vice versa. If want to show simple one message use this or use [passwordRequirements] to display particular message
    * passwordRequirements: A map containing pairs of regex of Each password requirements and message to display e.g {r'(?=.*[0-9]).*' : "Password must contains at least one digit"}. This map is used to display particular messages of invalid password. if this is null then [invalidPasswordMessage] should not be null and vice versa.
    * isUsingFirebaseAuth: Tells should use default [FirebaseAuth] auth methods for [login], [checkEmail], [register], [sendPasswordResetEmail], [logout]. By default it is false. If it is true then no need to provide authentication methods, if it false then need to provide all the authentication methods for [login], [checkEmail], [register], [sendPasswordResetEmail], [logout].
    * checkEmail: If [isUsingFirebaseAuth] is true then default [FirebaseAuth.fetchSignInMethodsForEmail] will be used. Other wise need to provide this method. The function that accepts an email and checks the email and returns [true] if the user is already exists with the email, otherwise returns [false] if the user is new. [AuthProvider] is used to update the widget to password widget if user is exists with the email. And if there is any thing wrong in email then assign appropriate [AuthExceptionType] to the [AuthProvider.authExceptionType]
    * login: If [isUsingFirebaseAuth] is true then default [FirebaseAuth.signInWithEmailAndPassword] will be used. Other wise need to provide this method. The function that accepts email and password and return true if the email and password are valid and let user login other wise return false. And if email and password does not match or any thing wrong in email or password then assign appropriate [AuthExceptionType] to the [AuthProvider.authExceptionType]
    * register: If [isUsingFirebaseAuth] is true then default [FirebaseAuth.createUserWithEmailAndPassword] will be used. Other wise need to provide this method. The function that accepts email, password and name and create an account with the provided details. If any error is there then need to assign appropriate [AuthExceptionType] to the [AuthProvider.authExceptionType]
    * sendPasswordResetEmail: If [isUsingFirebaseAuth] is true then default [FirebaseAuth.sendPasswordResetEmail] will be used. Other wise need to provide this method. The function that accepts an email and sends a password reset email to the provided email. Returns [true] if the password reset email sends successfully otherwise returns false. If any error is there then need to assign appropriate [AuthExceptionType] to the [AuthProvider.authExceptionType]
    * signOut: If [isUsingFirebaseAuth] is true then default [FirebaseAuth.signOut] will be used. Other wise need to provide this method. The function that sign out the user. If any error is there then need to assign appropriate [AuthExceptionType] to the [AuthProvider.authExceptionType]
* Example for one Authentication method:
```dart
    Future<bool> checkEmail(String email, AuthProvider authProvider)async{
    bool isAccountExists = false;
    try{
      isAccountExists = await doesAnyAccountExistWithThisEmail(email);
    }on FirebaseAuthException catch(e){
      authProvider.authExceptionType = AuthExceptions.typeOf[e.code];
    }catch (e) {
      printToConsole("Exception in FirebaseManageUsers.loginWithEmailPassword: ${e.toString()}");
      authProvider.authExceptionType = AuthExceptionType.unknown;
    }
    return isAccountExists;
  }
```

