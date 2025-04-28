class Review {
  final String id;
  final String userId;
  final String userName;
  final String equipmentId;
  final String equipmentName; // Добавляем новое поле
  final int rating;
  final String? comment;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.userId,
    required this.userName,
    required this.equipmentId,
    required this.equipmentName, // Добавляем в конструктор
    required this.rating,
    this.comment,
    required this.createdAt,
  });
}