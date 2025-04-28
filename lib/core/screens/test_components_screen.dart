import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sport_equipment_rent/core/widgets/buttons/custom_button.dart';
import 'package:sport_equipment_rent/core/widgets/cards/equipment_card.dart';
import 'package:sport_equipment_rent/core/widgets/inputs/custom_text_field.dart';
import 'package:sport_equipment_rent/core/widgets/loading/loading_overlay.dart';

class TestComponentsScreen extends StatefulWidget {
  const TestComponentsScreen({super.key});

  @override
  State<TestComponentsScreen> createState() => _TestComponentsScreenState();
}

class _TestComponentsScreenState extends State<TestComponentsScreen> {
  final TextEditingController _textController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _toggleLoading() {
    setState(() {
      _isLoading = !_isLoading;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UI Components Test'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Custom Button Test
                Text(
                  'Custom Button:',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                CustomButton(
                  text: 'Test Button',
                  onPressed: _toggleLoading,
                  isLoading: _isLoading,
                ),
                SizedBox(height: 24.h),

                // Custom TextField Test
                Text(
                  'Custom TextField:',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                CustomTextField(
                  label: 'Test Input',
                  hint: 'Enter some text',
                  controller: _textController,
                  prefix: const Icon(Icons.search),
                ),
                SizedBox(height: 24.h),

                // Equipment Card Test
                Text(
                  'Equipment Card:',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                EquipmentCard(
                  title: 'Горный велосипед',
                  address: 'ул. Спортивная, 15',
                  distance: 2.5,
                  price: 500,
                  isAvailable: true,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Card tapped!')),
                    );
                  },
                  imageUrl: 'https://example.com/bike.jpg',
                ),
              ],
            ),
          ),
          // Loading Overlay Test
          if (_isLoading) const LoadingOverlay(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleLoading,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}