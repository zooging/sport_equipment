import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sport_equipment_rent/core/widgets/buttons/custom_button.dart';
import 'package:sport_equipment_rent/data/providers/auth_provider.dart';
import 'package:sport_equipment_rent/features/auth/screens/sign_in_screen.dart';
import 'package:sport_equipment_rent/features/rental_history/screens/rental_history_screen.dart';
import 'package:sport_equipment_rent/features/profile/screens/settings_screen.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:sport_equipment_rent/features/profile/screens/payment_methods_screen.dart';
import 'package:sport_equipment_rent/features/profile/screens/documents_screen.dart';
import 'package:sport_equipment_rent/features/equipment/screens/reviews_screen.dart';


class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _updateProfilePhoto(BuildContext context, WidgetRef ref) async {
    try {
      final picker = ImagePicker();
      final imageFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (imageFile == null) return;

      if (!context.mounted) return;

      // Показываем индикатор загрузки
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      await ref.read(authServiceProvider).updateProfilePhoto(
        File(imageFile.path),
      );

      if (context.mounted) {
        // Закрываем индикатор загрузки
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Фото профиля обновлено')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Закрываем индикатор загрузки
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authServiceProvider).currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Column(
          children: [
            // Аватар и информация о пользователе
            Center(
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: () => _updateProfilePhoto(context, ref),
                    child: CircleAvatar(
                      radius: 50.r,
                      backgroundImage: user?.photoUrl != null
                          ? NetworkImage(user!.photoUrl!)
                          : null,
                      backgroundColor: Theme.of(context).primaryColor,
                      child: user?.photoUrl == null
                          ? Icon(
                        Icons.person,
                        size: 50.r,
                        color: Colors.white,
                      )
                          : null,
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: EdgeInsets.all(4.r),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        size: 20.r,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              user?.email ?? 'Пользователь',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 32.h),

            // Разделы профиля
            _buildProfileSection(
              context,
              icon: Icons.description,
              title: 'Документы',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DocumentsScreen(),
                  ),
                );
              },
            ),

            _buildProfileSection(
              context,
              icon: Icons.payment,
              title: 'Способы оплаты',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PaymentMethodsScreen(),
                  ),
                );
              },
            ),

            _buildProfileSection(
              context,
              icon: Icons.history,
              title: 'История аренды',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const RentalHistoryScreen(),
                  ),
                );
              },
            ),

            _buildProfileSection(
              context,
              icon: Icons.star,
              title: 'Мои отзывы',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyReviewsScreen(),
                  ),
                );
              },
            ),
            SizedBox(height: 32.h),

            // Кнопка выхода
            CustomButton(
              text: 'Выйти',
              onPressed: () async {
                await ref.read(authServiceProvider).signOut();
                if (context.mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const SignInScreen(),
                    ),
                  );
                }
              },
              backgroundColor: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(
      BuildContext context, {
        required IconData icon,
        required String title,
        required VoidCallback onTap,
      }) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      child: ListTile(
        leading: Icon(
          icon,
          color: Theme.of(context).primaryColor,
        ),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}