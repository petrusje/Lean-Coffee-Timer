import 'package:flutter/material.dart';
import 'package:lean_coffee_timer/model/note_model.dart';
import 'package:lean_coffee_timer/pages/StaggeredView.dart';
import 'package:lean_coffee_timer/pages/note_page.dart';
import 'package:lean_coffee_timer/utils/Utility.dart';

enum viewType { List, Staggered }

class NotesPage extends StatefulWidget {
  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  var notesViewType;
  @override
  void initState() {
    notesViewType = viewType.Staggered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        brightness: Brightness.light,
        actions: _appBarActions(),
        elevation: 1,
        backgroundColor: Colors.white,
        centerTitle: false,
        title: Text("Temas",
            style: TextStyle(
                color: Colors.black,
                fontSize: 32.0,
                fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: _body(),
        right: true,
        left: true,
        top: true,
        bottom: true,
      ),
     
      floatingActionButton: FloatingActionButton(
          tooltip: "Novo Tema",
          child: Icon(Icons.add, size: 26, color: Colors.black),
          backgroundColor: Colors.white70,
          onPressed: () => _newNoteTapped(context),
        ),
    );
  }

  Widget _body() {
    print(notesViewType);
    return Container(
        child: StaggeredGridPage(
      notesViewType: notesViewType,
    ));
  }


  void _newNoteTapped(BuildContext ctx) {
    // "-1" id indicates the note is not new
    var emptyNote = new Note("", "", "", DateTime.now(), Colors.white, 0);
    Navigator.push(
        ctx, MaterialPageRoute(builder: (ctx) => NotePage(emptyNote)));
  }

 
  void _toggleViewType() {
    setState(() {
      CentralStation.updateNeeded = true;
      if (notesViewType == viewType.List) {
        notesViewType = viewType.Staggered;
      } else {
        notesViewType = viewType.List;
      }
    });
  }

  List<Widget> _appBarActions() {
    return [
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: InkWell(
          child: GestureDetector(
            onTap: () => _toggleViewType(),
            child: Icon(
              notesViewType == viewType.List
                  ? Icons.developer_board
                  : Icons.view_headline,
              color: CentralStation.fontColor,
            ),
          ),
        ),
      ),
    ];
  }
}
