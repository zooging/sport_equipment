import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:sport_equipment_rent/data/models/equipment.dart';
import 'package:sport_equipment_rent/data/models/cache_policy.dart';

class CacheService {
  static const String _equipmentCacheKey = 'equipment_cache';
  static const String _lastUpdateKey = 'equipment_last_update';
  static const String _cachePolicyKey = 'cache_policy';

  Future<void> setCachePolicy(CachePolicy policy) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cachePolicyKey, policy.name);
  }

  Future<CachePolicy> getCachePolicy() async {
    final prefs = await SharedPreferences.getInstance();
    final policyName = prefs.getString(_cachePolicyKey);
    return policyName != null
        ? CachePolicy.values.firstWhere((e) => e.name == policyName)
        : CachePolicy.shortTerm;
  }

  Future<void> cacheEquipment(List<Equipment> equipment) async {
    final prefs = await SharedPreferences.getInstance();
    final equipmentJson = equipment
        .map((e) => json.encode(e.toJson()))
        .toList();

    await prefs.setStringList(_equipmentCacheKey, equipmentJson);
    await prefs.setInt(_lastUpdateKey, DateTime.now().millisecondsSinceEpoch);
  }

  Future<List<Equipment>?> getCachedEquipment() async {
    final prefs = await SharedPreferences.getInstance();
    final lastUpdate = prefs.getInt(_lastUpdateKey);

    if (lastUpdate == null) return null;

    final policy = await getCachePolicy();
    final lastUpdateTime = DateTime.fromMillisecondsSinceEpoch(lastUpdate);
    if (DateTime.now().difference(lastUpdateTime) > policy.validDuration) {
      return null;
    }

    final equipmentJson = prefs.getStringList(_equipmentCacheKey);
    if (equipmentJson == null) return null;

    try {
      return equipmentJson
          .map((e) => Equipment.fromJson(json.decode(e)))
          .toList();
    } catch (e) {
      print('Cache parsing error: $e');
      return null;
    }
  }

  Future<bool> isCacheValid() async {
    final prefs = await SharedPreferences.getInstance();
    final lastUpdate = prefs.getInt(_lastUpdateKey);

    if (lastUpdate == null) return false;

    final policy = await getCachePolicy();
    final lastUpdateTime = DateTime.fromMillisecondsSinceEpoch(lastUpdate);
    return DateTime.now().difference(lastUpdateTime) <= policy.validDuration;
  }

  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_equipmentCacheKey);
    await prefs.remove(_lastUpdateKey);
  }
}