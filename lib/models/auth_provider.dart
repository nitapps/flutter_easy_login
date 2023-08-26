import 'dart:core';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
class AuthProvider extends ChangeNotifier{
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

  final void Function(AuthProvider) initializeLoginState;

  AuthProvider(this.initializeLoginState){
    initializeLoginState(this);
  }

  void notify(){
    notifyListeners();
  }

  Future<void> doLogout(AuthProvider authProvider, Future<void> Function(AuthProvider) logout) async {
    isLoading = true;
    authExceptionType = null;
    notifyListeners();
    await logout(authProvider);
      email = null;
      authState = AuthState.loggedOut;
    isLoading = false;
    notifyListeners();
  }

  Future<bool> isAccountExistWithThis(String email, AuthProvider authProvider, Future<bool> Function(String email, AuthProvider) checkEmail) async {
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

  Future<bool> loginWith(String email, String password, AuthProvider authProvider, Future<bool> Function(String,String, AuthProvider) login) async {
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

  Future<bool> registerWith(String email, String password, String name, AuthProvider authProvider, Future<bool> Function(String, String, String, AuthProvider) register) async {
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

  Future<bool> sendPasswordResetEmailFor(String email, AuthProvider authProvider, Future<bool> Function(String, AuthProvider) sendPasswordResetEmail) async {
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

enum AuthState{
  loggedIn, loggedOut, password, register,forgotPassword
}


class AuthExceptions{
  AuthExceptions._();
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

enum AuthExceptionType{
  invalidEmail,userDisabled,userNotFound,wrongPassword,emailAlreadyInUse,
  operationNotAllowed, weakPassword,expiredActionCode,invalidActionCode,
  missingAndroidPkgName,missingContinueUri,missingIosBundleId,
  unauthorizedContinueUri, unknown
}
