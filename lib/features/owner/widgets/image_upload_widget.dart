import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sport_equipment_rent/data/providers/storage_provider.dart';

class ImageUploadWidget extends ConsumerStatefulWidget {
  final List<String> initialImages;
  final Function(List<String>) onImagesChanged;

  const ImageUploadWidget({
    super.key,
    required this.initialImages,
    required this.onImagesChanged,
  });

  @override
  ConsumerState<ImageUploadWidget> createState() => _ImageUploadWidgetState();
}

class _ImageUploadWidgetState extends ConsumerState<ImageUploadWidget> {
  final _picker = ImagePicker();
  List<String> _images = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _images = widget.initialImages;
  }

  Future<void> _showImageSourceDialog() async {
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выберите источник'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Галерея'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Камера'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
    if (source != null) {
      await _pickImage(source);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 85, // Оптимизация качества
      maxWidth: 1920, // Максимальная ширина
      maxHeight: 1080, // Максимальная высота
    );

    if (pickedFile == null) return;
    setState(() => _isLoading = true);
    try {
      final imageUrl = await ref.read(storageServiceProvider)
          .uploadEquipmentImage(File(pickedFile.path));

      setState(() {
        _images = [..._images, imageUrl];
        widget.onImagesChanged(_images);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
      widget.onImagesChanged(_images);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Фотографии',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: _isLoading ? null : _showImageSourceDialog,
              icon: const Icon(Icons.add_a_photo),
              label: const Text('Добавить фото'),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Container(
          height: 120.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _images.length + 1,
            itemBuilder: (context, index) {
              if (index == _images.length) {
                return GestureDetector(
                  onTap: _isLoading ? null : _showImageSourceDialog,
                  child: Container(
                    width: 120.w,
                    margin: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : Icon(
                      Icons.add_photo_alternate,
                      size: 40.r,
                      color: Colors.grey[400],
                    ),
                  ),
                );
              }

              return Stack(
                children: [
                  Container(
                    width: 120.w,
                    margin: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.r),
                      image: DecorationImage(
                        image: NetworkImage(_images[index]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                      icon: const Icon(Icons.remove_circle),
                      color: Colors.red,
                      onPressed: () => _removeImage(index),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}