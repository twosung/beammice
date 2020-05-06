import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:beammicebeta/const.dart';
import 'package:beammicebeta/chat.dart';
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