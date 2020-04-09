import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signinexample/main.dart';

class UserScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _UserScreen();
}

class _UserScreen extends State<UserScreen> with WidgetsBindingObserver{
  Map<String, dynamic> _useData = Map<String, dynamic>();
  bool _fetchingData = true;

  Future<void> _getUserData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        _useData['name'] = prefs.get('name');
        _useData['gender'] = prefs.get('gender');
        _useData['intro'] = prefs.get('intro');
        _useData['email'] = prefs.get('email');
        _useData['birth_year'] = prefs.get('birth_year');
        _useData['birth_month'] = prefs.get('birth_month');
        _useData['birth_day'] = prefs.get('birth_day');
        _useData['image0'] = prefs.get('image0');
        _useData['image1'] = prefs.get('image1');
        _useData['image2'] = prefs.get('image2');
        _useData['image3'] = prefs.get('image3');
        _useData['age'] = calculateAge(prefs.get('birth_year'), prefs.get('birth_month'), prefs.get('birth_day'));
        _fetchingData = false;
      });
    }catch(e) {
    }
  }

  calculateAge(int year, int month, int day) {
    DateTime currentDate = DateTime.now();
    int age = currentDate.year - year;
    int month1 = currentDate.month;
    int month2 = month;
    if (month2 > month1) {
      age--;
    } else if (month1 == month2) {
      int day1 = currentDate.day;
      int day2 = day;
      if (day2 > day1) {
        age--;
      }
    }
    return age;
  }

  @override
  void initState() {
    _getUserData();
    super.initState();
  }

  Widget titleSection() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.only(bottom: 8),
                  child:
                  Text(
                    _useData['name'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  _useData['email'],
                  style: TextStyle(
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.account_circle,
              color: _useData['gender'] == 'Man' ? Colors.blue[700] : Colors.red[700],
              size: 28,
            ),
          ),
          Text(_useData['age'].toString()),
        ],
      ),
    );
  }

  Widget textSection() {
    return Container(
      padding: const EdgeInsets.only(left:32, right: 32),
      child: Text(
        _useData['intro'],
        softWrap: true,
      ),
    );
  }

  Widget _deleteUser() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: RaisedButton(
        onPressed: () {
          _delete();
        },
        child: Text('Log out'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        exit(0);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('This is user screen'),
          automaticallyImplyLeading: false,
        ),
        body:
        _fetchingData ? CircularProgressIndicator() :
        ListView(
          children: [
            _useData['image0'] == '' ?
            Container(
              height: 240,
              child: Icon(Icons.broken_image, size: 160,color: Colors.grey,),
            ) :
            Image.network(_useData['image0'],
              height: 240,
              fit: BoxFit.cover,),
            titleSection(),
            textSection(),
            _deleteUser()
          ],
        ),
      ),
    );
  }

  void _delete() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLogin', false);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MyHomePage()),
    );
  }
}