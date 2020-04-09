import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:signinexample/HomeMain/userscreen.dart';
import 'package:signinexample/SignUp/signupmain.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignIn extends StatefulWidget {
  SignIn(this.parentAction);
  final ValueChanged<bool> parentAction;

  @override
  State<StatefulWidget> createState() => _SignIn();
}

class _SignIn extends State<SignIn> {

  final _emailTextController = TextEditingController();
  final _passwordTextController = TextEditingController();

  @override
  void dispose() {
    _emailTextController.dispose();
    _passwordTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container( //Wrap the bg as a white color with radius.
          margin: const EdgeInsets.fromLTRB(14,4.0,14,4),
          padding: const EdgeInsets.only(top:10,bottom: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey[400]),
            borderRadius: BorderRadius.all(
                Radius.circular(25.0)
            ),
          ),
          child: Column(
            children: <Widget>[
              Padding( // Login Title
                padding: const EdgeInsets.only(left:18.0,top: 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Login',
                  style: TextStyle(fontSize: 34,fontWeight: FontWeight.bold),),
                ),
              ),
              Container( //Wrap the column with grey color border.
                margin: const EdgeInsets.all(15.0),
                padding: const EdgeInsets.all(13.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[400]),
                  borderRadius: BorderRadius.all(
                      Radius.circular(25.0)
                  ),
                ),
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      width: 360,
                      child: TextFormField(
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(Icons.mail),
                            labelText: 'Email',
                            hintText: 'Type your email'
                        ),
                        validator: (String value) {
                          if (value.trim().isEmpty) {
                            return 'Email is required';
                          }else {
                            return null;
                          }
                        },
                        controller: _emailTextController,
                      ),
                    ),
                    Divider(),
                    SizedBox(
                      width: 360,
                      child: TextFormField(
                        obscureText: true,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            icon:Icon(Icons.lock),
                            labelText: 'Password',
                            hintText: 'Type password'
                        ),
                        validator: (String value) {
                          if (value.trim().isEmpty) {
                            return 'Password is required';
                          }else {
                            return null;
                          }
                        },
                        controller: _passwordTextController,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: <Widget>[
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.only(left:14.0,right: 14.0),
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(12.0),
//                    side: BorderSide(color: Colors.red)
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'Sign in',
                              style: TextStyle(fontSize: 28),
                            ),
                          ],
                        ),
                        textColor: Colors.white,
                        color: Colors.green[700],
                        padding: EdgeInsets.fromLTRB(10,10.0,10,10),
                        onPressed: () {
                          _signInWithMail();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
  }

  Future<void> _signInWithMail() async {
    try {
      FocusScope.of(context).requestFocus(FocusNode());
      widget.parentAction(true);
      final FirebaseUser firebaseUser = (await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailTextController.text,
          password: _passwordTextController.text
      )).user;

      if (firebaseUser != null) {
        _getDataFromFirebaseDB(firebaseUser);
      }else {
        showDialogWithText('Sign in error');
        widget.parentAction(false);
      }
    }catch(e) {
      showDialogWithText(e.message);
      widget.parentAction(false);
    }
  }


  Future<void> _getDataFromFirebaseDB(FirebaseUser firebaseUser) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (firebaseUser != null) {
        // Check is already sign up
        final QuerySnapshot result =
        await Firestore.instance.collection('users').where('id', isEqualTo: firebaseUser.uid).getDocuments();
        final List<DocumentSnapshot> documents = result.documents;
        if (documents.length == 0) {
          showDialogWithText('You do not have a account. Move to Create Account');
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SignUpMain(firebaseUser: null,)),
          );
        } else {
          // Write data to local
          await prefs.setString('id', documents[0]['id']);
          await prefs.setString('email', documents[0]['email']);
          await prefs.setString('password', documents[0]['password']);
          await prefs.setString('name', documents[0]['name']);
          await prefs.setString('gender', documents[0]['gender']);
          await prefs.setInt('age', documents[0]['age']);
          await prefs.setString('blood', documents[0]['blood']);
          await prefs.setString('image0', documents[0]['image0']);
          await prefs.setString('image1', documents[0]['image1']);
          await prefs.setString('image2', documents[0]['image2']);
          await prefs.setString('image3', documents[0]['image3']);
          await prefs.setInt('birth_year', documents[0]['birth_year']);
          await prefs.setInt('birth_month', documents[0]['birth_month']);
          await prefs.setInt('birth_day', documents[0]['birth_day']);
          await prefs.setString('intro', documents[0]['intro']);
          await prefs.setString('createdAt', documents[0]['createdAt']);
          await prefs.setBool('isLogin', true);
          widget.parentAction(false);
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => UserScreen()),
          );
        }
      } else {
        showDialogWithText('No user id');
        widget.parentAction(false);
      }

    }catch(e) {
      showDialogWithText(e.message);
      widget.parentAction(false);
    }
  }

  showDialogWithText(String textMessage) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text(textMessage),
          );
        }
    );
  }
}