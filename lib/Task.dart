class Task {
  String id;
  String task;
  bool status;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> m = {};
    m['id'] = id;
    m['task'] = task;
    m['status'] = status;
    return m;
  }

  Task({required this.id, required this.task, required this.status});

  static Task fromJson(Map<String, dynamic> m) {
    return Task(id: m['id'], task: m['task'], status: m['status']);
  }
}
