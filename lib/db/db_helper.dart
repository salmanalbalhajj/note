import 'package:note/model/note_.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DbHelper {
  static late final Database db;

  // دالة لتهيئة قاعدة البيانات
  static Future<void> initDB() async {
    db = await openDatabase(
      join(await getDatabasesPath(), 'task.db'), // استخدام join لبناء المسار
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE tasks (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, description TEXT, date TEXT)",
        );
      },
    );
  }

  // دالة لجلب جميع المهام
  static Future<List<Map<String, Object?>>> getAllTasks() async {
    return await db.query("tasks");
  }

  // دالة لإضافة مهمة جديدة
  static Future<int> addTask(Note task) async {
    return await db.insert("tasks", task.toMap());
  }

  // دالة لتحديث مهمة موجودة
  static Future<int> updateTask(Note task, int id) async {
    return await db
        .update("tasks", task.toMap(), where: 'id = ?', whereArgs: [id]);
  }

  // دالة لحذف مهمة
  static Future<int> deleteTask(int id) async {
    return await db.delete("tasks", where: "id = ?", whereArgs: [id]);
  }
}
