import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pet.dart';

class PersistenceService {
  static const String _saveKey = 'tamabrawler_save';

  Future<void> savePet(Pet pet) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(pet.toJson());
    await prefs.setString(_saveKey, jsonString);
  }

  Future<Pet?> loadPet() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_saveKey);
    if (jsonString != null) {
      try {
        final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
        return Pet.fromJson(jsonMap);
      } catch (e) {
        print('Error loading pet: $e');
        return null;
      }
    }
    return null;
  }
}
