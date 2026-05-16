import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/plant.dart';

class SupabaseService {
  final _supabase = Supabase.instance.client;

  Future<List<Plant>> fetchPlants() async {
    try {
      final response = await _supabase
          .from('plants')
          .select()
          .order('created_at', ascending: false);
      
      return (response as List).map((json) => Plant.fromJson(json)).toList();
    } on PostgrestException catch (e) {
      throw 'Database Error: ${e.message}';
    } catch (e) {
      throw 'Connection Error: $e';
    }
  }

  Future<void> addPlant(Plant plant) async {
    try {
      await _supabase.from('plants').insert(plant.toJson());
    } on PostgrestException catch (e) {
      throw 'Add Failed: ${e.message}';
    }
  }

  Future<void> updatePlant(Plant plant) async {
    try {
      await _supabase
          .from('plants')
          .update(plant.toJson())
          .eq('id', plant.id);
    } on PostgrestException catch (e) {
      throw 'Update Failed: ${e.message}';
    }
  }

  Future<void> deletePlant(String id) async {
    try {
      await _supabase.from('plants').delete().eq('id', id);
    } on PostgrestException catch (e) {
      throw 'Delete Failed: ${e.message}';
    }
  }

  Future<void> waterPlant(Plant plant) async {
    try {
      final now = DateTime.now();
      final updatedPlant = plant.copyWith(lastWatered: now);
      await updatePlant(updatedPlant);
      
      // Also log to history
      await _supabase.from('watering_history').insert({
        'plant_id': plant.id,
        'watered_at': now.toIso8601String(),
      });
    } catch (e) {
      // Even if history log fails, we consider the plant watered in the main table
      print('History log failed: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchRecentHistory() async {
    try {
      final response = await _supabase
          .from('watering_history')
          .select('*, plants(name)')
          .order('watered_at', ascending: false)
          .limit(10);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }
}
