import 'package:flutter/material.dart';
import 'package:task_manager/features/board/data/models/note_model.dart';

class DraggableNote extends StatefulWidget {
  final Note note;
  final void Function(Note updated) onUpdate;
  final VoidCallback onDelete;

  const DraggableNote({
    super.key,
    required this.note,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  State<DraggableNote> createState() => _DraggableNoteState();
}

class _DraggableNoteState extends State<DraggableNote> {
  late Offset currentPosition;
  late Size size;
  late String content;
  late Color color;
  bool isDragging = false;

  @override
  void initState() {
    super.initState();
    currentPosition = widget.note.position;
    size = widget.note.size;
    content = widget.note.content;
    color = widget.note.color;
  }

  @override
  void didUpdateWidget(DraggableNote oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!isDragging) {
      currentPosition = widget.note.position;
      size = widget.note.size;
      content = widget.note.content;
      color = widget.note.color;
    }
  }

  void _updateNote() {
    widget.onUpdate(
      Note(
        uid: widget.note.uid,
        position: currentPosition,
        size: size,
        content: content,
        color: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: currentPosition,
      child: GestureDetector(
        onPanStart: (details) {
          setState(() {
            isDragging = true;
          });
        },
        onPanUpdate: (details) {
          setState(() => currentPosition += details.delta);
        },
        onPanEnd: (details) {
          setState(() {
            isDragging = false;
          });
          _updateNote();
        },
        onTap: () => _openEditDialog(context),
        child: Container(
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black12)],
          ),
          child: Stack(
            children: [
              Padding(padding: const EdgeInsets.all(8), child: Text(content)),
              Positioned(
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      size = Size(
                        (size.width + details.delta.dx).clamp(80, 400),
                        (size.height + details.delta.dy).clamp(60, 400),
                      );
                    });
                  },
                  onPanEnd: (details) {
                    _updateNote();
                  },
                  child: Icon(Icons.open_in_full, size: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openEditDialog(BuildContext context) {
    final controller = TextEditingController(text: content);
    Color selectedColor = color;

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text('Edit Note'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: controller),
              SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children:
                    [
                      Colors.yellow,
                      Colors.green,
                      Colors.pink,
                      Colors.blue,
                      Colors.orange,
                      Colors.white,
                    ].map((c) {
                      return GestureDetector(
                        onTap: () => selectedColor = c,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: c,
                            border: Border.all(
                              color: selectedColor == c
                                  ? Colors.black
                                  : Colors.grey,
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                widget.onDelete();
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                setState(() {
                  content = controller.text;
                  color = selectedColor;
                  _updateNote();
                });
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
