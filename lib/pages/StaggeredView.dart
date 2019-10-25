import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:lean_coffee_timer/data/database.dart';
import 'package:lean_coffee_timer/model/note_model.dart';
import 'package:lean_coffee_timer/pages/notes_page.dart';
import 'package:lean_coffee_timer/utils/Utility.dart';
import 'package:lean_coffee_timer/widgets/StaggeredTiles.dart';

class StaggeredGridPage extends StatefulWidget {
  final notesViewType;
  const StaggeredGridPage({Key key, this.notesViewType}) : super(key: key);
  @override
  _StaggeredGridPageState createState() => _StaggeredGridPageState();
}

class _StaggeredGridPageState extends State<StaggeredGridPage> {
  var noteDB = DatabaseProvider.db;
  viewType notesViewType;

  @override
  void initState() {
    super.initState();
    this.notesViewType = widget.notesViewType;
  }

  @override
  void setState(fn) {
    super.setState(fn);
    this.notesViewType = widget.notesViewType;
  }

  Widget _buildChild(BuildContext context, AsyncSnapshot snapshot) {
    GlobalKey _stagKey = GlobalKey();
    List<Note> notes = snapshot.data;
    if ( snapshot.data == null || notes.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('Sem sugestões de Tema',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text('Adicione um novo Tema e ele \nSerá exibido aqui.',
                textAlign: TextAlign.center)
          ],
        ),
      );
    } else
    {
        return StaggeredGridView.count(
        key: _stagKey,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
        crossAxisCount: _colForStaggeredView(context),
        children: getTiles(notes), 
        staggeredTiles: _tilesForView(notes.length),
      );
    }
  }

 List<Widget> getTiles(List<Note> notes) 
  {
    List<Widget> tiles = new List<Widget>();
    for(int i=0; i < notes.length;i++)
      tiles.add(MyStaggeredTile(notes[i]));
    return tiles;
  }

  @override
  Widget build(BuildContext context) {
    print("update necessário?: ${CentralStation.updateNeeded}");
    if (CentralStation.updateNeeded) {
      changeState();
    }
    return Container(
        child: Padding(
      padding: _paddingForView(context),
      child: FutureBuilder(
          future: noteDB.selectAllNotes(),
          builder: ((BuildContext context, AsyncSnapshot snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return new Text('carregando...');
              default:
                if (snapshot.hasError)
                  return new Text('Erro: ${snapshot.error}');
                else
                  return _buildChild(context, snapshot);
            }
          })),
    ));
  }

  int _colForStaggeredView(BuildContext context) {
    if (widget.notesViewType == viewType.List) return 1;
    // for width larger than 600 on grid mode, return 3 irrelevant of the orientation to accommodate more notes horizontally
    return MediaQuery.of(context).size.width > 600 ? 3 : 2;
  }

  List<StaggeredTile> _tilesForView(int length) {
    // Generate staggered tiles for the view based on the current preference.
    return List.generate(length, (index) {
      return StaggeredTile.fit(1);
    });
  }

  EdgeInsets _paddingForView(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double padding;
    double top_bottom = 8;
    if (width > 500) {
      padding = (width) * 0.05; // 5% padding of width on both side
    } else {
      padding = 8;
    }
    return EdgeInsets.only(
        left: padding, right: padding, top: top_bottom, bottom: top_bottom);
  }

  void changeState() {
    // queries for all the notes from the database ordered by latest edited note. excludes archived notes.

    setState(() {
      CentralStation.updateNeeded = false;
    });
  }
}
