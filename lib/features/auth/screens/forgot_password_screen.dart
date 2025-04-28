import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sport_equipment_rent/core/widgets/buttons/custom_button.dart';
import 'package:sport_equipment_rent/core/widgets/inputs/custom_text_field.dart';
import 'package:sport_equipment_rent/data/providers/auth_provider.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authService = ref.read(authServiceProvider);
      await authService.resetPassword(_emailController.text.trim());

      if (mounted) {
        setState(() => _emailSent = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Инструкции по сбросу пароля отправлены на ваш email'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Восстановление пароля'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 40.h),

              // Иконка
              Icon(
                Icons.lock_reset,
                size: 80.r,
                color: Theme.of(context).primaryColor,
              ),
              SizedBox(height: 24.h),

              // Заголовок и описание
              Text(
                'Забыли пароль?',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),

              Text(
                'Введите ваш email и мы отправим инструкции по восстановлению пароля',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32.h),

              if (!_emailSent) ...[
                // Email поле
                CustomTextField(
                  label: 'Email',
                  controller: _emailController,
                  hint: 'Введите ваш email',
                  keyboardType: TextInputType.emailAddress,
                  prefix: const Icon(Icons.email),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Пожалуйста, введите email';
                    }
                    if (!value.contains('@')) {
                      return 'Введите корректный email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24.h),

                // Кнопка отправки
                CustomButton(
                  text: 'Отправить инструкции',
                  onPressed: _resetPassword,
                  isLoading: _isLoading,
                ),
              ] else ...[
                // Сообщение об успешной отправке
                Container(
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 48.r,
                      ),
                      SizedBox(height: 16.h),
                      const Text(
                        'Инструкции отправлены!',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      const Text(
                        'Проверьте ваш email и следуйте инструкциям для восстановления пароля',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],

              SizedBox(height: 16.h),

              // Кнопка возврата
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Вернуться к входу',
                  style: TextStyle(fontSize: 14.sp),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}