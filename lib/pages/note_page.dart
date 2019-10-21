import 'package:flutter/material.dart';
import 'dart:async';
import 'package:share/share.dart';
import 'package:flutter/services.dart';

import 'package:lean_coffee_timer/model/note_model.dart';
import 'package:lean_coffee_timer/utils/Utility.dart';
import 'package:lean_coffee_timer/widgets/MoreOptionsSheet.dart';
import 'package:lean_coffee_timer/data/database.dart';

class NotePage extends StatefulWidget {
  final Note noteInEditing;

  NotePage(this.noteInEditing);
  @override
  _NotePageState createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {

  final _contentController = TextEditingController();
  var note_color;
  bool _isNewNote = false;
  final _titleFocus = FocusNode();
  final _contentFocus = FocusNode();

  String _ownerFrominitial;
  String _contentFromInitial;
  DateTime _lastEditedForUndo;

  var _editableNote;

  // the timer variable responsible to call persistData function every 5 seconds and cancel the timer when the page pops.
  Timer _persistenceTimer;

  final GlobalKey<ScaffoldState> _globalKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    _editableNote = widget.noteInEditing;
    _contentController.text = _editableNote.content;
    note_color = _editableNote.note_color;

    _ownerFrominitial = widget.noteInEditing.owner;
    _contentFromInitial = widget.noteInEditing.content;

    if (widget.noteInEditing.id == "") {
      _isNewNote = true;
    }
    _persistenceTimer = new Timer.periodic(Duration(seconds: 5), (timer) {
      // call insert query here
      print("5 seconds passed");
      print("editable note id: ${_editableNote.id}");
      _persistData();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_editableNote.id == "" && _editableNote.owner.isEmpty) {
      FocusScope.of(context).requestFocus(_titleFocus);
    }

    return WillPopScope(
      child: Scaffold(
        key: _globalKey,
        appBar: AppBar(
          brightness: Brightness.light,
          leading: BackButton(
            color: Colors.black,
          ),
          actions: _archiveAction(context),
          elevation: 1,
          backgroundColor: note_color,
          title: Text(_editableNote.id == "" ? "Novo Tema" : "Editar Tema",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 28.0,
                  fontWeight: FontWeight.bold)),
        ),
        body: _body(context),
      ),
      onWillPop: _readyToPop,
    );
  }

  Widget _body(BuildContext ctx) {
    return Container(
        color: note_color,
        padding: EdgeInsets.only(left: 16, right: 16, top: 12),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Flexible(
                  child: Card(
                      shape: const RoundedRectangleBorder(
                        side: BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.all(Radius.circular(15.0)),
                      ),
                      child: Container(
                          padding: EdgeInsets.only(left: 16, right: 16, top: 12),
                          //    decoration: BoxDecoration(border: Border.all(color: CentralStation.borderColor,width: 1),borderRadius: BorderRadius.all(Radius.circular(10)) ),
                          child: EditableText(
                            onChanged: (str) => {updateNoteObject()},
                            maxLines: 300, // line limit extendable later
                            controller: _contentController,
                            focusNode: _contentFocus,
                            style: TextStyle(color: Colors.black, fontSize: 20),
                            backgroundCursorColor: Colors.red,
                            cursorColor: Colors.blue,
                          ))))
            ],
          ),
          left: true,
          right: true,
          top: false,
          bottom: false,
        ));
  }

  List<Widget> _archiveAction(BuildContext context) {
    List<Widget> actions = [];
    if (widget.noteInEditing.id != "") {
      actions.add(Padding(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: InkWell(
          child: GestureDetector(
            onTap: () => _undo(),
            child: Icon(
              Icons.undo,
              color: CentralStation.fontColor,
            ),
          ),
        ),
      ));
    }
    actions += [
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: InkWell(
          child: GestureDetector(
            onTap: () => bottomSheet(context),
            child: Icon(
              Icons.more_vert,
              color: CentralStation.fontColor,
            ),
          ),
        ),
      ),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: InkWell(
          child: GestureDetector(
            onTap: () => {_saveAndStartNewNote(context)},
            child: Icon(
              Icons.add,
              color: CentralStation.fontColor,
            ),
          ),
        ),
      )
    ];
    return actions;
  }

  void bottomSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext ctx) {
          return MoreOptionsSheet(
            color: note_color,
            callBackColorTapped: _changeColor,
            callBackOptionTapped: bottomSheetOptionTappedHandler,
          );
        });
  }

  void _persistData() {
    updateNoteObject();

    if (_editableNote.content.isNotEmpty) {
      var noteDB = DatabaseProvider.db;

      if (_editableNote.id == "") {
        Future<String> autoIncrementedId =
            noteDB.insertNote(_editableNote, true); // for new note
        // set the id of the note from the database after inserting the new note so for next persisting
        autoIncrementedId.then((value) {
          _editableNote.id = value;
        });
      } else {
        noteDB.insertNote(
            _editableNote, false); // for updating the existing note
      }
    }
  }

// this function will ne used to save the updated editing value of the note to the local variables as user types
  void updateNoteObject() {
    _editableNote.content = _contentController.text;
    _editableNote.note_color = note_color;
    print("novo conteúdo: ${_editableNote.content}");
    print(widget.noteInEditing);
    print(_editableNote);

    //print("mesmo titulo? ${_editableNote.title == _titleFrominitial}");
    print("mesmo tema? ${_editableNote.content == _contentFromInitial}");

    if (!(_editableNote.owner == _ownerFrominitial &&
            _editableNote.content == _contentFromInitial) ||
        (_isNewNote)) {
      CentralStation.updateNeeded = true;
    }
  }

  void bottomSheetOptionTappedHandler(moreOptions tappedOption) {
    print("opcão tapped: $tappedOption");
    switch (tappedOption) {
      case moreOptions.delete:
        {
          if (_editableNote.id != -1) {
            _deleteNote(_globalKey.currentContext);
          } else {
            _exitWithoutSaving(context);
          }
          break;
        }
      case moreOptions.share:
        {
          if (_editableNote.content.isNotEmpty) {
            Share.share("${_editableNote.owner}\n${_editableNote.content}");
          }
          break;
        }
      case moreOptions.copy:
        {
          _copy();
          break;
        }
    }
  }

  void _deleteNote(BuildContext context) {
    if (_editableNote.id != -1) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Confirma ?"),
              content: Text("Essa sugestão de Tema será excluído"),
              actions: <Widget>[
                FlatButton(
                    onPressed: () {
                      _persistenceTimer.cancel();
                      var noteDB = DatabaseProvider.db;
                      Navigator.of(context).pop();
                      noteDB.deleteNote(_editableNote);
                      CentralStation.updateNeeded = true;

                      Navigator.of(context).pop();
                    },
                    child: Text("Sim")),
                FlatButton(
                    onPressed: () => {Navigator.of(context).pop()},
                    child: Text("Não"))
              ],
            );
          });
    }
  }

  void _changeColor(Color newColorSelected) {
    print("note color changed");
    setState(() {
      note_color = newColorSelected;
      _editableNote.note_color = newColorSelected;
    });
    _persistColorChange();
    CentralStation.updateNeeded = true;
  }

  void _persistColorChange() {
    if (_editableNote.id != -1) {
      var noteDB = DatabaseProvider.db;
      _editableNote.note_color = note_color;
      noteDB.insertNote(_editableNote, false);
    }
  }

  void _saveAndStartNewNote(BuildContext context) {
    _persistenceTimer.cancel();
    var emptyNote = new Note("", "", "", DateTime.now(), Colors.white, 0);
    Navigator.of(context).pop();
    Navigator.push(
        context, MaterialPageRoute(builder: (ctx) => NotePage(emptyNote)));
  }

  Future<bool> _readyToPop() async {
    _persistenceTimer.cancel();
    //show saved toast after calling _persistData function.

    _persistData();
    return true;
  }

  void _archivePopup(BuildContext context) {
    if (_editableNote.id != -1) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Confirma ?"),
              content: Text("Essa nota será arquivada"),
              actions: <Widget>[
                FlatButton(
                    onPressed: () => _archiveThisNote(context),
                    child: Text("Sim")),
                FlatButton(
                    onPressed: () => {Navigator.of(context).pop()},
                    child: Text("Não"))
              ],
            );
          });
    } else {
      _exitWithoutSaving(context);
    }
  }

  void _exitWithoutSaving(BuildContext context) {
    _persistenceTimer.cancel();
    CentralStation.updateNeeded = false;
    Navigator.of(context).pop();
  }

  void _archiveThisNote(BuildContext context) {
    Navigator.of(context).pop();
    // set archived flag to true and send the entire note object in the database to be updated
    _editableNote.is_archived = 1;
    var noteDB = DatabaseProvider.db;
    noteDB.archiveNote(_editableNote);
    // update will be required to remove the archived note from the staggered view
    CentralStation.updateNeeded = true;
    _persistenceTimer.cancel(); // shutdown the timer

    Navigator.of(context).pop(); // pop back to staggered view
    // TODO: OPTIONAL show the toast of deletion completion
    Scaffold.of(context).showSnackBar(new SnackBar(content: Text("Apagado")));
  }

  void _copy() {
    var noteDB = DatabaseProvider.db;
    Note copy = Note("", _editableNote.owner, _editableNote.content,
        DateTime.now(), _editableNote.note_color, 0);

    var status = noteDB.copyNote(copy);
    status.then((query_success) {
      if (query_success) {
        CentralStation.updateNeeded = true;
        Navigator.of(_globalKey.currentContext).pop();
      }
    });
  }

  void _undo() {
    _contentController.text =
        _contentFromInitial; // widget.noteInEditing.content;
  }
}
