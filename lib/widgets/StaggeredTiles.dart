import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:lean_coffee_timer/model/note_model.dart';
import 'package:lean_coffee_timer/pages/note_page.dart';
import 'package:lean_coffee_timer/utils/Utility.dart';

class MyStaggeredTile extends StatefulWidget {
  final Note note;
  MyStaggeredTile(this.note);
  @override
  _MyStaggeredTileState createState() => _MyStaggeredTileState();
}

class _MyStaggeredTileState extends State<MyStaggeredTile> {
  String _content;
  double _fontSize;
  Color tileColor;
  String title;

  @override
  Widget build(BuildContext context) {
    _content = widget.note.content;
    _fontSize = 12.0; //_determineFontSizeForContent();
    tileColor = widget.note.note_color;
    title = "Votos:${widget.note.votes}";

    return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => _noteTapped(context),
        child: Container(
            decoration: BoxDecoration(
                border: tileColor == Colors.white
                    ? Border.all(color: CentralStation.borderColor)
                    : null,
                color: tileColor,
                borderRadius: BorderRadius.all(Radius.circular(8))),
            padding: EdgeInsets.all(8),
            child: constructChild()));
  }

  void _noteTapped(BuildContext ctx) {
    CentralStation.updateNeeded = false;
    Navigator.push(
        ctx, MaterialPageRoute(builder: (ctx) => NotePage(widget.note)));
  }

  Widget constructChild() {
    List<Widget> contentsOfTiles = [];
    // Tema
    contentsOfTiles.add(AutoSizeText(
      _content,
      style: TextStyle(fontSize: _fontSize),
      maxLines: 10,
      textScaleFactor: 1.5,
    ));

    contentsOfTiles.add(
      Divider(
        color: Colors.blueGrey,
        height: 6,
      ),
    );

    if ("Votos:${widget.note.votes}".length != 0) {
      contentsOfTiles.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            AutoSizeText(
              title,
              style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.normal,
                  color: Colors.grey),
              maxLines: "Votos:${widget.note.votes}".length == 0 ? 1 : 3,
              textScaleFactor: 1.5,
              textAlign: TextAlign.right,
            )
          ],
        ),
      );
    }

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: contentsOfTiles);
  }

  double _determineFontSizeForContent() {
    int charCount = _content.length + "Votos:${widget.note.votes}".length;
    double fontSize = 20;
    if (charCount > 110) {
      fontSize = 12;
    } else if (charCount > 80) {
      fontSize = 14;
    } else if (charCount > 50) {
      fontSize = 16;
    } else if (charCount > 20) {
      fontSize = 18;
    }

    return fontSize;
  }
}
