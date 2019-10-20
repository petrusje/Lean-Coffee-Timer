import 'package:flutter/cupertino.dart';
import 'package:lean_coffee_timer/model/task_model.dart';
import "package:lean_coffee_timer/data/database.dart";

class DataProvider with ChangeNotifier {
  static final DatabaseProvider dbProvider = DatabaseProvider.db;
  List<Task> _tasks = List<Task>();

  List<Task> getTasks() {
    if (_tasks.isEmpty) _loadAllTasks().then((list) => {_tasks = list});
    return _tasks;
  }

  void updatetasks() {
    _loadAllTasks().then((list) => {_tasks = list});
    notifyListeners();
  }

  Future<void> addNewTask(Task task) async {
    dbProvider.insert(task);
    updatetasks();
  }

  Future<List<Task>> _loadAllTasks() async {
    final data = await dbProvider.getAll();
    return data;
  }

  Future<void> deleteTask(Task task) async {
    dbProvider.delete(task.id);
    updatetasks();
  }
}
