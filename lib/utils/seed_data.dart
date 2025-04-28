import 'package:cloud_firestore/cloud_firestore.dart';

class SeedData {
  static Future<void> addTestEquipment() async {
    final equipment = [
      {
        'title': 'Велосипед горный',
        'description': 'Горный велосипед для активного отдыха. Идеально подходит для загородных поездок.',
        'category': 'Велосипеды',
        'pricePerHour': 300.0,
        'depositAmount': 3000.0,
        'status': 'available',
        'images': [
          'https://example.com/bike1.jpg',
        ],
        'rating': 4.5,
        'reviewsCount': 12,
        'locationData': {
          'latitude': 55.7558,
          'longitude': 37.6173,
          'address': 'ул. Пушкина, д. 10',
        },
      },
      {
        'title': 'Лыжный комплект',
        'description': 'Полный комплект для катания на горных лыжах, включая ботинки.',
        'category': 'Зимний спорт',
        'pricePerHour': 500.0,
        'depositAmount': 5000.0,
        'status': 'available',
        'images': [
          'https://example.com/ski1.jpg',
        ],
        'rating': 4.8,
        'reviewsCount': 8,
        'locationData': {
          'latitude': 55.7512,
          'longitude': 37.6184,
          'address': 'ул. Лермонтова, д. 15',
        },
      },
      {
        'title': 'Каяк для двоих',
        'description': 'Прочный каяк для спокойных водоемов. Вмещает 2 человек.',
        'category': 'Водный спорт',
        'pricePerHour': 700.0,
        'depositAmount': 10000.0,
        'status': 'available',
        'images': [
          'https://example.com/kayak1.jpg',
        ],
        'rating': 4.9,
        'reviewsCount': 15,
        'locationData': {
          'latitude': 55.7530,
          'longitude': 37.6200,
          'address': 'наб. реки Москвы, д. 5',
        },
      },
      {
        'title': 'Роликовые коньки',
        'description': 'Размер 40-42. Отличное состояние, подходят для начинающих.',
        'category': 'Летний спорт',
        'pricePerHour': 200.0,
        'depositAmount': 2000.0,
        'status': 'available',
        'images': [
          'https://example.com/rollers1.jpg',
        ],
        'rating': 4.2,
        'reviewsCount': 6,
        'locationData': {
          'latitude': 55.7545,
          'longitude': 37.6150,
          'address': 'ул. Гагарина, д. 20',
        },
      },
      {
        'title': 'Палатка 4-местная',
        'description': 'Водонепроницаемая палатка для кемпинга. В комплекте спальные мешки.',
        'category': 'Туризм',
        'pricePerHour': 400.0,
        'depositAmount': 6000.0,
        'status': 'available',
        'images': [
          'https://example.com/tent1.jpg',
        ],
        'rating': 4.7,
        'reviewsCount': 10,
        'locationData': {
          'latitude': 55.7500,
          'longitude': 37.6220,
          'address': 'пр. Мира, д. 30',
        },
      },
      {
        'title': 'Электросамокат',
        'description': 'Мощность 350W, запас хода 25 км. Макс. скорость 25 км/ч.',
        'category': 'Электротранспорт',
        'pricePerHour': 450.0,
        'depositAmount': 15000.0,
        'status': 'available',
        'images': [
          'https://example.com/scooter1.jpg',
        ],
        'rating': 4.6,
        'reviewsCount': 18,
        'locationData': {
          'latitude': 55.7570,
          'longitude': 37.6190,
          'address': 'ул. Тверская, д. 12',
        },
      },
      {
        'title': 'Скейтборд',
        'description': 'Профессиональный скейтборд для трюков. Подшипники ABEC-7.',
        'category': 'Экстрим',
        'pricePerHour': 250.0,
        'depositAmount': 3500.0,
        'status': 'available',
        'images': [
          'https://example.com/skateboard1.jpg',
        ],
        'rating': 4.4,
        'reviewsCount': 7,
        'locationData': {
          'latitude': 55.7580,
          'longitude': 37.6140,
          'address': 'ул. Маяковского, д. 8',
        },
      },
      {
        'title': 'Гантели наборные',
        'description': 'Набор гантелей от 2 до 10 кг. Подходит для домашних тренировок.',
        'category': 'Фитнес',
        'pricePerHour': 150.0,
        'depositAmount': 2500.0,
        'status': 'available',
        'images': [
          'https://example.com/dumbbells1.jpg',
        ],
        'rating': 4.3,
        'reviewsCount': 5,
        'locationData': {
          'latitude': 55.7520,
          'longitude': 37.6160,
          'address': 'ул. Спортивная, д. 3',
        },
      },
      {
        'title': 'Сноуборд Burton',
        'description': 'Профессиональный сноуборд с креплениями. Размер 160 см.',
        'category': 'Зимний спорт',
        'pricePerHour': 600.0,
        'depositAmount': 12000.0,
        'status': 'available',
        'images': [
          'https://example.com/snowboard1.jpg',
        ],
        'rating': 4.9,
        'reviewsCount': 14,
        'locationData': {
          'latitude': 55.7590,
          'longitude': 37.6210,
          'address': 'ул. Горнолыжная, д. 7',
        },
      },
      {
        'title': 'Теннисные ракетки',
        'description': '2 ракетки Wilson + мячи. Отличный набор для любителей.',
        'category': 'Теннис',
        'pricePerHour': 350.0,
        'depositAmount': 4000.0,
        'status': 'available',
        'images': [
          'https://example.com/tennis1.jpg',
        ],
        'rating': 4.5,
        'reviewsCount': 9,
        'locationData': {
          'latitude': 55.7560,
          'longitude': 37.6230,
          'address': 'ул. Тенисная, д. 4',
        },
      },
      {
        'title': 'Гироскутер',
        'description': 'Smart Balance 10.5". Макс. скорость 15 км/ч.',
        'category': 'Электротранспорт',
        'pricePerHour': 400.0,
        'depositAmount': 8000.0,
        'status': 'available',
        'images': [
          'https://example.com/gyro1.jpg',
        ],
        'rating': 4.1,
        'reviewsCount': 11,
        'locationData': {
          'latitude': 55.7535,
          'longitude': 37.6175,
          'address': 'ул. Современная, д. 11',
        },
      },
      {
        'title': 'Бадминтонный набор',
        'description': '2 ракетки + воланчики. Легкий и удобный комплект.',
        'category': 'Бадминтон',
        'pricePerHour': 180.0,
        'depositAmount': 1500.0,
        'status': 'available',
        'images': [
          'https://example.com/badminton1.jpg',
        ],
        'rating': 4.0,
        'reviewsCount': 4,
        'locationData': {
          'latitude': 55.7540,
          'longitude': 37.6195,
          'address': 'ул. Парковая, д. 9',
        },
      },
    ];

    final firestore = FirebaseFirestore.instance;
    final batch = firestore.batch();

    for (var item in equipment) {
      final doc = firestore.collection('equipment').doc();
      batch.set(doc, item);
    }

    await batch.commit();
  }
}