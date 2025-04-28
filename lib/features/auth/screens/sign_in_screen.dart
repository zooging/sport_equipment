import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sport_equipment_rent/core/widgets/buttons/custom_button.dart';
import 'package:sport_equipment_rent/core/widgets/inputs/custom_text_field.dart';
import 'package:sport_equipment_rent/data/providers/auth_provider.dart';
import 'package:sport_equipment_rent/data/models/user_model.dart';
import 'package:sport_equipment_rent/data/models/user_role.dart';
import 'package:sport_equipment_rent/features/auth/screens/sign_up_screen.dart';
import 'package:sport_equipment_rent/features/auth/screens/forgot_password_screen.dart';
import 'package:sport_equipment_rent/features/home/screens/home_screen.dart';
import 'package:sport_equipment_rent/features/home/screens/owner_home_screen.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authService = ref.read(authServiceProvider);
      final user = await authService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => user.role == UserRole.owner
                ? const OwnerHomeScreen()
                : const HomeScreen(),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getErrorMessage(e.toString())),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getErrorMessage(String error) {
    if (error.contains('user-not-found')) {
      return 'Пользователь с таким email не найден';
    } else if (error.contains('wrong-password')) {
      return 'Неверный пароль';
    } else if (error.contains('invalid-email')) {
      return 'Некорректный email';
    } else if (error.contains('user-disabled')) {
      return 'Этот аккаунт был отключен';
    } else if (error.contains('too-many-requests')) {
      return 'Слишком много попыток входа. Попробуйте позже';
    }
    return 'Ошибка входа: $error';
  }

  void _navigateToSignUp() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const SignUpScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.r),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 60.h),

                // Логотип
                Icon(
                  Icons.sports_outlined,
                  size: 100.r,
                  color: Theme.of(context).primaryColor,
                ),
                SizedBox(height: 16.h),

                // Заголовок
                Text(
                  'Добро пожаловать',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.h),

                Text(
                  'Войдите, чтобы продолжить',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 40.h),

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
                SizedBox(height: 16.h),

                // Пароль поле
                CustomTextField(
                  label: 'Пароль',
                  controller: _passwordController,
                  hint: 'Введите пароль',
                  obscureText: _obscurePassword,
                  prefix: const Icon(Icons.lock),
                  suffix: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Пожалуйста, введите пароль';
                    }
                    if (value.length < 6) {
                      return 'Пароль должен содержать минимум 6 символов';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 8.h),

                // Ссылка "Забыли пароль?"
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ForgotPasswordScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Забыли пароль?',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),

                // Кнопка входа
                CustomButton(
                  text: 'Войти',
                  onPressed: _signIn,
                  isLoading: _isLoading,
                ),
                SizedBox(height: 16.h),

                // Ссылка на регистрацию
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Нет аккаунта? ',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    TextButton(
                      onPressed: _navigateToSignUp,
                      child: Text(
                        'Зарегистрируйтесь',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}