import 'package:firebase_auth/firebase_auth.dart';
import 'auth_provider.dart';
import 'helper_functions.dart';

class FirebaseManageUsers{
  FirebaseManageUsers._();
  static String regex = r"^.{6,32}$";
  static String emailRegex = r"^(?=.{1,64}@)([a-zA-Z\d]+([\.\-_]?[a-zA-Z\d]+)*)@(?=.{4,63}$)([a-zA-Z\d]+([\.\-]?[a-zA-Z\d]+)*\.[a-zA-Z\d]{2,})$";

  static void listenToFirebaseAuthStateChanges(AuthProvider authProvider){
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

  static Future<bool> doesAccountExistWithThis(String email, AuthProvider authProvider)async{
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

  static Future<bool> loginWithEmailPassword(String email, String password, AuthProvider authProvider)async{
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

  static Future<bool> registerWithEmailPasswordName(String email, String password, String name, AuthProvider authProvider) async {
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
  static Future<bool> sendPasswordResetEmail(String email, AuthProvider authProvider) async {
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

  static Future<bool> updatePassword(String resetCode, String newPassword, AuthProvider authProvider) async {
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
  static Future<void> signOut(AuthProvider authProvider) async {
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


