import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PaymentMethodsScreen extends ConsumerStatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  ConsumerState<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends ConsumerState<PaymentMethodsScreen> {
  final List<PaymentMethod> _paymentMethods = [
    PaymentMethod(
      id: '1',
      type: 'card',
      title: '**** 4242',
      subtitle: 'VISA',
      isDefault: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Способы оплаты'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Сохраненные способы оплаты',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            if (_paymentMethods.isEmpty)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.credit_card_outlined,
                      size: 64.r,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16.h),
                    const Text('Нет сохраненных способов оплаты'),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _paymentMethods.length,
                itemBuilder: (context, index) {
                  final method = _paymentMethods[index];
                  return _PaymentMethodCard(
                    method: method,
                    onDelete: () => _deletePaymentMethod(method.id),
                    onSetDefault: () => _setDefaultPaymentMethod(method.id),
                  );
                },
              ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _addPaymentMethod,
                icon: const Icon(Icons.add),
                label: const Text('Добавить способ оплаты'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addPaymentMethod() {
    // Демонстрационное добавление карты
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Добавление карты'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Это демонстрационная версия.\nРеальная оплата не поддерживается.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 16.h),
            Icon(
              Icons.credit_card,
              size: 48.r,
              color: Theme.of(context).primaryColor,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  void _deletePaymentMethod(String id) {
    setState(() {
      _paymentMethods.removeWhere((method) => method.id == id);
    });
  }

  void _setDefaultPaymentMethod(String id) {
    setState(() {
      for (var method in _paymentMethods) {
        method.isDefault = method.id == id;
      }
    });
  }
}

class _PaymentMethodCard extends StatelessWidget {
  final PaymentMethod method;
  final VoidCallback onDelete;
  final VoidCallback onSetDefault;

  const _PaymentMethodCard({
    required this.method,
    required this.onDelete,
    required this.onSetDefault,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 8.h),
      child: ListTile(
        leading: Icon(
          method.type == 'card' ? Icons.credit_card : Icons.payment,
          color: Theme.of(context).primaryColor,
        ),
        title: Text(method.title),
        subtitle: Text(method.subtitle),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (method.isDefault)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 8.w,
                  vertical: 4.h,
                ),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  'Основной',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.green[700],
                  ),
                ),
              )
            else
              IconButton(
                icon: const Icon(Icons.check_circle_outline),
                onPressed: onSetDefault,
                tooltip: 'Сделать основным',
              ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: onDelete,
              tooltip: 'Удалить',
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentMethod {
  final String id;
  final String type;
  final String title;
  final String subtitle;
  bool isDefault;

  PaymentMethod({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    this.isDefault = false,
  });
}