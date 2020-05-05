import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class ReadFileScreen extends StatefulWidget {
  @override
  ReadFileScreenState createState() {
    return new ReadFileScreenState();
  }
}

class ReadFileScreenState extends State<ReadFileScreen> {
  final myController = TextEditingController();
  final storage = FileStorage();
  Timer update_Timer;

  List<String> lines = [];

  @override
  void initState() {
    super.initState();
    const oneSec = const Duration(seconds:1);
    update_Timer = Timer.periodic(oneSec, (Timer t) => _loadFile());
  }

  //can not make initState() async, so calling this function asynchronously
  _loadFile() async {
    final String readLines = await storage.readFileAsString();
    debugPrint("readLines: $readLines");
    setState(() {
      lines = readLines.split("\\n"); //Escape the new line
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Testing'),
      ),
      body: new Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: new TextField(
              controller: myController,
              decoration: new InputDecoration(
                hintText: 'Enter the text',
              ),
            ),
          ),
          new Expanded(
            child: new ListView.builder(
                itemCount: lines.length,
                itemBuilder: (context, index) {
                  return new Text(lines[index]); //Replace with ListTile here
                }),
          ),
        ],
      ),
      floatingActionButton: new FloatingActionButton(
        child: new Icon(Icons.save_alt),
        onPressed: () {
          final String enteredText = myController.text;
          storage.writeFile(enteredText);
          myController.clear();
          setState(() {
            lines.add(enteredText);
          });
        },
      ),
    );
  }

  @override
  void dispose() {
    if (update_Timer != null) {
      update_Timer.cancel();
    }
    super.dispose();
  }
}

class MyDialogue {
  String time;
  String type;
  String text;
  String img;
}

class FileStorage {
  Future<String> get _localPath async {
    final directory = await getExternalStorageDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = '/sdcard/Download';//await _localPath;
    print('my_local_path is $path');
    return File('$path/my_log_file.json');
  }

  Future<String> readFileAsString() async {
    String contents = "";
    final file = await _localFile;
    if (file.existsSync()) { //Must check or error is thrown
      debugPrint("File exists");
      contents = await file.readAsString();
    }
    return contents;
  }

  Future<Null> writeFile(String text) async {
    final file = await _localFile;

    IOSink sink = file.openWrite(mode: FileMode.APPEND);
    sink.add(utf8.encode('$text\n')); //Use newline as the delimiter
    await sink.flush();
    await sink.close();
  }
}