import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lean_coffee_timer/data/data_provider.dart';
import 'package:lean_coffee_timer/model/task_model.dart';
import 'package:lean_coffee_timer/pages/bottom_sheet.dart';
import 'package:lean_coffee_timer/pages/new_task_page.dart';
import 'package:lean_coffee_timer/widgets/task_widget.dart';
import 'package:provider/provider.dart';

class TaskPage extends StatefulWidget {
  final String title = 'Timers';

  @override
  _TaskPageState createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  
@override
  void initState() {
    DataProvider();
    super.initState();
  }

  void _openBottomSheet() async {
    final newTask = await showCustomModalBottomSheet<Task>(
        context: context,
        builder: (context) {
          return GestureDetector(
            onTap: () {},
            child: Container(
              color: Color(0xFF737373),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: NewTaskPage(),
              ),
            ),
          );
        });

    if (newTask != null) {
      Provider.of<DataProvider>(context).addNewTask(newTask);
    }
  }

  Widget _buildChild() {
    List<Task> tasks = Provider.of<DataProvider>(context).getTasks();
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('Sem timers',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text('Adicione um novo Timer e ele \nSerá exibido aqui.',
                textAlign: TextAlign.center)
          ],
        ),
      );
    }
    return ListView.builder(
      itemCount: tasks.length,
      padding: const EdgeInsets.only(top: 8),
      itemBuilder: (BuildContext context, int index) {
        final Task item = tasks.elementAt(index);
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Dismissible(
            background: Container(color: Colors.red),
            direction: DismissDirection.endToStart,
            key: ObjectKey(item),
            child: TaskWidget(task: item),
            onDismissed: (direction) {
              tasks.remove(item);
              Provider.of<DataProvider>(context).deleteTask(item);
              setState(() {});

              Scaffold.of(context)
                  .showSnackBar(SnackBar(content: Text("Timer excluido!")));
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<DataProvider>(
      builder: (context) => DataProvider(),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: false,
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          title: Text(
            widget.title,
            style: TextStyle(
                color: Colors.black,
                fontSize: 32.0,
                fontWeight: FontWeight.bold),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add, size: 26, color: Colors.black),
          backgroundColor: Colors.white,
          onPressed: _openBottomSheet,
        ),
        body: _buildChild(),
      ),
    );
  }
}
