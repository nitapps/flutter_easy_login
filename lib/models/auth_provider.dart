import 'dart:core';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// the provider that manage the authentication and auth changes
///
/// this provider need to be created in the [main] method - [runApp] method with
/// the [ChangeNotifierProvider]
class AuthenticationProvider extends ChangeNotifier{
  AuthState authState = AuthState.loggedOut;
  String? userName;
  String? email;
  bool isLoading = false;

  /// an enum represents the firebase exception types based on exception codes.
  ///
  /// can be also used with out firebase login, Use consts in [AuthExceptions]
  ///
  /// Can get message based on this type with the map of [messageOfType] in class [AuthExceptions]
  ///
  /// used to display error messages in login, register, reset/update password.
  AuthExceptionType? authExceptionType;

  /// checks the user is logged in or not and based on that updates the
  /// [email] and [authState]
  final void Function(AuthenticationProvider) initializeLoginState;

  AuthenticationProvider(this.initializeLoginState){
    initializeLoginState(this);
  }

  void notify(){
    notifyListeners();
  }

  /// logout
  Future<void> doLogout(AuthenticationProvider authProvider, Future<void> Function(AuthenticationProvider) logout) async {
    isLoading = true;
    authExceptionType = null;
    notifyListeners();
    await logout(authProvider);
    email = null;
    authState = AuthState.loggedOut;
    isLoading = false;
    notifyListeners();
  }

  /// check whether any account exist with the [email]
  Future<bool> isAccountExistWithThis(String email, AuthenticationProvider authProvider, Future<bool> Function(String email, AuthenticationProvider) checkEmail) async {
    isLoading = true;
    authExceptionType = null;
    this.email = null;
    notifyListeners();
    bool result = await checkEmail(email, authProvider);
    this.email = email;
    isLoading = false;
    notifyListeners();
    return result;
  }

  /// login with [email] and [password]
  Future<bool> loginWith(String email, String password, AuthenticationProvider authProvider, Future<bool> Function(String,String, AuthenticationProvider) login) async {
    isLoading = true;
    authExceptionType = null;
    notifyListeners();
    bool isLoginSuccess = false;
    final result = await login(email, password, authProvider);
    if(result){
      if(FirebaseAuth.instance.currentUser != null){
        authState = AuthState.loggedIn;
        userName = FirebaseAuth.instance.currentUser!.displayName;
        email = FirebaseAuth.instance.currentUser!.email!;
        notifyListeners();
        isLoginSuccess =  true;
      }
    }
    isLoading = false;
    notifyListeners();
    return isLoginSuccess;
  }

  /// register with [email], [password], [name]
  Future<bool> registerWith(String email, String password, String name, AuthenticationProvider authProvider, Future<bool> Function(String, String, String, AuthenticationProvider) register) async {
    isLoading = true;
    authExceptionType = null;
    notifyListeners();
    bool isRegistrationSuccess = false;
    final result = await register(email, password, name, authProvider);
    if(result){
      if(FirebaseAuth.instance.currentUser != null){
        authState = AuthState.loggedIn;
        userName = FirebaseAuth.instance.currentUser!.displayName;
        email = FirebaseAuth.instance.currentUser!.email!;
        notifyListeners();
        isRegistrationSuccess =  true;
      }
    }
    isLoading = false;
    notifyListeners();
    return isRegistrationSuccess;
  }

  /// sends a password reset email to the provided [email]
  Future<bool> sendPasswordResetEmailFor(String email, AuthenticationProvider authProvider, Future<bool> Function(String, AuthenticationProvider) sendPasswordResetEmail) async {
    isLoading = true;
    authExceptionType = null;
    notifyListeners();
    notifyListeners();
    final result =  await sendPasswordResetEmail(email, authProvider);
    isLoading = false;
    notifyListeners();
    return result;
  }
}

/// Authentication states
enum AuthState{
  loggedIn, loggedOut, password, register,forgotPassword
}

/// a constants class used to provide information regarding authentication exceptions
class AuthExceptions{
  AuthExceptions._();

  /// constant values
  static const invalidEmail = "invalid-email";
  static const userDisabled = "user-disabled";
  static const userNotFound = "user-not-found";
  static const wrongPassword = "wrong-password";
  static const emailAlreadyInUse = "email-already-in-use";
  static const operationNotAllowed = "operation-not-allowed";
  static const weakPassword = "weak-password";
  static const expiredActionCode = "expired-action-code";
  static const invalidActionCode = "invalid-action-code";
  static const missingAndroidPkgName = "auth/missing-android-pkg-name";
  static const missingContinueUri = "auth/missing-continue-uri";
  static const missingIosBundleId = "auth/missing-ios-bundle-id";
  static const unauthorizedContinueUri = "auth/unauthorized-continue-uri";
  static const unknown = "unknown";
  static const typeOf = {
    invalidEmail: AuthExceptionType.invalidEmail,
    missingAndroidPkgName: AuthExceptionType.missingAndroidPkgName,
    missingContinueUri: AuthExceptionType.missingContinueUri,
    missingIosBundleId: AuthExceptionType.missingIosBundleId,
    unauthorizedContinueUri: AuthExceptionType.unauthorizedContinueUri,
    userNotFound: AuthExceptionType.userNotFound,
    expiredActionCode: AuthExceptionType.expiredActionCode,
    invalidActionCode: AuthExceptionType.invalidActionCode,
    userDisabled: AuthExceptionType.userDisabled,
    weakPassword: AuthExceptionType.weakPassword,
    emailAlreadyInUse: AuthExceptionType.emailAlreadyInUse,
    operationNotAllowed: AuthExceptionType.operationNotAllowed,
    wrongPassword: AuthExceptionType.wrongPassword,
    unknown: AuthExceptionType.unknown
  };

  /// a map consisting of [AuthExceptionType] to its description
  static const Map<AuthExceptionType, String> messageOfType ={
    AuthExceptionType.invalidEmail: "Invalid Email! Please enter proper Email.",
    AuthExceptionType.userNotFound: "User not found. Please check your email or Register.",
    AuthExceptionType.userDisabled: "Account is disabled. Please contact support.",
    AuthExceptionType.emailAlreadyInUse: "Email already in use. Please Login or Register with other Email.",
    AuthExceptionType.wrongPassword: "Wrong password! Please enter proper Password.",
    AuthExceptionType.weakPassword: "Weak Password! Please check the valid password requirements.",
    AuthExceptionType.operationNotAllowed: "Something went wrong! Please try again, still face the problem please contact support.",
    AuthExceptionType.expiredActionCode: "The code is expired.",
    AuthExceptionType.invalidActionCode: "Invalid code or already used.",
    AuthExceptionType.missingIosBundleId: "Something went wrong! Please try again, still face the problem please contact support.",
    AuthExceptionType.missingContinueUri: "Something went wrong! Please try again, still face the problem please contact support.",
    AuthExceptionType.missingAndroidPkgName: "Something went wrong! Please try again, still face the problem please contact support.",
    AuthExceptionType.unauthorizedContinueUri: "Something went wrong! Please try again, still face the problem please contact support.",
    AuthExceptionType.unknown: "Something went wrong! Please try again."
  };
}

/// Auth exception types
enum AuthExceptionType{
  /// Specify that the email is not a proper email ID
  invalidEmail,

  /// Specify that user account is disabled
  userDisabled,

  /// Specify that the user with the email id is not registered
  userNotFound,

  /// Tells that the password is not correct
  wrongPassword,

  /// Tells that the email user is using to register is already have used
  emailAlreadyInUse,

  /// due to some reason user is not allowed
  operationNotAllowed,

  /// the password user entered is weak
  weakPassword,

  /// The code is expired
  expiredActionCode,

  /// the action code is invalid
  invalidActionCode,

  /// An Android Package Name must be provided if the Android App is required to be installed.
  missingAndroidPkgName,

  /// A valid continue URL must be provided in the request.
  missingContinueUri,

  /// The request is missing a Bundle ID.
  missingIosBundleId,

  /// The domain of the continue URL is not whitelisted. Whitelist the domain in the Firebase Console.
  unauthorizedContinueUri,

  /// unknown error
  unknown
}
