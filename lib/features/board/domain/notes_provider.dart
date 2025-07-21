import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task_manager/features/board/domain/notes_repository.dart';
import '../data/models/note_model.dart';

final notesRepositoryProvider = Provider<INotesRepository>((ref) {
  return NotesRepository();
});

final notesProvider = StateNotifierProvider<NoteController, List<Note>>((ref) {
  return NoteController(ref);
});

class NoteController extends StateNotifier<List<Note>> {
  final Ref ref;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  NoteController(this.ref) : super([]) {
    _listenToNotes();
  }

  void _listenToNotes() {
    firestore.collection('notes').snapshots().listen((snapshot) {
      final notes = snapshot.docs
          .map((doc) => Note.fromMap(doc.data(), doc.id))
          .toList();
      state = notes;
    });
  }
}
