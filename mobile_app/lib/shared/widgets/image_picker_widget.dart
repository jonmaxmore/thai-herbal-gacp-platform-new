import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// วิดเจ็ตสำหรับเลือกรูปภาพจากกล้องหรือแกลเลอรี่
class ImagePickerWidget extends StatefulWidget {
  final void Function(XFile file) onImageSelected;
  final String? label;
  final double? width;
  final double? height;

  const ImagePickerWidget({
    super.key,
    required this.onImageSelected,
    this.label,
    this.width,
    this.height,
  });

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  XFile? _selectedImage;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: source, imageQuality: 85);
    if (file != null) {
      setState(() => _selectedImage = file);
      widget.onImageSelected(file);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_selectedImage != null)
          Image.file(
            File(_selectedImage!.path),
            width: widget.width ?? 120,
            height: widget.height ?? 120,
            fit: BoxFit.cover,
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.photo_camera),
              tooltip: 'ถ่ายภาพ',
              onPressed: () => _pickImage(ImageSource.camera),
            ),
            IconButton(
              icon: const Icon(Icons.photo_library),
              tooltip: 'เลือกจากแกลเลอรี่',
              onPressed: () => _pickImage(ImageSource.gallery),
            ),
          ],
        ),
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(widget.label!),
          ),
      ],
    );
  }
}