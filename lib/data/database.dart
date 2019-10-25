import 'dart:async';
import 'dart:io';
import 'package:lean_coffee_timer/model/note_model.dart';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:lean_coffee_timer/model/task_model.dart';
import 'package:uuid/uuid.dart';

class DatabaseProvider {
  DatabaseProvider._();

  static final DatabaseProvider db = DatabaseProvider._();
  static Database _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database;
    }

    _database = await initDb();
    return _database;
  }

  initDb() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, 'leancoffee.db');

    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      await db.execute('CREATE TABLE Task ('
          'id INTEGER PRIMARY KEY,'
          'color INTEGER,'
          'title TEXT,'
          'hours INTEGER,'
          'minutes INTEGER,'
          'seconds INTEGER'
          ')');

      await db.execute('CREATE TABLE notes ('
          'id TEXT PRIMARY KEY,'
          'content BLOB,'
          'owner TEXT,'
          'date_created INTEGER,'
          'note_color INTEGER,'
          'votes INTEGER'
          ')');
    });
  }

// task Functions
  insertTask(Task task) async {
    print('Saving Task...');

    var db = await database;

    var table = await db.rawQuery('SELECT MAX(id)+1 as id FROM Task');
    var id = table.first['id'];

    var raw = db.rawInsert(
        'INSERT Into Task (id, color, title, hours, minutes, seconds) VALUES (?,?,?,?,?,?)',
        [
          id,
          task.color.value,
          task.title,
          task.hours,
          task.minutes,
          task.seconds
        ]);

    print('Task saved :)');
    return raw;
  }

  Future<List<Task>> getAllTasks() async {
    print('getting tasks...');

    var db = await database;
    var query = await db.query('Task');

    List<Task> tasks =
        query.isNotEmpty ? query.map((t) => Task.fromMap(t)).toList() : [];

    print('tasks in database: ${tasks.length}');
    return tasks;
  }

  Future<void> deleteTask(int id) async {
    var db = await database;
    await db.rawDelete('DELETE FROM Task WHERE id = ?', [id]);
  }

  // discussionthemes

  Future<String> insertNote(Note note, bool isNew) async {
    // Get a reference to the database
    final Database db = await database;
    print("insert called");

    // Insert the Notes into the correct table.
    await db.insert(
      'notes',
      isNew ? note.toMap(false) : note.toMap(true),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    if (isNew) {
      // generate a new uuid
      var uuid = new Uuid();
      String latestId = uuid.v1();
      return latestId;
    }
    return note.id;
  }

  Future<bool> deleteNote(Note note) async {
    if (note.id != '') {
      final Database db = await database;
      try {
        await db.delete("notes", where: "id = '?'", whereArgs: [note.id]);
        return true;
      } catch (Error) {
        print("Erro delatando ${note.id}: ${Error.toString()}");
        return false;
      }
    }
    return false;
  }

  Future<List<Note>> selectAllNotes() async {
    final Database db = await database;
    // query all the notes sorted by last edited
     
    var query = await db.query("notes",
    columns: ["id", "content", "owner", "date_created", "note_color", "votes"],
     orderBy: "date_created desc");
    List<Note> notes =
        query.isNotEmpty ? query.map((t) => Note.fromMap(t)).toList() : [];
    return notes;
  }

  Future<List<Map<String, dynamic>>> selectAllNotesMap() async {
    final Database db = await database;
    // query all the notes sorted by last edited
    var data = await db.query("notes", orderBy: "date_created desc");
    return data;
  }

  Future<bool> copyNote(Note note) async {
    final Database db = await database;
    try {
      await db.insert("notes", note.toMap(false),
          conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (Error) {
      print(Error);
      return false;
    }
    return true;
  }

  Future<bool> archiveNote(Note note) async {
    return true;
  }
}
