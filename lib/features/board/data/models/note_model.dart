import 'package:flutter/material.dart';

class Note {
  final String uid;
  Offset position;
  String content;
  Size size;
  Color color;

  Note({
    required this.uid,
    required this.position,
    required this.content,
    required this.size,
    required this.color,
  });

  factory Note.fromMap(Map<String, dynamic> data, String docUid) {
    return Note(
      uid: docUid,
      position: Offset(data['x'], data['y']),
      size: Size(data['width'], data['height']),
      content: data['content'] ?? '',
      color: Color(data['color']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'x': position.dx,
      'y': position.dy,
      'width': size.width,
      'height': size.height,
      'content': content,
      'color': color.toARGB32(),
    };
  }
}
