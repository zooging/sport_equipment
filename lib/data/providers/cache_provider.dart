import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_equipment_rent/data/models/cache_policy.dart';
import 'package:sport_equipment_rent/data/services/cache_service.dart';

final cacheServiceProvider = Provider<CacheService>((ref) => CacheService());

final cachePolicyProvider = StateNotifierProvider<CachePolicyNotifier, CachePolicy>(
      (ref) => CachePolicyNotifier(ref.read(cacheServiceProvider)),
);

class CachePolicyNotifier extends StateNotifier<CachePolicy> {
  final CacheService _cacheService;

  CachePolicyNotifier(this._cacheService) : super(CachePolicy.shortTerm) {
    _initPolicy();
  }

  Future<void> _initPolicy() async {
    state = await _cacheService.getCachePolicy();
  }

  Future<void> setPolicy(CachePolicy policy) async {
    await _cacheService.setCachePolicy(policy);
    state = policy;
  }
}