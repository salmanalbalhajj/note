class Note {
  late int? id;
  late String title;
  late String description;
  late String date;
  Note(
    this.id,
    this.title,
    this.description,
    this.date,
  );
  Map<String, Object> toMap() {
    return {
      "title": title,
      "description": description,
      "date": date,
    };
  }

  Note.toJson(Map<String, Object?> json)
      : id = int.tryParse(json["id"].toString()) ?? 0,
        title = json["title"].toString(),
        description = json["description"].toString(),
        date = json["date"].toString();
}
