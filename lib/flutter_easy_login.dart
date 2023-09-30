library flutter_easy_login;

import 'package:flutter/material.dart';
import 'package:flutter_easy_login/models/firebase_manage_users.dart';
import 'package:flutter_easy_login/widgets/button_widgets.dart';
import 'package:flutter_easy_login/widgets/message_container.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/provider.dart';

import 'models/auth_provider.dart';
import 'models/constants.dart';
import 'models/helper_functions.dart';

/// The First widget of the app for Login and Registration
///
/// If user is logged in then the [child] screen is shown as the home screen
class LoginPage extends StatelessWidget {
  LoginPage({super.key,  required this.appName, required this.child, required this.passwordRegex,
    this.invalidPasswordMessage, this.passwordRequirements, this.checkEmail,
    this.login, this.register, this.sendPasswordResetEmail, this.signOut, this.
    isUsingFirebaseAuth = false}) :assert(
  invalidPasswordMessage == null || passwordRequirements == null,
  "Cannot provide both values, either use invalidPasswordMessage or passwordRequirements"
  ),assert( isUsingFirebaseAuth ||
  (!isUsingFirebaseAuth && checkEmail != null && login != null && register != null
      && sendPasswordResetEmail != null && signOut != null),
  "If [isUsingFirebaseAuth] is false then must provide methods for [checkEmail],"
      "[login], [register], [sendPasswordResetEmail] and [logout]"
  ){
    if(isUsingFirebaseAuth){
      checkEmail = FirebaseManageUsers.doesAccountExistWithThis;
      login = FirebaseManageUsers.loginWithEmailPassword;
      register = FirebaseManageUsers.registerWithEmailPasswordName;
      sendPasswordResetEmail = FirebaseManageUsers.sendPasswordResetEmail;
      signOut = FirebaseManageUsers.signOut;
    }
  }

  /// App Name to display in Login/Registration pages
  final String appName;

  /// widget or page to display when user is logged in
  final Widget child;

  /// if this is true then default [FirebaseAuth] authentication methods will be
  /// assigned to [login], [checkEmail], [register], [sendPasswordResetEmail], [signOut]
  final bool isUsingFirebaseAuth;

  /// A REGULAR EXPRESSION of a valid password
  final String passwordRegex;

  /// A message to be displayed to the user when the password does not match with [passwordRegex]
  ///
  /// this should not be null if [passwordRequirements] is null and vice versa.
  ///
  /// if want to show simple one message use this or use [passwordRequirements] to display particular message
  final String? invalidPasswordMessage;

  /// A map containing pairs of regex of Each password requirements and message to display
  ///
  /// e.g {r'(?=.*[0-9]).*' : "Password must contains at least one digit"}
  ///
  /// This map is used to display particular messages of invalid password
  ///
  /// if this is null then [invalidPasswordMessage] should not be null and vice versa.
  final Map<String, String>? passwordRequirements;

  /// If [isUsingFirebaseAuth] is true then default [FirebaseAuth.fetchSignInMethodsForEmail] will be used.
  ///
  /// other wise need to provide this method.
  ///
  /// the function that accepts an email and checks the email and returns [true] if the user is already
  /// exists with the email, otherwise returns [false] if the user is new
  ///
  /// [AuthProvider] is used to update the widget to password widget if user is
  /// exists with the email
  ///
  /// and if there is any thing wrong in email then assign
  /// appropriate [AuthExceptionType] to the [AuthProvider.authExceptionType]
  late final Future<bool> Function(String, AuthProvider)? checkEmail;

  /// If [isUsingFirebaseAuth] is true then default [FirebaseAuth.signInWithEmailAndPassword] will be used.
  ///
  /// other wise need to provide this method.
  ///
  /// the function that accepts email and password and return true if the email and
  /// password are valid and let user login other wise return false
  ///
  /// and if email and password does not match or any thing wrong in email or password
  /// then assign appropriate [AuthExceptionType] to the [AuthProvider.authExceptionType]
  late final Future<bool> Function(String, String, AuthProvider)? login;

  /// If [isUsingFirebaseAuth] is true then default [FirebaseAuth.createUserWithEmailAndPassword] will be used.
  ///
  /// other wise need to provide this method.
  ///
  /// the function that accepts email, password and name and create an account
  /// with the provided details
  ///
  /// if any error is there then need to assign appropriate [AuthExceptionType]
  /// to the [AuthProvider.authExceptionType]
  late final Future<bool> Function(String, String, String, AuthProvider)? register;

  /// If [isUsingFirebaseAuth] is true then default [FirebaseAuth.sendPasswordResetEmail] will be used.
  ///
  /// other wise need to provide this method.
  ///
  /// the function that accepts an email and sends a password reset email to the
  /// provided email,
  /// returns [true] if the password reset email sends successfully otherwise returns false
  ///
  /// if any error is there then need to assign appropriate [AuthExceptionType]
  /// to the [AuthProvider.authExceptionType]
  late final Future<bool> Function(String, AuthProvider)? sendPasswordResetEmail;

  /// If [isUsingFirebaseAuth] is true then default [FirebaseAuth.signOut] will be used.
  ///
  /// other wise need to provide this method.
  ///
  /// the function that sign out the user
  /// /// if any error is there then need to assign appropriate [AuthExceptionType]
  /// to the [AuthProvider.authExceptionType]
  late final Future<void> Function(AuthProvider)? signOut;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        switch(authProvider.authState){
          case AuthState.loggedIn:
            return child;
          case AuthState.loggedOut:
            return AuthWidget(appName: appName, child: EmailWidget(appName: appName, authProvider: authProvider, checkEmail: checkEmail!,));
          case AuthState.password:
            return AuthWidget(appName: appName, child: PasswordWidget(authProvider: authProvider, login: login!,));
          case AuthState.register:
            return AuthWidget(appName: appName, child: RegistrationWidget(authProvider: authProvider,
                register: register!, passwordRegex: passwordRegex,invalidPasswordMessage: invalidPasswordMessage, passwordRequirements: passwordRequirements));
          case AuthState.forgotPassword:
            return AuthWidget(appName: appName, child: ForgotPasswordWidget(authProvider: authProvider, checkEmail: checkEmail!, sendPasswordResetEmail: sendPasswordResetEmail!,));
        }
      },
    );
  }
}

class AuthWidget extends StatelessWidget {
  const AuthWidget({super.key, required this.child, required this.appName});
  final Widget child;
  final String appName;

  @override
  Widget build(BuildContext context) {
    return StreamProvider<InternetConnectionStatus>(
      initialData: InternetConnectionStatus.connected,
      create: (_){
        return InternetConnectionChecker().onStatusChange;
      },
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                constraints: const BoxConstraints(
                    maxWidth: 500
                ),
                child: Card(
                  elevation: 8,
                  //color: Theme.of(context).colorScheme.primary,
                  margin: const EdgeInsets.all(8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        sizedBoxWithHeight10,
                        Text(appName, style: LargeTextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            isBold: true
                        ),),
                        const Divider(),
                        sizedBoxWithHeight10,
                        Builder(
                            builder: (context) {
                              return Provider.of<InternetConnectionStatus>(context) ==
                                  InternetConnectionStatus.disconnected
                                  ? Column(
                                children: const [
                                  Text("No Internet Connection!", style: MediumTextStyle(isBold: true)),
                                  sizedBoxWithHeight10,
                                  Text("Please check your internet connectivity.", style: SmallTextStyle())
                                ],
                              )
                                  : child;
                            }
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class EmailWidget extends StatefulWidget {
  const EmailWidget({super.key, required this.authProvider, required this.checkEmail, required this.appName});
  final AuthProvider authProvider;
  final Future<bool> Function(String, AuthProvider) checkEmail;
  final String appName;

  @override
  State<EmailWidget> createState() => _EmailWidgetState();
}

class _EmailWidgetState extends State<EmailWidget> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> checkEmail() async {
    if (_formKey.currentState!.validate()) {

      final result = await widget.authProvider.isAccountExistWithThis(_emailController.text, widget.authProvider, widget.checkEmail);
      if(result){
        widget.authProvider.authState = AuthState.password;
      }else{
        widget.authProvider.authState = AuthState.register;
      }
      widget.authProvider.notify();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            sizedBoxWithHeight10,
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                hintText: "abcd@email.com",
                labelText: "Email",
              ),
              onFieldSubmitted: (email){
                checkEmail();
              },
              validator: (email) {
                if (email == null || email.isEmpty) {
                  return "Email is Required";
                } else if (!RegExp(emailRegex).hasMatch(email)) {
                  return "Enter valid email id";
                } else {
                  return null;
                }
              },
            ),
            sizedBoxWithHeight10,
            AuthExceptionTypeErrorWidget(authProvider: widget.authProvider),
            MyButton(
              label: "Continue",
              isLoading: widget.authProvider.isLoading,
              onTap: checkEmail,
            )
          ],
        ),
      ),
    );
  }
}

class PasswordWidget extends StatefulWidget {
  const PasswordWidget({super.key, required this.authProvider, required this.login});
  final AuthProvider authProvider;
  final Future<bool> Function(String, String, AuthProvider) login;

  @override
  State<PasswordWidget> createState() => _PasswordWidgetState();
}


class _PasswordWidgetState extends State<PasswordWidget> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  bool _showPassword = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.authProvider.email == null || widget.authProvider.email!.isEmpty){
      widget.authProvider.authState = AuthState.loggedOut;
      widget.authProvider.notify();
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }
  void login() {
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      widget.authProvider.loginWith(widget.authProvider.email ?? "", _passwordController.text,widget.authProvider, widget.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Center(
          child: Column(
            children: [
              sizedBoxWithHeight10,
              EmailFieldNotEditable(authProvider: widget.authProvider),
              sizedBoxWithHeight10,
              TextFormField(
                obscureText: !_showPassword,
                controller: _passwordController,
                decoration: InputDecoration(
                    hintText: "Enter password",
                    labelText: "Password",
                    isDense: true,
                    suffix: IconButton(onPressed: (){
                      setVariables(mounted, setState, () {
                        _showPassword = !_showPassword;
                      });
                    }, icon: Icon(!_showPassword ? Icons.visibility : Icons.visibility_off, color: Theme.of(context).colorScheme.primary, size: 24,))
                ),
                validator: (password){
                  if(password == null || password.isEmpty){
                    return "Please enter password!";
                  }else{
                    return null;
                  }
                },
                onFieldSubmitted: (_){
                  login();
                },
              ),
              sizedBoxWithHeight10,
              AuthExceptionTypeErrorWidget(authProvider: widget.authProvider),
              MyButton(
                  label: "Login",
                  isLoading: widget.authProvider.isLoading,
                  onTap: login
              )
            ],
          ),
        ));
  }
}

class RegistrationWidget extends StatefulWidget {
  const RegistrationWidget({super.key, required this.authProvider, required this.register, this.passwordRequirements, this.invalidPasswordMessage, required this.passwordRegex,}):
        assert(passwordRequirements != null || invalidPasswordMessage != null);
  final AuthProvider authProvider;
  final Future<bool> Function(String, String, String, AuthProvider) register;
  final String passwordRegex;
  final Map<String, String>? passwordRequirements;
  final String? invalidPasswordMessage;

  @override
  State<RegistrationWidget> createState() => _RegistrationWidgetState();
}

class _RegistrationWidgetState extends State<RegistrationWidget> {
  final _passwordController = TextEditingController();
  final _reEnterPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  // String? checkPasswordRequirements(String password){
  //   String? invalidPasswordMessage;
  //   if(widget.authProvider.passwordRequirements != null){
  //     for(final key in widget.authProvider.passwordRequirements!.keys) {
  //       if(!RegExp(key).hasMatch(password)){
  //         invalidPasswordMessage = widget.authProvider.passwordRequirements[key];
  //       }
  //     }
  //   }else{
  //     invalidPasswordMessage = widget.authProvider.invalidPasswordMessage;
  //   }
  //   return invalidPasswordMessage;
  // }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.authProvider.email == null || widget.authProvider.email!.isEmpty){
      widget.authProvider.authState = AuthState.loggedOut;
      //widget.authProvider.notify();
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _reEnterPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(
          children: [
            EmailFieldNotEditable(
                authProvider: widget.authProvider),
            sizedBoxWithWidth10,
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                  labelText: "Name",
                  hintText: "Enter your name"
              ),
              validator: (name){
                if(name == null || name.isEmpty){
                  return "Name is required";
                }
                return null;
              },
            ),
            sizedBoxWithHeight10,
            PasswordTextField(passwordController: _passwordController,
              reEnterPasswordController: _reEnterPasswordController,
              authProvider: widget.authProvider,
              invalidPasswordMessage: widget.invalidPasswordMessage,
              passwordRequirements: widget.passwordRequirements, passwordRegex: widget.passwordRegex,
            ),
            sizedBoxWithWidth10,
            AuthExceptionTypeErrorWidget(authProvider: widget.authProvider),
            MyButton(label: "Register",
              isLoading: widget.authProvider.isLoading,
              onTap: (){
                if (_formKey.currentState != null && _formKey.currentState!.validate()) {
                  widget.authProvider.registerWith(widget.authProvider.email ?? "", _passwordController.text, _nameController.text, widget.authProvider,widget.register);
                }
              },),
            sizedBoxWithHeight10,
            const Text("Or"),
            sizedBoxWithHeight10,
            InkWell(
              child: Text("Login", style: MediumTextStyle(color: Theme.of(context).colorScheme.primary),),
              onTap: (){
                widget.authProvider.authState = AuthState.loggedOut;
                widget.authProvider.notify();
              },
            )
          ],
        ));
  }
}

class ForgotPasswordWidget extends StatefulWidget {
  const ForgotPasswordWidget({super.key, required this.authProvider, required this.checkEmail, required this.sendPasswordResetEmail});
  final AuthProvider authProvider;
  final Future<bool> Function(String, AuthProvider) checkEmail;
  final Future<bool> Function(String, AuthProvider) sendPasswordResetEmail;

  @override
  State<ForgotPasswordWidget> createState() => _ForgotPasswordWidgetState();
}

class _ForgotPasswordWidgetState extends State<ForgotPasswordWidget> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _emailController.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: "Email",
              hintText: "Enter your Email",
            ),
            validator: (email){
              if(email == null || email.isEmpty){
                return "Email is Required";
              }
              return null;
            },
          ),
          sizedBoxWithHeight10,
          widget.authProvider.authExceptionType != null
              ? MessageContainer(message: AuthExceptions.messageOfType[widget.authProvider.authExceptionType] ?? "")
              : const SizedBox(),
          MyButton(label: "Send Password Reset Email",
            isLoading: widget.authProvider.isLoading,
            onTap: () async {
              if(_formKey.currentState != null && _formKey.currentState!.validate()){
                final result = await widget.authProvider.isAccountExistWithThis(_emailController.text,widget.authProvider, widget.checkEmail);
                if(result){
                  final result = await widget.authProvider.sendPasswordResetEmailFor(_emailController.text, widget.authProvider,widget.sendPasswordResetEmail);
                  if(result){
                    if (context.mounted) {
                      showSnackBar(context, "Password reset email is successfully to your email: ${_emailController.text}");
                      Navigator.pop(context);
                    }
                  }
                }
              }
            },)
        ],
      ),
    );
  }
}



class EmailFieldNotEditable extends StatelessWidget {
  const EmailFieldNotEditable({super.key, required this.authProvider});
  final AuthProvider authProvider;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: TextFormField(
          initialValue: authProvider.email,
          enabled: false,
        )),
        sizedBoxWithWidth5,
        IconButton(
          icon: Icon(Icons.edit, color: Theme.of(context).colorScheme.primary),
          onPressed: () {
            authProvider.authState = AuthState.loggedOut;
            authProvider.notify();
          },),
      ],
    );
  }
}

class AuthExceptionTypeErrorWidget extends StatelessWidget {
  const AuthExceptionTypeErrorWidget({super.key, required this.authProvider});
  final AuthProvider authProvider;

  @override
  Widget build(BuildContext context) {
    return authProvider.authExceptionType != null
        ? Column(
      children: [
        MessageContainer(message: AuthExceptions.messageOfType[authProvider.authExceptionType] ?? ""),
      ],
    ) : const SizedBox();
  }
}

class PasswordRequirementsWidget extends StatelessWidget {
  const PasswordRequirementsWidget({super.key, required this.authProvider, required this.password, required this.passwordRegex, this.invalidPasswordMessage, this.passwordRequirements}):
        assert(passwordRequirements != null || invalidPasswordMessage != null, "In both passwordRequirements and invalidPassword any one should be provided");

  // /// map of key-value pairs of each regex and its message of passwordRequirements
  // ///
  // /// if [password] matches any regex the message related to that regex is shown
  // /// in green color otherwise in red color
  // /// **it should contains at least one regex and its message
  // final Map<String, String> passwordRequirements;
  final AuthProvider authProvider;

  final String? password;

  final String passwordRegex;
  final String? invalidPasswordMessage;
  final Map<String, String>? passwordRequirements;



  @override
  Widget build(BuildContext context) {
    final passwordRequirementsMap = passwordRequirements ??
        {passwordRegex : invalidPasswordMessage ?? 'Invalid password'};
    return passwordRequirementsMap.isNotEmpty
        ? Column(
      children: passwordRequirementsMap.keys.map((key){
        final color = RegExp(key).hasMatch(password ?? "") ? Colors.green.shade700
            : Colors.red.shade700;
        return passwordRequirementsMap[key] != null && passwordRequirementsMap[key]!.isNotEmpty
            && !RegExp(key).hasMatch(password ?? "")
            ? Padding(padding: const EdgeInsets.symmetric(vertical: 4,horizontal: 4),
          child: Row(
            children: [
              Icon(Icons.check, color: color,),
              sizedBoxWithWidth10,
              Expanded(child: Text(passwordRequirementsMap[key] ?? "",
                style: SmallTextStyle(
                    color: color
                ),))
            ],
          ),) : const SizedBox();
      }).toList(),
    ): const SizedBox();
  }
}

class PasswordTextField extends StatefulWidget {
  const PasswordTextField({super.key, required this.passwordController,required this.reEnterPasswordController, required this.authProvider, required this.invalidPasswordMessage, this.passwordRequirements, required this.passwordRegex});
  final TextEditingController passwordController;
  final TextEditingController reEnterPasswordController;
  final AuthProvider authProvider;
  final String passwordRegex;
  final String? invalidPasswordMessage;
  final Map<String, String>? passwordRequirements;

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  String password = "";
  bool _showPassword = false;
  bool _showReEnterPassword = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.passwordController.addListener(() {
      setVariables(mounted, setState, () {
        password = widget.passwordController.text;
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          obscureText: !_showPassword,
          controller: widget.passwordController,
          decoration: InputDecoration(
              hintText: "Enter password",
              labelText: "Password",
              suffix: IconButton(onPressed: (){
                setVariables(mounted, setState, () {
                  _showPassword = !_showPassword;
                });
              }, icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility, color: Theme.of(context).colorScheme.primary,))
          ),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (password){
            if(password == null || password.isEmpty){
              return "Password is Required.";
            }else if(!RegExp(widget.passwordRegex).hasMatch(password)){
              return "";
            }else{
              return null;
            }
          },
        ),
        PasswordRequirementsWidget(
            authProvider: widget.authProvider,
            password: password,
            passwordRegex: widget.passwordRegex,
            invalidPasswordMessage: widget.invalidPasswordMessage,
            passwordRequirements: widget.passwordRequirements
        ),
        RegExp(widget.passwordRegex).hasMatch(password)
            ? Column(
          children: [
            sizedBoxWithWidth10,
            TextFormField(
              obscureText: !_showReEnterPassword,
              controller: widget.reEnterPasswordController,
              decoration: InputDecoration(
                  labelText: "Re Enter Password",
                  hintText: "Enter password again",
                  suffix: IconButton(onPressed: (){
                    setVariables(mounted, setState, () {
                      _showReEnterPassword = !_showReEnterPassword;
                    });
                  }, icon: Icon(_showReEnterPassword ? Icons.visibility_off : Icons.visibility, color: Theme.of(context).colorScheme.primary,))
              ),
              validator: (reEnterPassword){
                if(reEnterPassword == null || reEnterPassword.isEmpty){
                  return "Please enter the same password again.";
                }else if(reEnterPassword != widget.passwordController.text){
                  return "Re Enter Password must be same as above.";
                }
                return null;
              },
            ),
          ],
        ) : const SizedBox()
      ],
    );
  }
}









