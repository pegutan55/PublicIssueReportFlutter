import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ReportDialog extends StatefulWidget {
  const ReportDialog({super.key});

  @override
  State<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  static const _maximumPhotos = 5;

  final _descriptionController = TextEditingController();
  final _imagePicker = ImagePicker();
  final List<XFile> _photos = [];
  bool _isOpeningCamera = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _takePhoto() async {
    setState(() => _isOpeningCamera = true);
    try {
      final photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (photo != null && mounted) {
        setState(() => _photos.add(photo));
      }
    } catch (error) {
      if (!mounted) return;
      debugPrint('Unable to open camera: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('カメラを起動できませんでした。権限を確認してください。')),
      );
    } finally {
      if (mounted) setState(() => _isOpeningCamera = false);
    }
  }

  Future<bool> _showConfirmation({
    required String title,
    required String message,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('いいえ'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('はい'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _requestClose() async {
    final shouldClose = await _showConfirmation(
      title: '故障報告をやめますか？',
      message: '入力した内容は保存されません。',
    );
    if (shouldClose && mounted) Navigator.of(context).pop();
  }

  Future<void> _removePhoto(int index) async {
    final shouldDelete = await _showConfirmation(
      title: '写真を削除しますか？',
      message: 'この写真を報告から削除します。',
    );
    if (shouldDelete && mounted) {
      setState(() => _photos.removeAt(index));
    }
  }

  Future<void> _submitReport() async {
    final hasDescription = _descriptionController.text.trim().isNotEmpty;
    if (_photos.isEmpty && !hasDescription) {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          content: const Text('写真、もしくは故障内容を入力してください'),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('閉じる'),
            ),
          ],
        ),
      );
      return;
    }

    final shouldSubmit = await _showConfirmation(
      title: '確認',
      message: '故障報告を行います。よろしいですか？',
    );
    if (!shouldSubmit || !mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        content: const Text('故障報告を行いました'),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: screenHeight * 0.9),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 18, 12, 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      '故障報告',
                      style: TextStyle(
                        color: Color(0xFF14273D),
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _requestClose,
                    tooltip: '閉じる',
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            '写真',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Text(
                          '${_photos.length}/$_maximumPhotos',
                          style: const TextStyle(
                            color: Color(0xFF687789),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (_photos.isNotEmpty) ...[
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _photos.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 9,
                              mainAxisSpacing: 9,
                              childAspectRatio: 1,
                            ),
                        itemBuilder: (context, index) => _PhotoTile(
                          photo: _photos[index],
                          onRemove: () => _removePhoto(index),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: _photos.length >= _maximumPhotos ||
                                _isOpeningCamera
                            ? null
                            : _takePhoto,
                        icon: _isOpeningCamera
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.photo_camera_outlined),
                        label: Text(
                          _photos.length >= _maximumPhotos
                              ? '写真は最大5枚です'
                              : '写真を撮る',
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      '故障内容',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 9),
                    TextField(
                      controller: _descriptionController,
                      minLines: 3,
                      maxLines: 5,
                      maxLength: 1000,
                      textInputAction: TextInputAction.newline,
                      decoration: const InputDecoration(
                        hintText: '故障の場所や状況を入力してください',
                        alignLabelWithHint: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 20),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _submitReport,
                  child: const Text(
                    '故障報告をする',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({required this.photo, required this.onRemove});

  final XFile photo;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.file(
            File(photo.path),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const ColoredBox(
              color: Color(0xFFE5EAF0),
              child: Icon(Icons.broken_image_outlined),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: Material(
              color: Colors.black54,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: onRemove,
                customBorder: const CircleBorder(),
                child: const Padding(
                  padding: EdgeInsets.all(5),
                  child: Icon(Icons.close, size: 16, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
