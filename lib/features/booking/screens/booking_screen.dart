import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sport_equipment_rent/data/models/equipment.dart';
import 'package:sport_equipment_rent/core/widgets/buttons/custom_button.dart';
import 'package:intl/intl.dart';
import 'package:sport_equipment_rent/data/models/rental_booking.dart';
import 'package:sport_equipment_rent/features/equipment/screens/equipment_detail_screen.dart';
import 'package:sport_equipment_rent/data/providers/booking_provider.dart';
import 'package:sport_equipment_rent/features/booking/widgets/booking_confirmation_dialog.dart';
import 'package:sport_equipment_rent/data/providers/auth_provider.dart';
import 'package:sport_equipment_rent/features/booking/screens/booking_status_screen.dart'; // Add this import

class BookingScreen extends ConsumerStatefulWidget {
  final Equipment equipment;

  const BookingScreen({
    super.key,
    required this.equipment,
  });

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  int _hours = 1;
  double _totalPrice = 0;
  bool _isCheckingAvailability = false;
  bool _isLoading = false;
  List<DateTime> _bookedDates = [];

  @override
  void initState() {
    super.initState();
    _loadBookedDates();
    _calculateTotal();
  }

  void _calculateTotal() {
    _totalPrice = widget.equipment.pricePerHour * _hours;
  }

  Future<void> _loadBookedDates() async {
    final bookingService = ref.read(bookingServiceProvider);
    final dates = await bookingService.getBookedDates(widget.equipment.id);
    setState(() {
      _bookedDates = dates;
    });
  }

  Future<void> _selectDateTime(bool isStartDate) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      selectableDayPredicate: (DateTime day) {
        return !_bookedDates.any((bookedDate) =>
        day.year == bookedDate.year &&
            day.month == bookedDate.month &&
            day.day == bookedDate.day);
      },
    );

    if (date != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (date != null && time != null) {
        final selectedDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );

        setState(() => _isCheckingAvailability = true);

        final bookingService = ref.read(bookingServiceProvider);
        final isAvailable = await bookingService.isEquipmentAvailable(
          widget.equipment.id,
          selectedDateTime,
          selectedDateTime.add(Duration(hours: _hours)),
        );
        setState(() => _isCheckingAvailability = false);

        if (!isAvailable) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Выбранное время уже занято'),
              ),
            );
          }
          return;
        }

        setState(() {
          if (isStartDate) {
            _startDate = selectedDateTime;
            if (_endDate != null && _endDate!.isBefore(_startDate!)) {
              _endDate = null;
            }
          } else {
            _endDate = selectedDateTime;
          }

          if (_startDate != null && _endDate != null) {
            _hours = _endDate!.difference(_startDate!).inHours;
            if (_hours < 1) _hours = 1;
            _calculateTotal();
          }
        });
      }
    }
  }

  Future<void> _confirmBooking() async {
    final shouldProceed = await showDialog<bool>(
      context: context,
      builder: (context) => BookingConfirmationDialog(
        equipment: widget.equipment,
        startDate: _startDate!,
        endDate: _endDate!,
        hours: _hours,
        totalPrice: _totalPrice,
      ),
    );

    if (shouldProceed == true && mounted) {
      setState(() => _isLoading = true);

      try {
        final user = ref.read(authServiceProvider).currentUser;
        if (user == null) throw Exception('Пользователь не авторизован');

        final bookingService = ref.read(bookingServiceProvider);
        final bookingId = await bookingService.createBooking(
          equipmentId: widget.equipment.id,
          userId: user.uid,
          startDate: _startDate!,
          endDate: _endDate!,
          totalPrice: _totalPrice,
        );

        if (bookingId.isEmpty) {
          throw Exception('Не получен ID бронирования');
        }

        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => BookingStatusScreen(
                bookingId: bookingId,
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ошибка бронирования: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  void _handleBooking() {
    if (_startDate != null && _endDate != null && !_isLoading) {
      _confirmBooking();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Бронирование'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.r),
                    child: Row(
                      children: [
                        Container(
                          width: 80.w,
                          height: 80.w,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(
                            Icons.sports,
                            size: 40.r,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.equipment.title,
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                '${widget.equipment.pricePerHour} ₽/час',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  'Выберите время аренды',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _selectDateTime(true),
                        child: Container(
                          padding: EdgeInsets.all(12.r),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Начало',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                _startDate != null
                                    ? DateFormat('dd.MM.yyyy HH:mm')
                                    .format(_startDate!)
                                    : 'Выберите дату',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (_startDate != null) {
                            _selectDateTime(false);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Сначала выберите время начала'),
                              ),
                            );
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.all(12.r),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Конец',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                _endDate != null
                                    ? DateFormat('dd.MM.yyyy HH:mm')
                                    .format(_endDate!)
                                    : 'Выберите дату',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
                Container(
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Длительность:',
                            style: TextStyle(fontSize: 16.sp),
                          ),
                          Text(
                            '$_hours ч',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Стоимость аренды:',
                            style: TextStyle(fontSize: 16.sp),
                          ),
                          Text(
                            '$_totalPrice ₽',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Депозит:',
                            style: TextStyle(fontSize: 16.sp),
                          ),
                          Text(
                            '${widget.equipment.depositAmount} ₽',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_isCheckingAvailability)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: CustomButton(
          text: 'Забронировать',
          onPressed: _handleBooking,
          isLoading: _isLoading,
        ),
      ),
    );
  }
}