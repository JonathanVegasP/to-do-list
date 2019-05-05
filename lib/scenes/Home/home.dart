import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:to_do_list/storage/file_manager.dart';
import 'package:to_do_list/storage/files.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _newTask = TextEditingController();
  List _toDoList = [];
  int _lastRemovedPos;
  Map<String, dynamic> _lastRemoved;
  final file = FileManager(TO_DO_LIST);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    file.readData().then((data) {
      setState(() {
        _toDoList = json.decode(data);
      });
    });
  }

  void _addToDo() {
    if (_newTask.text.trim().isNotEmpty) {
      Map<String, dynamic> newToDo = Map<String, dynamic>();
      newToDo["title"] = _newTask.text;
      _newTask.text = "";
      newToDo["finished"] = false;
      setState(() {
        _toDoList.add(newToDo);
      });
      file.saveData(_toDoList);
    } else {
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text("Digite uma tarefa!"),
        ),
      );
    }
  }

  Future<Null> _refresh() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _toDoList.sort((a, b) {
        if (a["finished"] && !b["finished"])
          return 1;
        else if (!a["finished"] && b["finished"])
          return -1;
        else
          return 0;
      });
    });
    file.saveData(_toDoList);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text("To Do List"),
          centerTitle: true,
          backgroundColor: Colors.blueGrey,
        ),
        body: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Theme(
                      data: ThemeData(
                        primaryColor: Colors.blueGrey,
                      ),
                      child: TextField(
                        controller: _newTask,
                        decoration: InputDecoration(
                          labelText: "New Task",
                          contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                        ),
                      ),
                    ),
                  ),
                  RaisedButton(
                    onPressed: _addToDo,
                    child: Text("ADD"),
                    textColor: Colors.white,
                    color: Colors.blueGrey,
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                child: ListView.builder(
                  padding: EdgeInsets.only(top: 8.0),
                  itemCount: _toDoList.length,
                  itemBuilder: (context, index) {
                    return Dismissible(
                      onDismissed: (d) {
                        _lastRemoved = Map.from(_toDoList[index]);
                        _lastRemovedPos = index;
                        setState(() {
                          _toDoList.removeAt(index);
                        });
                        file.saveData(_toDoList);
                        Scaffold.of(context).showSnackBar(
                          SnackBar(
                            action: SnackBarAction(
                              label: "Desfazer",
                              onPressed: () {
                                setState(() {
                                  _toDoList.insert(
                                      _lastRemovedPos, _lastRemoved);
                                });
                                file.saveData(_toDoList);
                              },
                            ),
                            duration: Duration(seconds: 3),
                            content: Text(
                              'Task "${_lastRemoved["title"]}" removed!',
                            ),
                          ),
                        );
                      },
                      direction: DismissDirection.startToEnd,
                      background: Container(
                        color: Colors.red,
                        child: Align(
                          alignment: Alignment(-0.9, 0.0),
                          child: Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      key: Key(
                        DateTime.now().millisecondsSinceEpoch.toString(),
                      ),
                      child: CheckboxListTile(
                        title: Text(_toDoList[index]["title"]),
                        secondary: CircleAvatar(
                          backgroundColor: Colors.blueGrey,
                          child: Icon(
                            _toDoList[index]["finished"]
                                ? Icons.check
                                : Icons.error,
                            color: Colors.white,
                          ),
                        ),
                        value: _toDoList[index]["finished"],
                        onChanged: (b) {
                          setState(() {
                            _toDoList[index]["finished"] = b;
                          });
                          file.saveData(_toDoList);
                        },
                      ),
                    );
                  },
                ),
                onRefresh: _refresh,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
