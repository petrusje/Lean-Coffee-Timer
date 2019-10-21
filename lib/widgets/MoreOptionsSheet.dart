import 'package:flutter/material.dart';
import 'package:lean_coffee_timer/utils/Utility.dart';
import 'package:lean_coffee_timer/widgets/ColorSlider.dart';

enum moreOptions { delete, share, copy }

class MoreOptionsSheet extends StatefulWidget {
  final Color color;
  final void Function(Color) callBackColorTapped;

  final void Function(moreOptions) callBackOptionTapped;

  const MoreOptionsSheet(
      {Key key,
      this.color,
      this.callBackColorTapped,
      this.callBackOptionTapped})
      : super(key: key);

  @override
  _MoreOptionsSheetState createState() => _MoreOptionsSheetState();
}

class _MoreOptionsSheetState extends State<MoreOptionsSheet> {
  var note_color;

  @override
  void initState() {
    note_color = widget.color;
  }

  @override
  Widget build(BuildContext context) {
    final _size = MediaQuery.of(context).size;
    return SizedBox(
      height: _size.height,
      width: _size.width,
      child: Container(
        color: this.note_color,
        child: new Wrap(
          children: <Widget>[
            new ListTile(
                leading: new Icon(Icons.delete),
                title: new Text('Apagar permanentemente'),
                onTap: () {
                  Navigator.of(context).pop();
                  widget.callBackOptionTapped(moreOptions.delete);
                }),
            new ListTile(
                leading: new Icon(Icons.content_copy),
                title: new Text('Duplicar'),
                onTap: () {
                  Navigator.of(context).pop();
                  widget.callBackOptionTapped(moreOptions.copy);
                }),
            new ListTile(
                leading: new Icon(Icons.share),
                title: new Text('Compartilhar'),
                onTap: () {
                  Navigator.of(context).pop();
                  widget.callBackOptionTapped(moreOptions.share);
                }),
            new Padding(
              padding: EdgeInsets.only(left: 10, right: 10),
              child: SizedBox(
                height: 44,
                width: MediaQuery.of(context).size.width,
                child: ColorSlider(
                  callBackColorTapped: _changeColor,
                  // call callBack from notePage here
                  noteColor: note_color, // take color from local variable
                ),
              ),
            ),
            /*new Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 44,
                child: Center(
                    child: Text(CentralStation.stringForDatetime(
                        widget.date_last_edited))),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          ),*/
            new ListTile()
          ],
        ),
      ),
    );
  }

  void _changeColor(Color color) {
    setState(() {
      this.note_color = color;
      widget.callBackColorTapped(color);
    });
  }
}
