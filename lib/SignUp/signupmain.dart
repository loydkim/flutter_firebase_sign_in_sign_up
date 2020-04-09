import 'package:flutter/material.dart';
import 'package:signinexample/SignUp/ChildViews/signupform.dart';
import 'package:signinexample/SignUp/ChildViews/signupimages.dart';
import 'package:signinexample/SignUp/ChildViews/signupintroduce.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signinexample/HomeMain/userscreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class SignUpMain extends StatefulWidget {
  final FirebaseUser firebaseUser;
  SignUpMain({Key key, @required this.firebaseUser}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SignUpWithMail();
}

class _SignUpWithMail extends State<SignUpMain> {
  // Get user data. these controllers connected with childView ( signupform.dart )
  final _emailTextController = TextEditingController();
  final _passwordTextController = TextEditingController();
  final _nameTextController = TextEditingController();
  final _introduceTextController = TextEditingController();

  // pageController in view.
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // save user data except textfield data like gender, images, birthday
  Map<String, dynamic> _userDataMap = Map<String, dynamic>();

  // the data from SNS ( facebook, google ). if using email, the value is null.
  FirebaseUser currentUser;

  // Editable values
  String _nextText = 'Next';
  Color _nextColor = Colors.green[800];

  // Save imageList from library
  List<File> _imageList;

  // image URL String list from Firebase storage.
  List<String> _imageStringList = List<String>.generate(4,(i) => '');

  bool isWithSNS = false;
  bool isLoading = false;

  // update user data from child views ( signupform, signupimage, signupintroduce)
  // the 0 is key. 1 is value
  _updateUserData(List<dynamic> data) {
    setState(() {
      _userDataMap[data[0]] = data[1];
    });
  }

  @override
  void initState() {
    // init values
    _userDataMap['gender'] = 'Man';
    _userDataMap['term'] = false;
    _userDataMap['age'] = 0;
    _userDataMap['birth_year'] = 0;

    // set data from SNS
    setState(() {
      if(widget.firebaseUser != null) {
        isWithSNS = true;
        currentUser = widget.firebaseUser;
        _emailTextController.text = currentUser.email;
        _nameTextController.text = currentUser.displayName;
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          WillPopScope( // blocking if the user cancel button, close the view.
            child: Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('images/intro_bg.png'), fit: BoxFit.fill)),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container( // white bg with radius.
                        margin: const EdgeInsets.all(4.0),
                        padding: const EdgeInsets.only(top: 10, bottom: 24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey[400]),
                          borderRadius: BorderRadius.all(Radius.circular(25.0)),
                        ),
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(left: 18.0, top: 10),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Create Account',
                                  style: TextStyle(
                                      fontSize: 34, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            Container(
                              width: 400,
                              height: 440,
                              child: PageView(
                                onPageChanged: (int page) {
                                  setState(() {
                                    _currentPage = page;
                                  });

                                  if (page == 2) { // if last page, change text and color
                                    setState(() {
                                      _nextText = 'Submit';
                                      _nextColor = Colors.blue[900];
                                    });
                                  } else {
                                    setState(() {
                                      _nextText = 'Next';
                                      _nextColor = Colors.green[800];
                                    });
                                  }
                                },
                                controller: _pageController,
                                children: <Widget>[
                                  SignUpForm( // pass controllers to get texts
                                      _emailTextController,
                                      _passwordTextController,
                                      _nameTextController,
                                      _updateUserData,
                                      isWithSNS
                                  ),
                                  SignUpImages(_updateUserData),
                                  SignUpIntroduce(_introduceTextController)
                                ],
                              ),
                            ),
                            Row(
                              children: <Widget>[
                                Flexible(
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.only(left: 8.0, right: 8.0),
                                    child: RaisedButton(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: new BorderRadius.circular(12.0),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          Text(
                                            'Cancel',
                                            style: TextStyle(fontSize: 28),
                                          ),
                                        ],
                                      ),
                                      textColor: Colors.black,
                                      color: Colors.white,
                                      padding: EdgeInsets.all(10),
                                      onPressed: () { // move first page view when click 'cancel' button
                                        if (_currentPage > 0) {
                                          _pageController.animateToPage(
                                              0,
                                              duration: Duration(milliseconds: 200),
                                              curve: Curves.easeIn);
                                        } else {
                                          Navigator.pop(context);
                                        }

                                      },
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.only(left: 8.0, right: 8.0),
                                    child: RaisedButton(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: new BorderRadius.circular(12.0),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          Text(
                                            _nextText,
                                            style: TextStyle(fontSize: 28),
                                          ),
                                        ],
                                      ),
                                      textColor: Colors.white,
                                      color: _nextColor,
                                      padding: EdgeInsets.all(10),
                                      onPressed: () {
                                        if (_pageController.page.toInt() == 0) {
                                          if (_validateUserData()) {
                                            _moveToNextPage(); // check user data validation and move next page
                                          }
                                        }else if (_pageController.page.toInt() == 1){
                                          _moveToNextPage();
                                        }else if (_pageController.page.toInt() == 2) {
                                          _arrayImageFiles();
                                          if (_validateUserData()) {
                                            print('last page');
                                            setState(() {
                                              isLoading = true;
                                            });
                                            if (currentUser == null) {
                                              _signUpToFirebaseAuth(); // if user use email, add email and password to Firebase Auth
                                            }else{
                                              _addUserImagesToFirebaseStorage(currentUser); // if user use SNS, add data directly.
                                            }
                                          }
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
            onWillPop: onBackPress,
          ),
          Positioned(
            child: isLoading
                ? Container(
              child: Center(
                child: CircularProgressIndicator(
//                  valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                ),
              ),
              color: Colors.white.withOpacity(0.7),
            )
                : Container(),
          ),
        ],
      ),
    );
  }

  bool _validateUserData() {
    String alertString = '';

    if (_emailTextController.text.trim() == '') {
      alertString = alertString+ 'Please type your email';
    }

    if (!isWithSNS) {
      if (_passwordTextController.text.trim() == ''){
        if (alertString.trim() != '') {
          alertString = alertString+ '\n\n';
        }
        alertString = alertString+ 'Please type your password';
      }
    }

    if (_nameTextController.text.trim() == ''){
      if (alertString.trim() != '') {
        alertString = alertString+ '\n\n';
      }
      alertString = alertString+ 'Please type your name';
    }

    if (_userDataMap['birth_year'] == 0){
      if (alertString.trim() != '') {
        alertString = alertString+ '\n\n';
      }
      alertString = alertString+ 'Please select your age';
    }

    if (_userDataMap['term'] == false){
      if (alertString.trim() != '') {
        alertString = alertString+ '\n\n';
      }
      alertString = alertString+ 'Please agree the term check box';
    }

    if (alertString.trim() != '') {
      showDialogWithText(alertString);
      return false;
    }else {
      return true;
    }
  }

  Future<bool> onBackPress() { // block close the view.
    if (_currentPage > 0) {
      _pageController.animateToPage(
          0,
          duration: Duration(milliseconds: 200),
          curve: Curves.easeIn);
    } else {
      Navigator.pop(context);
    }
    return Future.value(false);
  }

  void _moveToNextPage() { // move next page.
    _pageController.animateToPage(
        _pageController.page.toInt() + 1,
        duration: Duration(milliseconds: 200),
        curve: Curves.easeIn);
  }

  void _arrayImageFiles() {
    List<File> _userImageList = List<File>();
    for (var i = 0; i < 4; i++) {
      print('image file is ${ _userDataMap['image$i']}');
      if (_userDataMap['image$i'] != null) {
        _userImageList.add(_userDataMap['image$i']);
      }
    }
    _imageList = _userImageList;
  }

  Future<void> _signUpToFirebaseAuth() async {
    try {
      final FirebaseUser firebaseUser = (await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailTextController.text,
          password: _passwordTextController.text
      )).user;
      _addUserImagesToFirebaseStorage(firebaseUser);
    }catch(e) {
      showDialogWithText(e.message);
      setState(() {
        isLoading = false;
      });
    }
  }

  int _uploadImagePosition = 0;
  Future<void> _addUserImagesToFirebaseStorage(FirebaseUser firebaseUser) async {
    try {
      if (_imageList != null && _imageList.length > 0) {
        _uploadUserImages(_imageList[_uploadImagePosition], firebaseUser.uid, 'image$_uploadImagePosition', _uploadImagePosition,firebaseUser);
      }else {
        _insertDataToLocalAndFirebaseDB(firebaseUser);
      }
    }catch(e) {
      showDialogWithText(e.message);
      setState(() {
        isLoading = false;
      });
    }

  }

  bool isFinishedUpload = false;
  Future<void> _uploadUserImages(File imageFile, String userID,String imageCount, int position, FirebaseUser firebaseUser) async {
    try {
      String fileName = 'images/$userID/$imageCount';//userID+imageCount;
      StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
      StorageUploadTask uploadTask = reference.putFile(imageFile);
      StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
      storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
        _imageStringList[position] = downloadUrl;
        _uploadImagePosition++;
        if (_uploadImagePosition < _imageList.length) {
          _uploadUserImages(_imageList[_uploadImagePosition], firebaseUser.uid, 'image$_uploadImagePosition', _uploadImagePosition,firebaseUser);
        }else {
          _insertDataToLocalAndFirebaseDB(firebaseUser);
        }
      }, onError: (err) {
        setState(() {
          showDialogWithText(err);
          setState(() {
            isLoading = false;
          });
        });
      });
    }catch(e) {
      showDialogWithText(e.message);
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _insertDataToLocalAndFirebaseDB(FirebaseUser firebaseUser) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (firebaseUser != null) {
        // Check is already sign up
        final QuerySnapshot result =
        await Firestore.instance.collection('users').where('id', isEqualTo: firebaseUser.uid).getDocuments();
        final List<DocumentSnapshot> documents = result.documents;
        if (documents.length == 0) {
          // Update data to server if new user
          Firestore.instance.collection('users').document(firebaseUser.uid).setData({
            'email': _emailTextController.text,
            'password': _passwordTextController.text,
            'name': _nameTextController.text,
            'gender': _userDataMap['gender'],
            'age': _userDataMap['age'],
            'image0' : _imageStringList[0],
            'image1' : _imageStringList[1],
            'image2' : _imageStringList[2],
            'image3' : _imageStringList[3],
            'birth_year': _userDataMap['birth_year'],
            'birth_month': _userDataMap['birth_month'],
            'birth_day': _userDataMap['birth_day'],
            'intro': _introduceTextController.text,
            'id': firebaseUser.uid,
            'createdAt': DateTime.now().millisecondsSinceEpoch.toString(),
            'chattingWith': null
          });

          // Write data to local
          currentUser = firebaseUser;
          await prefs.setString('id', currentUser.uid);
          await prefs.setString('email', _emailTextController.text);
          await prefs.setString('password', _passwordTextController.text);
          await prefs.setString('name', _nameTextController.text);
          await prefs.setString('gender', _userDataMap['gender']);
          await prefs.setInt('age', _userDataMap['age']);
          await prefs.setString('image0', _imageStringList[0]);
          await prefs.setString('image1', _imageStringList[1]);
          await prefs.setString('image2', _imageStringList[2]);
          await prefs.setString('image3', _imageStringList[3]);
          await prefs.setInt('birth_year', _userDataMap['birth_year']);
          await prefs.setInt('birth_month', _userDataMap['birth_month']);
          await prefs.setInt('birth_day', _userDataMap['birth_day']);
          await prefs.setString('intro',_introduceTextController.text);
          await prefs.setString('createdAt', DateTime.now().millisecondsSinceEpoch.toString());
        } else {
          // Write Firebase data to local
          await prefs.setString('id', documents[0]['id']);
          await prefs.setString('email', documents[0]['email']);
          await prefs.setString('password', documents[0]['password']);
          await prefs.setString('name', documents[0]['name']);
          await prefs.setString('gender', documents[0]['gender']);
          await prefs.setInt('age', documents[0]['age']);
          await prefs.setString('image0', documents[0]['image0']);
          await prefs.setString('image1', documents[0]['image1']);
          await prefs.setString('image2', documents[0]['image2']);
          await prefs.setString('image3', documents[0]['image3']);
          await prefs.setInt('birth_year', documents[0]['birth_year']);
          await prefs.setInt('birth_month', documents[0]['birth_month']);
          await prefs.setInt('birth_day', documents[0]['birth_day']);
          await prefs.setString('intro', documents[0]['intro']);
          await prefs.setString('createdAt', documents[0]['createdAt']);
        }
        setState(() {
          isLoading = false;
        });
      } else {
        showDialogWithText('Sign in fail');
        setState(() {
          isLoading = false;
        });
      }
      await prefs.setBool('isLogin', true);
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => UserScreen()),
      );
    }catch(e) {
      showDialogWithText(e.message);
      setState(() {
        isLoading = false;
      });
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
