import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:beammicebeta/const.dart';
import 'package:beammicebeta/chat.dart';
import 'package:beammicebeta/test.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() async {

  runApp(MaterialApp(
    title: "BeamMice",
    theme: ThemeData(
      primaryColor: themeColor,
    ),
    home: HomePage(),
    debugShowCheckedModeBanner: false,
  ));
  await createOrderMessage();
}

Future<String> createOrderMessage() async {
  if (await Permission.storage.request().isUndetermined) {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage
    ].request();
  }
  return 'success';
}

class HomePage extends StatelessWidget {

  var chat_list = [
    {'id': '001', 'name': '치즈', 'avatar': 'assets/images/cat_cheese.jpg', 'greeting': '방금 식사를 마쳤어요.', 'active': true},
    {'id': '002', 'name': '검댕이', 'avatar': 'assets/images/cat_black.jpg', 'greeting': '(자는 중...)', 'active': false},
    {'id': '003', 'name': '화이트', 'avatar': 'assets/images/dog_white.jpg', 'greeting': '...', 'active': true},
    {'id': '004', 'name': '사자', 'avatar': 'assets/images/dog_yellow.jpg', 'greeting': '(자는 중...)', 'active': false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
            "나의 펫 대화하기",
            style: TextStyle(
              fontFamily: 'Daum_Bold',
              fontStyle: FontStyle.normal,
            ),
          )
      ),
      body: ListView.builder(
        itemCount: chat_list.length,
        itemBuilder: (context, index) {
          return Card(
            color: chat_list[index]['active']? Colors.white: Colors.white54,
            child: ListTile(
              leading: CircleAvatar(
                radius: 28,
                backgroundColor: index == 0? themeColor: (chat_list[index]['active']? Colors.grey: Colors.white),
                child: CircleAvatar(
                radius: 26,
                backgroundImage: AssetImage(chat_list[index]['avatar']),
                ),
              ),
              title: Text(
                chat_list[index]['name'],
                style: TextStyle(
                  fontFamily: 'Daum_Bold',
                  fontStyle: FontStyle.normal,
                ),
              ),
              subtitle: Text(
                chat_list[index]['greeting'],
                style: TextStyle(
                  fontFamily: 'Daum',
                  fontStyle: FontStyle.normal,
                ),
              ),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Chat(
                      peerId: chat_list[index]['id'],
                      peerName: chat_list[index]['name'],
                      peerAvatar: chat_list[index]['avatar'],
                    )));
                },
            ),
          );
        },
      )
    );
  }
}

/*


ListView(
        children: <Widget>[
          ListTile(
            leading: CircleAvatar(
              radius: 28,
              backgroundImage: AssetImage(profile),
            ),
            title: Text(id),
            subtitle: Text(greeting),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => Chat(
                    peerId: id,
                    peerAvatar: profile,
                  )));
            },
          )
        ].map((child) {
          return Card(
            child: child,
          );
        }).toList(),
      ),

 */
/*
GoogleSignInDemoState pageState;

GoogleSignIn _googleSignIn = GoogleSignIn(scopes: <String>[
  'email',
  'https://www.googleapis.com/auth/contacts.readonly',
]);

class GoogleSignInDemo extends StatefulWidget {
  @override
  GoogleSignInDemoState createState() {
    pageState = GoogleSignInDemoState();
    return pageState;
  }
}

class GoogleSignInDemoState extends State<GoogleSignInDemo> {
  GoogleSignInAccount _currentUser;
  String _contactText;

  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      setState(() {
        _currentUser = account;
      });
      if (_currentUser != null) {
        _handleGetContact();
      }
      _googleSignIn.signInSilently();
    });
  }

  Future<void> _handleGetContact() async {
    setState(() {
      _contactText = "Loading contact info...";
    });
    final http.Response response = await http.get(
        'https://people.googleapis.com/v1/people/me/connections'
            '?requestMask.includeField=person.names',
        headers: await _currentUser.authHeaders);

    if (response.statusCode != 200) {
      setState(() {
        _contactText = "People API gave a ${response.statusCode} "
            "response. Check logs for detailes.";
      });
      print("People API ${response.statusCode} response: ${response.body}");
      return;
    }

    final Map<String, dynamic> data = json.decode(response.body);
    final String namedContact = _pickFirstNamedContact(data);
    setState(() {
      if (namedContact != null) {
        _contactText = "I see you know $namedContact";
      } else {
        _contactText = "No contacts to display.";
      }
    });
  }

  String _pickFirstNamedContact(Map<String, dynamic> data) {
    final List<dynamic> connections = data['connections'];
    final Map<String, dynamic> contact = connections?.firstWhere(
          (dynamic contact) => contact['names'] != null,
      orElse: () => null,
    );
    if (contact != null) {
      final Map<String, dynamic> name = contact['names'].firstWhere(
            (dynamic name) => name['displayName'] != null,
        orElse: () => null,
      );
      if (name != null) {
        return name['displayName'];
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Google Sign-In Demo")),
        body: ConstrainedBox(
          constraints: const BoxConstraints.expand(),
          child: _buildBody(),
        ));
  }

  Widget _buildBody() {
    if (_currentUser != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          ListTile(
            leading: GoogleUserCircleAvatar(
              identity: _currentUser,
            ),
            title: Text(_currentUser.displayName ?? ""),
            subtitle: Text(_currentUser.email ?? ""),
          ),
          const Text("Signed in successfully."),
          Text(_contactText ?? ""),
          RaisedButton(
            child: const Text("SIGN OUT"),
            onPressed: _handleSignOut,
          ),
          RaisedButton(
            child: const Text("REFRESH"),
            onPressed: _handleGetContact,
          )
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          const Text("You are not currently signed in"),
          RaisedButton(
            child: const Text("SIGN IN"),
            onPressed: _handleSignIn,
          )
        ],
      );
    }
  }

  Future<void> _handleSignIn() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      print(error);
    }
  }

  Future<void> _handleSignOut() async {
    _googleSignIn.disconnect();
  }


  void registerNotification() {
    firebaseMessaging.requestNotificationPermissions();

    firebaseMessaging.configure(onMessage: (Map<String, dynamic> message) {
      print('onMessage: $message');
      Platform.isAndroid
          ? showNotification(message['notification'])
          : showNotification(message['aps']['alert']);
      return;
    }, onResume: (Map<String, dynamic> message) {
      print('onResume: $message');
      return;
    }, onLaunch: (Map<String, dynamic> message) {
      print('onLaunch: $message');
      return;
    });

    firebaseMessaging.getToken().then((token) {
      print('token: $token');
      Firestore.instance
          .collection('users')
          .document(currentUserId)
          .updateData({'pushToken': token});
    }).catchError((err) {
      Fluttertoast.showToast(msg: err.message.toString());
    });
  }
}

 */