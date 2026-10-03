import 'package:flutter/material.dart';
import '../../data/local/database.dart';
import '../../data/local/fixture_repository.dart';

class EditorDraft extends ChangeNotifier {
  EditorDraft(FixtureItem item)
    : id = item.id,
      _committedTitle = item.title,
      _committedNotes = item.notes,
      _observedTitle = item.title,
      _observedNotes = item.notes,
      title = TextEditingController(text: item.title),
      notes = TextEditingController(text: item.notes) {
    title.addListener(_changed);
    notes.addListener(_changed);
  }
  final String id;
  String _committedTitle;
  String _committedNotes;
  String _observedTitle;
  String _observedNotes;
  final TextEditingController title;
  final TextEditingController notes;
  final titleFocus = FocusNode(debugLabel: 'Fixture title');
  final notesFocus = FocusNode(debugLabel: 'Fixture notes');
  bool dirty = false;
  bool saving = false;
  String? message;
  bool _refreshing = false;
  void _changed() {
    if (_refreshing) return;
    if (title.text == _observedTitle && notes.text == _observedNotes) return;
    _observedTitle = title.text;
    _observedNotes = notes.text;
    dirty = title.text != _committedTitle || notes.text != _committedNotes;
    message = null;
    notifyListeners();
  }

  void acceptCommitted(FixtureItem item) {
    if (dirty || saving || titleFocus.hasFocus || notesFocus.hasFocus) return;
    _refreshing = true;
    try {
      if (title.text != item.title) title.text = item.title;
      if (notes.text != item.notes) notes.text = item.notes;
      _committedTitle = item.title;
      _committedNotes = item.notes;
      _observedTitle = item.title;
      _observedNotes = item.notes;
    } finally {
      _refreshing = false;
    }
  }

  Future<void> save(FixtureRepository repository) async {
    if (saving) return;
    final proposedTitle = title.text;
    final proposedNotes = notes.text;
    saving = true;
    message = null;
    notifyListeners();
    try {
      await repository.save(id, proposedTitle, proposedNotes);
      _committedTitle = proposedTitle;
      _committedNotes = proposedNotes;
      dirty = title.text != proposedTitle || notes.text != proposedNotes;
      message = dirty
          ? 'Saved earlier text; newer draft is unsaved.'
          : 'Saved on this device';
    } catch (e) {
      message = 'Not saved. Draft retained. $e';
    } finally {
      saving = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    title.dispose();
    notes.dispose();
    titleFocus.dispose();
    notesFocus.dispose();
    super.dispose();
  }
}
