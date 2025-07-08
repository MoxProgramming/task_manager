import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  static const String _selectedProjectKey = 'selected_project';
  static const String _selectedProjectUidKey = 'selected_project_uid';

  static Future<void> saveSelectedProject(
    String projectName,
    String uid,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedProjectKey, projectName);
    await prefs.setString(_selectedProjectUidKey, uid);
  }

  static Future<String?> getSelectedProjectName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_selectedProjectKey);
  }

  static Future<String?> getSelectedProjectUid() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_selectedProjectUidKey);
  }

  static Future<void> clearSelectedProject() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_selectedProjectKey);
    await prefs.remove(_selectedProjectUidKey);
  }

  static Future<bool> hasSelectedProject() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_selectedProjectKey) &&
        prefs.containsKey(_selectedProjectUidKey);
  }
}
