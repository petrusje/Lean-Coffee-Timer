import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lean_coffee_timer/data/data_provider.dart';
import 'package:lean_coffee_timer/data/database.dart';
import 'package:lean_coffee_timer/pages/tasks_page.dart';


import 'package:provider/provider.dart';
import 'package:lean_coffee_timer/widgets/ButtonNavyBar.dart';


void main()
{ 
  runApp(MyApp());
}


class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void dispose() {
    super.dispose();
  }

@override
  void initState() {
    DatabaseProvider db  = DatabaseProvider.db;
    db.getAll();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
      return MaterialApp(
      title: 'Lean Coffee',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: MainPage(title: 'Lean Coffee'),
    );
  }
}
class MainPage extends StatefulWidget {
  MainPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {

int currentIndex = 0;

final List<BottomNavyBarItem> naviItems = [
    BottomNavyBarItem(
      icon: Icon(Icons.home), 
      title: Text('Home'), 
      activeColor: Colors.deepPurpleAccent[100]),
    BottomNavyBarItem(
      icon: Icon(Icons.access_alarm),
      title:  Text('Timer'), 
      activeColor: Colors.pinkAccent[100]),
    BottomNavyBarItem(
      icon: Icon(Icons.comment),
      title:  Text('Temas'), 
      activeColor: Colors.amber[100]),
    BottomNavyBarItem(
      icon: Icon(Icons.settings),
      title:  Text('Config'),
      activeColor: Colors.cyan[100]),
  ]; 

  Widget _buildChild() {
  switch (currentIndex) {
    case 0:
      return Center(
            child: Container(
              child: Image.asset('images/logo.png'))
          );
    break;
    case 1:
      
      return ChangeNotifierProvider<DataProvider>(
        builder: 
        (context) => DataProvider(),
        child:  Consumer<DataProvider>(
          builder: (context, model, child) => TaskPage(),
        ),
      );
    break; 
    case 2:
      return Container();   
    break;
    case 3:
      return Container();   
    break;
  }
  return Container();
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: Text('Lean Coffee'),
      ),
      body: _buildChild(),
       bottomNavigationBar: SafeArea(
         child: BottomNavyBar(
          selectedIndex: currentIndex,
          items: naviItems,
          onItemSelected: (index) => setState(() {
              currentIndex = index;
            })
        )),
    );
  }
}

