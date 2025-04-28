import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sport_equipment_rent/data/models/rental_booking.dart';
import 'package:sport_equipment_rent/data/models/rental_history_item.dart';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> isEquipmentAvailable(
      String equipmentId,
      DateTime startDate,
      DateTime endDate,
      ) async {
    try {
      print('Checking availability for equipment: $equipmentId');
      print('From: $startDate to $endDate');

      final bookings = await _firestore
          .collection('bookings')
          .where('equipmentId', isEqualTo: equipmentId)
          .where('status', whereIn: ['pending', 'confirmed'])
          .get();

      print('Found ${bookings.docs.length} existing bookings');

      for (var booking in bookings.docs) {
        final bookingStartDate = (booking.data()['startDate'] as Timestamp).toDate();
        final bookingEndDate = (booking.data()['endDate'] as Timestamp).toDate();

        print('Comparing with booking:');
        print('${booking.id} - ${bookingStartDate} to ${bookingEndDate}');

        // Проверяем пересечение периодов
        if (startDate.isBefore(bookingEndDate) && endDate.isAfter(bookingStartDate)) {
          print('Date conflict found with booking ${booking.id}');
          return false;
        }
      }

      print('No conflicts found, equipment is available');
      return true;
    } catch (e) {
      print('Error checking availability: $e');
      throw Exception('Не удалось проверить доступность оборудования: $e');
    }
  }

  Future<String> createBooking({
    required String equipmentId,
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
    required double totalPrice,
  }) async {
    try {
      // Проверяем ID оборудования
      if (equipmentId.isEmpty) {
        throw Exception('ID оборудования не может быть пустым');
      }

      print('Creating booking for equipment: $equipmentId by user: $userId');

      // Получаем документ оборудования
      final equipmentDoc = await _firestore
          .collection('equipment')
          .doc(equipmentId)
          .get();

      if (!equipmentDoc.exists || equipmentDoc.data() == null) {
        throw Exception('Оборудование не найдено');
      }

      final equipmentData = equipmentDoc.data()!;
      final ownerId = equipmentData['ownerId'] as String?;

      if (ownerId == null || ownerId.isEmpty) {
        throw Exception('Владелец оборудования не определен');
      }

      if (ownerId == userId) {
        throw Exception('Вы не можете забронировать собственное оборудование');
      }

      print('Equipment owner ID: $ownerId');

      // Проверяем доступность
      final isAvailable = await isEquipmentAvailable(
        equipmentId,
        startDate,
        endDate,
      );

      if (!isAvailable) {
        throw Exception('Оборудование уже забронировано на выбранные даты');
      }

      // Создаем бронирование
      final bookingRef = _firestore.collection('bookings').doc();

      final booking = {
        'equipmentId': equipmentId,
        'userId': userId,
        'ownerId': ownerId,
        'startDate': Timestamp.fromDate(startDate),
        'endDate': Timestamp.fromDate(endDate),
        'totalPrice': totalPrice,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'ownerComment': null,
      };

      // Выполняем транзакцию
      await _firestore.runTransaction((transaction) async {
        // Проверяем статус оборудования еще раз перед бронированием
        final freshEquipDoc = await transaction.get(equipmentDoc.reference);
        if (freshEquipDoc.data()?['status'] != 'available') {
          throw Exception('Оборудование больше не доступно');
        }

        transaction.set(bookingRef, booking);
        transaction.update(
          equipmentDoc.reference,
          {'status': 'booked'},
        );
      });

      print('Successfully created booking: ${bookingRef.id}');
      return bookingRef.id;

    } catch (e, stackTrace) {
      print('Error creating booking: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Не удалось создать бронирование: $e');
    }
  }

  Future<List<DateTime>> getBookedDates(String equipmentId) async {
    try {
      print('Getting booked dates for equipment: $equipmentId');
      final bookings = await _firestore
          .collection('bookings')
          .where('equipmentId', isEqualTo: equipmentId)
          .where('status', whereIn: ['pending', 'confirmed'])
          .get();

      print('Found ${bookings.docs.length} bookings');
      List<DateTime> bookedDates = [];

      for (var booking in bookings.docs) {
        final startDate = (booking.data()['startDate'] as Timestamp).toDate();
        final endDate = (booking.data()['endDate'] as Timestamp).toDate();

        print('Processing booking ${booking.id}: $startDate to $endDate');

        // Добавляем все даты в период бронирования
        for (var date = startDate;
        date.isBefore(endDate);
        date = date.add(const Duration(hours: 1))) {
          bookedDates.add(date);
        }
      }

      print('Total booked dates: ${bookedDates.length}');
      return bookedDates;
    } catch (e) {
      print('Error getting booked dates: $e');
      throw Exception('Не удалось получить список занятых дат: $e');
    }
  }

  Stream<RentalBooking?> getBookingStream(String bookingId) {
    print('Setting up stream for booking: $bookingId');
    return _firestore
        .collection('bookings')
        .doc(bookingId)
        .snapshots()
        .handleError((error) {
      print('Error in booking stream: $error');
      return null;
    })
        .map((doc) {
      if (!doc.exists || doc.data() == null) {
        print('Booking not found or data is null for ID: $bookingId');
        return null;
      }

      try {
        final data = doc.data()!;
        print('Received booking data: ${doc.id}');
        return RentalBooking(
          id: doc.id,
          equipmentId: data['equipmentId'] as String,
          userId: data['userId'] as String,
          ownerId: data['ownerId'] as String,
          startDate: (data['startDate'] as Timestamp).toDate(),
          endDate: (data['endDate'] as Timestamp).toDate(),
          totalPrice: (data['totalPrice'] as num).toDouble(),
          status: data['status'] as String,
          createdAt: (data['createdAt'] as Timestamp).toDate(),
          ownerComment: data['ownerComment'] as String?,
        );
      } catch (e) {
        print('Error parsing booking data: $e');
        return null;
      }
    });
  }

  Stream<List<RentalBooking>> getOwnerBookings(String ownerId) {
    print('Setting up stream for owner bookings: $ownerId');
    return _firestore
        .collection('bookings')
        .where('ownerId', isEqualTo: ownerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .handleError((error) {
      print('Error in owner bookings stream: $error');
      return [];
    })
        .map((snapshot) {
      print('Received ${snapshot.docs.length} owner bookings');
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return RentalBooking(
          id: doc.id,
          equipmentId: data['equipmentId'],
          userId: data['userId'],
          ownerId: data['ownerId'],
          startDate: (data['startDate'] as Timestamp).toDate(),
          endDate: (data['endDate'] as Timestamp).toDate(),
          totalPrice: data['totalPrice'],
          status: data['status'],
          createdAt: (data['createdAt'] as Timestamp).toDate(),
          ownerComment: data['ownerComment'],
        );
      }).toList();
    });
  }

  Stream<List<RentalBooking>> getOwnerPendingBookings(String ownerId) {
    return _firestore
        .collection('bookings')
        .where('ownerId', isEqualTo: ownerId)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => RentalBooking.fromMap({...doc.data(), 'id': doc.id}))
        .toList());
  }


  Future<void> updateBookingStatus(
      String bookingId,
      String status, {
        String? comment,
      }) async {
    try {
      print('Updating booking status: $bookingId to $status');
      final updateData = {
        'status': status,
        if (comment != null) 'ownerComment': comment,
      };

      await _firestore.collection('bookings').doc(bookingId).update(updateData);
      print('Successfully updated booking $bookingId');
    } catch (e) {
      print('Error updating booking status: $e');
      throw Exception('Не удалось обновить статус бронирования: $e');
    }
  }

  Stream<List<RentalBooking>> getUserBookings(String userId) {
    print('Setting up stream for user bookings: $userId');
    return _firestore
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .handleError((error) {
      print('Error in user bookings stream: $error');
      return [];
    })
        .map((snapshot) {
      print('Received ${snapshot.docs.length} user bookings');
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return RentalBooking(
          id: doc.id,
          equipmentId: data['equipmentId'],
          userId: data['userId'],
          ownerId: data['ownerId'],
          startDate: (data['startDate'] as Timestamp).toDate(),
          endDate: (data['endDate'] as Timestamp).toDate(),
          totalPrice: data['totalPrice'],
          status: data['status'],
          createdAt: (data['createdAt'] as Timestamp).toDate(),
          ownerComment: data['ownerComment'],
        );
      }).toList();
    });
  }

  Stream<List<RentalHistoryItem>> getUserRentalHistory(String userId) {
    return _firestore
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .asyncMap((snapshot) async {
      List<RentalHistoryItem> items = [];

      for (var doc in snapshot.docs) {
        try {
          final data = doc.data();
          final equipmentId = data['equipmentId'] as String;

          // Получаем информацию об оборудовании
          final equipmentDoc = await _firestore
              .collection('equipment')
              .doc(equipmentId)
              .get();

          if (equipmentDoc.exists) {
            final equipment = equipmentDoc.data()!;

            // Преобразование статуса
            String bookingStatus = data['status'] as String? ?? 'pending';
            String mappedStatus = _mapBookingStatus(bookingStatus);

            items.add(RentalHistoryItem(
              id: doc.id,
              equipmentName: equipment['title'] as String,
              startDate: (data['startDate'] as Timestamp).toDate(),
              endDate: (data['endDate'] as Timestamp).toDate(),
              totalPrice: (data['totalPrice'] as num).toDouble(),
              status: mappedStatus,
            ));
          }
        } catch (e, stack) {
          print('Error processing booking document: $e');
          print('Stack trace: $stack');
        }
      }

      return items;
    });
  }

  String _mapBookingStatus(String bookingStatus) {
    switch (bookingStatus) {
      case 'confirmed':
        return 'confirmed';
      case 'completed':
        return 'completed';
      case 'rejected':
        return 'rejected';
      case 'pending':
        return 'confirmed'; // Pending заказы тоже показываем как активные
      default:
        return 'confirmed';
    }
  }

  Stream<List<RentalBooking>> getPendingBookingsForEquipment(String equipmentId) {
    return _firestore
        .collection('bookings')
        .where('equipmentId', isEqualTo: equipmentId)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => RentalBooking.fromJson({...doc.data(), 'id': doc.id}))
        .toList());
  }

  Future<void> extendBooking(String bookingId, DateTime newEndDate) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).update({
        'endDate': Timestamp.fromDate(newEndDate),
        'lastUpdated': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      print('Error extending booking: $e');
      throw Exception('Не удалось продлить аренду');
    }
  }

  Future<void> completeBooking(String bookingId) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).update({
        'status': 'completed',
        'completedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      print('Error completing booking: $e');
      throw Exception('Не удалось завершить аренду');
    }
  }

  Future<void> cancelBooking(
      String bookingId, {
        required String reason,
        required double cancellationFee,
      }) async {
    try {
      print('Cancelling booking: $bookingId');
      print('Reason: $reason');
      print('Fee: $cancellationFee');

      await _firestore.collection('bookings').doc(bookingId).update({
        'status': 'rejected',
        'cancelledAt': FieldValue.serverTimestamp(),
        'cancellationReason': reason,
        'cancellationFee': cancellationFee,
      });

      print('Booking cancelled successfully');
    } catch (e) {
      print('Error cancelling booking: $e');
      throw Exception('Не удалось отменить аренду: $e');
    }
  }

  Future<double> calculateCancellationFee(String bookingId) async {
    try {
      final doc = await _firestore.collection('bookings').doc(bookingId).get();
      if (!doc.exists) throw Exception('Бронирование не найдено');

      final data = doc.data()!;
      final startDate = (data['startDate'] as Timestamp).toDate();
      final totalPrice = (data['totalPrice'] as num).toDouble();

      // Вывод данных для отладки
      print('Calculating cancellation fee:');
      print('Start date: $startDate');
      print('Total price: $totalPrice');
      print('Current time: ${DateTime.now()}');

      // Расчет штрафа в зависимости от времени до начала аренды
      final daysUntilStart = startDate.difference(DateTime.now()).inDays;
      print('Days until start: $daysUntilStart');

      double feePercentage;
      if (daysUntilStart > 7) {
        feePercentage = 0.0; // Нет штрафа при отмене за неделю
      } else if (daysUntilStart > 3) {
        feePercentage = 0.1; // 10% штраф
      } else if (daysUntilStart > 1) {
        feePercentage = 0.3; // 30% штраф
      } else {
        feePercentage = 0.5; // 50% штраф
      }

      final fee = totalPrice * feePercentage;
      print('Calculated fee: $fee (${feePercentage * 100}%)');

      return fee;
    } catch (e, stack) {
      print('Error calculating cancellation fee: $e');
      print('Stack trace: $stack');
      return 0.0; // Возвращаем 0 в случае ошибки
    }
  }

}