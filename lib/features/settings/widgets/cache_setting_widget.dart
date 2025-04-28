import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sport_equipment_rent/data/models/cache_policy.dart';
import 'package:sport_equipment_rent/data/providers/cache_provider.dart';

class CacheSettingsWidget extends ConsumerWidget {
  const CacheSettingsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPolicy = ref.watch(cachePolicyProvider);

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.storage_rounded,
                  color: Theme.of(context).primaryColor,
                  size: 24.r,
                ),
                SizedBox(width: 12.w),
                Text(
                  'Управление кэшем',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            DropdownButtonFormField<CachePolicy>(
              value: currentPolicy,
              decoration: InputDecoration(
                labelText: 'Политика кэширования',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
              ),
              items: CachePolicy.values.map((policy) {
                return DropdownMenuItem(
                  value: policy,
                  child: Row(
                    children: [
                      Icon(
                        _getPolicyIcon(policy),
                        size: 20.r,
                        color: Theme.of(context).primaryColor,
                      ),
                      SizedBox(width: 8.w),
                      Text(_getPolicyName(policy)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (policy) {
                if (policy != null) {
                  ref.read(cachePolicyProvider.notifier).setPolicy(policy);
                }
              },
            ),
            SizedBox(height: 8.h),
            Text(
              _getPolicyDescription(currentPolicy),
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getPolicyIcon(CachePolicy policy) {
    switch (policy) {
      case CachePolicy.shortTerm:
        return Icons.speed;
      case CachePolicy.mediumTerm:
        return Icons.timer;
      case CachePolicy.longTerm:
        return Icons.archive;
    }
  }

  String _getPolicyName(CachePolicy policy) {
    switch (policy) {
      case CachePolicy.shortTerm:
        return 'Короткий срок (15 минут)';
      case CachePolicy.mediumTerm:
        return 'Средний срок (1 час)';
      case CachePolicy.longTerm:
        return 'Длительный срок (24 часа)';
    }
  }

  String _getPolicyDescription(CachePolicy policy) {
    switch (policy) {
      case CachePolicy.shortTerm:
        return 'Частое обновление данных, больше сетевых запросов';
      case CachePolicy.mediumTerm:
        return 'Оптимальный баланс между актуальностью и экономией трафика';
      case CachePolicy.longTerm:
        return 'Максимальная экономия трафика, данные могут быть неактуальными';
    }
  }
}