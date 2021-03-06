import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_webapp/constants/task_enum.dart';

final sharedPrefs = Preferences.prefs;

class Preferences {
  static final Preferences _prefs = Preferences();
  static Preferences get prefs => _prefs;
  late SharedPreferences instance;

  Future<void> init() async {
    instance = await SharedPreferences.getInstance();
  }

  List<dynamic> getTasksForActivity({required String activity}) {
    String? tasks = sharedPrefs.instance.getString("${activity}Tasks");
    List<dynamic> taskList = [];
    if (tasks != null) {
      taskList = jsonDecode(tasks);
    }

    return taskList;
  }

  void addTaskToActivity(
      {required int taskIdx,
      required String activity,
      required String description,
      required int steps,
      required int currSteps}) {
    var tasks = getTasksForActivity(activity: activity);
    List list = [taskIdx, steps, currSteps, description];
    tasks.add(list);
    final s = jsonEncode(tasks);
    sharedPrefs.instance.setString("${activity}Tasks", s);
  }

  void incrementProgressOfTask({
    required int taskIdx,
    required String activity,
  }) {
    var tasks = getTasksForActivity(activity: activity);
    for (var task in tasks) {
      if (task[TaskEnum.taskIdx.id] == taskIdx) {
        if (task[TaskEnum.taskSteps.id] != task[TaskEnum.taskCurrentSteps.id]) {
          task[TaskEnum.taskCurrentSteps.id]++;
        }
        break;
      }
    }
    final s = jsonEncode(tasks);
    sharedPrefs.instance.setString("${activity}Tasks", s);
  }

  void decrementProgressOfTask({
    required int taskIdx,
    required String activity,
  }) {
    var tasks = getTasksForActivity(activity: activity);
    for (var task in tasks) {
      if (task[TaskEnum.taskIdx.id] == taskIdx) {
        if (task[TaskEnum.taskCurrentSteps.id] > 0) {
          task[TaskEnum.taskCurrentSteps.id]--;
        }
        break;
      }
    }
    final s = jsonEncode(tasks);
    sharedPrefs.instance.setString("${activity}Tasks", s);
  }

  double getTotalProgressForActivity({
    required String activity,
  }) {
    var tasks = getTasksForActivity(activity: activity);
    double totalProgress = tasks.length as double;
    double currentProgress = 0.0;
    //add to currentProgress only if task is 100% done
    for (var task in tasks) {
      if (task[TaskEnum.taskSteps.id] == task[TaskEnum.taskCurrentSteps.id]) {
        currentProgress++;
      }
    }
    if (currentProgress != 0) {
      return currentProgress / totalProgress;
    }

    return 0;
  }

  void resetProgressFromAllTasksForActivity({
    required String activity,
  }) {
    var tasks = getTasksForActivity(activity: activity);
    for (var task in tasks) {
      task[TaskEnum.taskCurrentSteps.id] = 0;
    }
    final s = jsonEncode(tasks);
    sharedPrefs.instance.setString("${activity}Tasks", s);
  }

  void removeTaskFromActivity(
      {required String activity, required int taskIdx}) {
    var tasks = getTasksForActivity(activity: activity);
    for (var task in tasks) {
      if (task[TaskEnum.taskIdx.id] == taskIdx) {
        tasks.remove(task);
        break;
      }
    }
    final s = jsonEncode(tasks);
    sharedPrefs.instance.setString("${activity}Tasks", s);
  }

  void removeAllTasksFromActivity({required String activity}) {
    sharedPrefs.instance.remove("${activity}Tasks");
  }

  String getActivityName({required int activityIdx}) {
    late List<String>? items;
    items = sharedPrefs.instance.getStringList('activities');
    return items![activityIdx];
  }

  List<String> getAllActivityNames() {
    late List<String>? items;
    items = sharedPrefs.instance.getStringList('activities');
    items ??= [];
    return items;
  }

  void addActivity({required String activity}) {
    late List<String>? items = getAllActivityNames();
    items.add(activity);
    sharedPrefs.instance.setStringList('activities', items);
  }

  void removeActivity({required String activity}) {
    late List<String>? items = getAllActivityNames();
    items.remove(activity);
    removeAllTasksFromActivity(activity: activity);
    sharedPrefs.instance.setStringList('activities', items);
  }

  List<String> getAllNotes() {
    late List<String>? notes;
    notes = sharedPrefs.instance.getStringList('notes');
    notes ??= [];
    return notes;
  }

  void addNote({required String note}) {
    late List<String>? notes = getAllNotes();
    notes.add(note);
    sharedPrefs.instance.setStringList('notes', notes);
  }

  void removeAllNotes() {
    late List<String>? notes = getAllNotes();
    notes.clear();
    sharedPrefs.instance.setStringList("notes", notes);
  }

  void removeNoteFromNotes({required int noteIdx}) {
    late List<String>? notes = getAllNotes();
    notes.removeAt(noteIdx);
    sharedPrefs.instance.setStringList("notes", notes);
  }
}
