import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:signinexample/HomeMain/userscreen.dart';
import 'package:signinexample/SignUp/signupmain.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUp extends StatefulWidget {
  SignUp(this.parentAction);
  final ValueChanged<bool> parentAction;
  @override
  State<StatefulWidget> createState() => _SignUp();
}

class _SignUp extends State<SignUp> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14,4.0,14,14),
      padding: const EdgeInsets.only(top:10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[400]),
        borderRadius: BorderRadius.all(
            Radius.circular(25.0)
        ),
      ),
      child: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(left: 20,right: 20),
            child: Row(
                children: <Widget>[
                  Expanded(child: Divider(thickness: 2)),
                  Text(" Sign Up ",
                    style: TextStyle(fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700]),),
                  Expanded( child: Divider(thickness: 2,)),
                ]
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                child: new RawMaterialButton(
                  onPressed: () { //Move to SingUp View.
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignUpMain(firebaseUser: null,)),
                    );
                  },
                  child: new Icon(
                    Icons.mail,
                    color: Colors.white,
                    size: 50.0,
                  ),
                  shape: new CircleBorder(),
                  elevation: 2.0,
                  fillColor: Colors.redAccent,
                  padding: const EdgeInsets.all(15.0),
                ),
                margin: EdgeInsets.only(left: 10,right: 10, bottom: 14),
              ),
              Container(
                child: new RawMaterialButton(
                  onPressed: () {
                    signUpWithFacebook();
                  },
                  child: Text('f',
                    style: TextStyle(color: Colors.white,
                        fontSize: 56,fontWeight: FontWeight.bold),),
                  shape: new CircleBorder(),
                  elevation: 2.0,
                  fillColor: Colors.blue[900],
                  padding: const EdgeInsets.all(8.0),
                ),
                margin: EdgeInsets.only(left: 10,right: 10, bottom: 14),
              ),
              Container(
                child: new RawMaterialButton(
                  onPressed: () {
                    _googleSignUp();
                  },
                  child: Image.asset('images/google_logo.png',
                    fit: BoxFit.cover,
                    width: 40,
                    height: 40,),
                  shape: new CircleBorder(),
                  elevation: 2.0,
                  fillColor: Colors.white,
                  padding: const EdgeInsets.all(22.0),
                ),
                margin: EdgeInsets.only(left: 10,right: 10, bottom: 14),
              ),
            ],
          )
        ],
      ),
    );
  }

  Future<void> signUpWithFacebook() async{
    try {
      widget.parentAction(true);

      var facebookLogin = new FacebookLogin();
      var result = await facebookLogin.logIn(['email']);

      if(result.status == FacebookLoginStatus.loggedIn) {
        final AuthCredential credential = FacebookAuthProvider.getCredential(
          accessToken: result.accessToken.token,
        );
        final FirebaseUser user = (await FirebaseAuth.instance.signInWithCredential(credential)).user;
        _checkExistUserFromFirebaseDB(user);
        return user;
      }else {
        showDialogWithText('Facebook Sign in fail');
        widget.parentAction(false);
      }
    }catch (e) {
      showDialogWithText(e.message);
    }
  }

  Future<void> _googleSignUp() async {
    try {
      widget.parentAction(true);

      final GoogleSignIn _googleSignIn = GoogleSignIn(
        scopes: [
          'email'
        ],
      );
      final FirebaseAuth _auth = FirebaseAuth.instance;

      final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final FirebaseUser user = (await _auth.signInWithCredential(credential)).user;
      _checkExistUserFromFirebaseDB(user);
      return user;
    }catch (e) {
      showDialogWithText(e.message);
    }
  }

  Future<void> _checkExistUserFromFirebaseDB(FirebaseUser firebaseUser) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (firebaseUser != null) {
        // Check is already sign up
        final QuerySnapshot result =
        await Firestore.instance.collection('users').where('id', isEqualTo: firebaseUser.uid).getDocuments();
        final List<DocumentSnapshot> documents = result.documents;
        if (documents.length == 0) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SignUpMain(firebaseUser: firebaseUser,)),
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

          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => UserScreen()),
          );
        }
        widget.parentAction(false);
      } else {
        showDialogWithText('No user id');
        widget.parentAction(false);
      }
    }catch(e) {
      showDialogWithText(e.message);
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
    widget.parentAction(false);
  }
}