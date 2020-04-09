import 'package:flutter/material.dart';
import 'package:signinexample/LoginScreen/mainlogo.dart';
import 'package:signinexample/LoginScreen/signin.dart';
import 'package:signinexample/LoginScreen/signup.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signinexample/HomeMain/userscreen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  bool isLoading = false;
  bool _isLogin = false;

  _checkLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLogin = (prefs.get('isLogin') ?? false);

    setState(() {
      _isLogin = isLogin;
    });
  }

  // Upadte Loading value from signin class.
  // If the user try to signin. show loading in this view.
  _updateLoadingStatus(bool value) {
    setState(() {
      isLoading = value;
    });
  }

  @override
  void initState() {
    _checkLogin();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return !_isLogin ? _signInWidget() : UserScreen();
  }

  Widget _signInWidget() {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
                image: DecorationImage(image:
                AssetImage('images/intro_bg.png'),
                    fit: BoxFit.fill)
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  mainLogo(),
                  SignIn(_updateLoadingStatus), // connecting with child view.
                  SignUp(_updateLoadingStatus)
                ],
              ),
            ),
          ),
          Positioned( // Loading view in the center.
            child: isLoading
                ? Container(
              child: Center(
                child: CircularProgressIndicator(),
              ),
              color: Colors.white.withOpacity(0.7),
              )
                : Container(),
          ),
        ],
      ),
    );
  }
}
