import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_manager/features/board/domain/notes_provider.dart';
import '../widgets/draggable_note.dart';

class BoardScreen extends ConsumerWidget {
  const BoardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(notesProvider);
    final noteController = ref.read(notesRepositoryProvider);

    void addNote(Offset offset) {
      noteController.addNote(offset, 'New Note', Size(150, 100), Colors.yellow);
    }

    return Scaffold(
      appBar: AppBar(title: Text('Cloud Notes')),
      body: GestureDetector(
        onTapDown: (details) {
          final offset = details.localPosition;
          addNote(offset);
        },
        child: Stack(
          children: [
            Container(color: Colors.grey[100]),
            ...notes.map((note) {
              return DraggableNote(
                note: note,
                onUpdate: (updatedNote) =>
                    noteController.updateNote(updatedNote),
                onDelete: () => noteController.deleteNote(note.uid),
              );
            }),
          ],
        ),
      ),
    );
  }
}
