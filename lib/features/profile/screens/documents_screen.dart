import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DocumentsScreen extends ConsumerStatefulWidget {
  const DocumentsScreen({super.key});

  @override
  ConsumerState<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends ConsumerState<DocumentsScreen> {
  final List<UserDocument> _documents = [
    UserDocument(
      id: '1',
      type: 'passport',
      title: 'Паспорт',
      status: DocumentStatus.verified,
      uploadDate: DateTime.now().subtract(const Duration(days: 30)),
    ),
    UserDocument(
      id: '2',
      type: 'driver_license',
      title: 'Водительское удостоверение',
      status: DocumentStatus.pending,
      uploadDate: DateTime.now(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Документы'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Мои документы',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Для аренды некоторых видов оборудования требуется верификация документов',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 24.h),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _documents.length,
              itemBuilder: (context, index) {
                final document = _documents[index];
                return _DocumentCard(
                  document: document,
                  onReupload: () => _reuploadDocument(document),
                  onDelete: () => _deleteDocument(document.id),
                );
              },
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _addNewDocument,
                icon: const Icon(Icons.add),
                label: const Text('Добавить документ'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addNewDocument() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выберите тип документа'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.credit_card),
              title: const Text('Паспорт'),
              onTap: () {
                Navigator.pop(context);
                _showUploadDemo('passport');
              },
            ),
            ListTile(
              leading: const Icon(Icons.drive_eta),
              title: const Text('Водительское удостоверение'),
              onTap: () {
                Navigator.pop(context);
                _showUploadDemo('driver_license');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showUploadDemo(String type) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Загрузка документа'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.file_upload,
              size: 48.r,
              color: Theme.of(context).primaryColor,
            ),
            SizedBox(height: 16.h),
            const Text(
              'Это демонстрационная версия.\nЗагрузка документов временно недоступна.',
              textAlign: TextAlign.center,
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

  void _reuploadDocument(UserDocument document) {
    _showUploadDemo(document.type);
  }

  void _deleteDocument(String id) {
    setState(() {
      _documents.removeWhere((doc) => doc.id == id);
    });
  }
}

class _DocumentCard extends StatelessWidget {
  final UserDocument document;
  final VoidCallback onReupload;
  final VoidCallback onDelete;

  const _DocumentCard({
    required this.document,
    required this.onReupload,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  document.type == 'passport'
                      ? Icons.credit_card
                      : Icons.drive_eta,
                  color: Theme.of(context).primaryColor,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        document.title,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Загружен ${_formatDate(document.uploadDate)}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onReupload,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Обновить'),
                ),
                SizedBox(width: 8.w),
                TextButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Удалить'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color color;
    String text;

    switch (document.status) {
      case DocumentStatus.verified:
        color = Colors.green;
        text = 'Подтвержден';
        break;
      case DocumentStatus.pending:
        color = Colors.orange;
        text = 'На проверке';
        break;
      case DocumentStatus.rejected:
        color = Colors.red;
        text = 'Отклонен';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 8.w,
        vertical: 4.h,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.sp,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }
}

enum DocumentStatus {
  verified,
  pending,
  rejected,
}

class UserDocument {
  final String id;
  final String type;
  final String title;
  final DocumentStatus status;
  final DateTime uploadDate;

  UserDocument({
    required this.id,
    required this.type,
    required this.title,
    required this.status,
    required this.uploadDate,
  });
}