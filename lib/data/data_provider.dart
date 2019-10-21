import 'dart:async';

import 'package:lean_coffee_timer/data/database.dart';
import 'package:flutter/cupertino.dart';
import 'package:lean_coffee_timer/model/task_model.dart';

class TaskDataProvider with ChangeNotifier {
  List<Task> _tasks = List<Task>();

  Future<List<Task>> getTasks() async {
    if (_tasks.isEmpty) {
      _tasks = await _loadAllTasks();
    }    
    return _tasks;
  }

  void updatetasks() {
    _loadAllTasks().then((list) => {_tasks = list});
    notifyListeners();
  }

  Future<void> addNewTask(Task task) async {
    DatabaseProvider.db.insertTask(task);
    updatetasks();
  }

  Future<List<Task>> _loadAllTasks() async {
    final data = await DatabaseProvider.db.getAllTasks();
    return data;
  }

  Future<void> deleteTask(Task task) async {
    DatabaseProvider.db.deleteTask(task.id);
    updatetasks();
  }

  
}
