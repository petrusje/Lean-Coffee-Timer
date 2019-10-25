import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';


class Note {
  String id;
  String content;
  String owner;
  DateTime date_created;
  Color note_color;
  int votes;

  Note(this.id, this.content, this.owner, this.date_created, this.note_color, this.votes );

  Map<String, dynamic> toMap(bool forUpdate) {
    var data = {
      'id': utf8.encode(id),  //since id is auto incremented in the database we don't need to send it to the insert query.
      'content': utf8.encode( content ),
      'owner': utf8.encode(owner),
      'date_created': epochFromDate( date_created ),
      'note_color': note_color.value,
      'votes': votes  //  for later use for integrating archiving
    };
    if(forUpdate){
      data["id"] = this.id;
    } else 
      {
        var uuid = new Uuid();
        data["id"] = uuid.v1();
      }
    return data;
  }

// Converting the date time object into int representing seconds passed after midnight 1st Jan, 1970 UTC
int epochFromDate(DateTime dt) {
    return dt.millisecondsSinceEpoch ~/ 1000 ;
}

  factory Note.fromMap(Map<String, dynamic> json) {
    return Note(
      json['id'],
      utf8.decode(json['content']),
      utf8.decode(json['owner']),
      DateTime.fromMicrosecondsSinceEpoch(json['date_created']),
      Color(json['note_color']),
      json['votes']
  );
  }

// overriding toString() of the note class to print a better debug description of this custom class
@override toString() {
  return {
    'id': id,
    'owner': owner,
    'content': content ,
    'date_created': epochFromDate( date_created ),
    'note_color': note_color.toString(),
    'votes':votes
  }.toString();
}

}