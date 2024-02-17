import 'package:firebase_auth/firebase_auth.dart';
import 'auth_provider.dart';
import 'helper_functions.dart';

/// a class used to manage firebase authentication
class FirebaseManageUsers{
  FirebaseManageUsers._();
  /// simple regex for password,
  /// that checks the password has 6-32 chars or not
  static String regex = r"^.{6,32}$";

  /// complex regex that validate a email id with the general email standards
  static String emailRegex = r"^(?=.{1,64}@)([a-zA-Z\d]+([\.\-_]?[a-zA-Z\d]+)*)@(?=.{4,63}$)([a-zA-Z\d]+([\.\-]?[a-zA-Z\d]+)*\.[a-zA-Z\d]{2,})$";

  /// initiate a listener for user authentication changes
  static void listenToFirebaseAuthStateChanges(AuthenticationProvider authProvider){
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if(user == null){
        authProvider.email = null;
        authProvider.authState = AuthState.loggedOut;
        authProvider.notify();
      }else{
        authProvider.authState = AuthState.loggedIn;
        authProvider.userName = user.displayName;
        authProvider.email = user.email;
        authProvider.notify();
      }
    });
  }

  /// checks whether any account exist with the provided [email]
  static Future<bool> doesAccountExistWithThis(String email, AuthenticationProvider authProvider)async{
    bool isAccountExists = false;
    try{
      final signInMethods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
      if(signInMethods.isNotEmpty){
        isAccountExists =  true;
      }
    }on FirebaseAuthException catch(e){
      authProvider.authExceptionType = AuthExceptions.typeOf[e.code];
    }catch (e) {
      printToConsole("Exception in FirebaseManageUsers.loginWithEmailPassword: ${e.toString()}");
      authProvider.authExceptionType = AuthExceptionType.unknown;
    }
    return isAccountExists;
  }

  /// login using [email] and [password]
  static Future<bool> loginWithEmailPassword(String email, String password, AuthenticationProvider authProvider)async{
    bool isLoginSuccess = false;
    try {
      final userCredentials = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      if(userCredentials.user != null){
        isLoginSuccess = true;
      }
    } on FirebaseAuthException catch (e) {
      authProvider.authExceptionType = AuthExceptions.typeOf[e.code];
    }catch (e) {
      printToConsole("Exception in FirebaseManageUsers.loginWithEmailPassword: ${e.toString()}");
      authProvider.authExceptionType = AuthExceptionType.unknown;
    }
    return isLoginSuccess;
  }

  /// registration with [email], [password] and [name]
  static Future<bool> registerWithEmailPasswordName(String email, String password, String name, AuthenticationProvider authProvider) async {
    bool isRegistrationSuccessful = false;
    try {
      final userCredentials = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      if(userCredentials.user != null){
        userCredentials.user!.updateDisplayName(name);
        isRegistrationSuccessful = true;
      }
    } on FirebaseAuthException catch (e) {
      authProvider.authExceptionType = AuthExceptions.typeOf[e.code];
    }catch (e) {
      printToConsole("Exception in FirebaseManageUsers.loginWithEmailPassword: ${e.toString()}");
      authProvider.authExceptionType = AuthExceptionType.unknown;
    }
    return isRegistrationSuccessful;
  }

  /// sends password reset email to provided [email]
  static Future<bool> sendPasswordResetEmail(String email, AuthenticationProvider authProvider) async {
    bool isPasswordResetEmailSent = false;
    try{
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      isPasswordResetEmailSent = true;
    }on FirebaseAuthException catch(e){
      authProvider.authExceptionType = AuthExceptions.typeOf[e.code];
    }catch(e){
      printToConsole("Exception in FirebaseManageUsers.sendPasswordResetEmail: ${e.toString()}");
      authProvider.authExceptionType = AuthExceptionType.unknown;
    }
    return isPasswordResetEmailSent;
  }

  /// updates password with [resetCode] and [newPassword]
  static Future<bool> updatePassword(String resetCode, String newPassword, AuthenticationProvider authProvider) async {
    bool isPasswordResetCompleted = false;
    try {
      await FirebaseAuth.instance.confirmPasswordReset(code: resetCode, newPassword: newPassword);
      isPasswordResetCompleted = true;
    } on FirebaseAuthException catch (e) {
      authProvider.authExceptionType = AuthExceptions.typeOf[e.code];
    }catch (e) {
      printToConsole("Exception in FirebaseManageUsers.loginWithEmailPassword: ${e.toString()}");
      authProvider.authExceptionType = AuthExceptionType.unknown;
    }
    return isPasswordResetCompleted;
  }

  /// logs out the user
  static Future<void> signOut(AuthenticationProvider authProvider) async {
    try {
      await FirebaseAuth.instance.signOut();
    } on FirebaseAuthException catch (e) {
      authProvider.authExceptionType = AuthExceptions.typeOf[e.code];
    }catch (e) {
      printToConsole("Exception in FirebaseManageUsers.loginWithEmailPassword: ${e.toString()}");
      authProvider.authExceptionType = AuthExceptionType.unknown;
    }
  }
}


