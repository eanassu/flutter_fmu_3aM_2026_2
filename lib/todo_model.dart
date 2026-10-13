class Todo {
  int? id;
  String title;
  String description;
  bool isDone;
  Todo({this.id,required this.title,required this.description,this.isDone=false});
  Map<String,dynamic> toMap() {
    return {
      'id':id,
      'title':title,
      'description':description,
      'isDone':isDone?1:0
    };
  }
  factory Todo.fromMap(Map<String,dynamic> map) {
    return Todo(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      isDone: map['isDone']==1?true:false 
    );
  }
}