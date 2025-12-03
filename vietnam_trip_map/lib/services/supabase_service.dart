import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/pin.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Pin>> getPins() async {
    try {
      final response = await _client
          .from('pins')
          .select()
          .order('created_at', ascending: false);

      return (response as List).map((pin) => Pin.fromJson(pin)).toList();
    } catch (e) {
      print('Error fetching pins: $e');
      return [];
    }
  }

  Future<Pin?> addPin(Pin pin) async {
    try {
      final data = {
        'title': pin.title,
        'description': pin.description,
        'latitude': pin.latitude,
        'longitude': pin.longitude,
        'type': pin.type.value,
      };

      final response = await _client
          .from('pins')
          .insert(data)
          .select()
          .single();

      return Pin.fromJson(response);
    } catch (e) {
      print('Error adding pin: $e');
      return null;
    }
  }

  Future<bool> updatePin(Pin pin) async {
    try {
      await _client.from('pins').update({
        'title': pin.title,
        'description': pin.description,
        'latitude': pin.latitude,
        'longitude': pin.longitude,
        'type': pin.type.value,
      }).eq('id', pin.id!);

      return true;
    } catch (e) {
      print('Error updating pin: $e');
      return false;
    }
  }

  Future<bool> deletePin(String id) async {
    try {
      await _client.from('pins').delete().eq('id', id);
      return true;
    } catch (e) {
      print('Error deleting pin: $e');
      return false;
    }
  }
}
