import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../data/models/note_model.dart';

abstract class INotesRepository {
  Future<void> addNote(Offset position, String content, Size size, Color color);
  Future<void> updateNote(Note note);
  Future<void> deleteNote(String uid);
}

class NotesRepository implements INotesRepository {
  final FirebaseFirestore _firestore;

  NotesRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> addNote(
    Offset position,
    String content,
    Size size,
    Color color,
  ) async {
    final projectRef = _firestore.collection('notes').doc();

    final note = Note(
      uid: projectRef.id,
      position: position,
      content: content,
      size: size,
      color: color,
    );
    await _firestore.collection('notes').add(note.toMap());
  }

  @override
  Future<void> updateNote(Note note) async {
    await _firestore.collection('notes').doc(note.uid).update(note.toMap());
  }

  @override
  Future<void> deleteNote(String uid) async {
    await _firestore.collection('notes').doc(uid).delete();
  }
}
