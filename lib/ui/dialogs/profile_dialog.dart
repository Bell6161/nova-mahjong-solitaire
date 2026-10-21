import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/game_theme.dart';
import '../../services/storage_service.dart';

class ProfileDialog extends StatefulWidget {
  final GameTheme theme;
  final VoidCallback onProfileUpdated;

  const ProfileDialog({
    super.key,
    required this.theme,
    required this.onProfileUpdated,
  });

  @override
  State<ProfileDialog> createState() => _ProfileDialogState();
}

class _ProfileDialogState extends State<ProfileDialog> {
  late TextEditingController _nameController;
  int _selectedAvatarId = 0;
  String? _customAvatarPath;
  final ImagePicker _picker = ImagePicker();

  final List<IconData> _presetAvatars = [
    Icons.spa_rounded,
    Icons.wb_sunny_rounded,
    Icons.shield_rounded,
    Icons.military_tech_rounded,
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: StorageService.userName);
    _selectedAvatarId = StorageService.avatarId;
    _customAvatarPath = StorageService.customAvatarPath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          _customAvatarPath = image.path;
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    if (name.isNotEmpty) {
      await StorageService.setUserName(name);
    }
    await StorageService.setAvatarId(_selectedAvatarId);
    await StorageService.setCustomAvatarPath(_customAvatarPath);
    widget.onProfileUpdated();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: widget.theme.cardBackgroundColor.withOpacity(0.97),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: widget.theme.tileHighlightColor.withOpacity(0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.person_rounded, color: widget.theme.tileHighlightColor, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'PLAYER PROFILE',
                        style: TextStyle(
                          color: widget.theme.primaryTextColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: widget.theme.primaryTextColor),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Current Avatar Preview
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: widget.theme.tileHighlightColor, width: 3),
                      color: widget.theme.boardBackgroundColor,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _buildAvatarImage(),
                  ),
                  GestureDetector(
                    onTap: _pickImageFromGallery,
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: widget.theme.tileHighlightColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.photo_camera_rounded, size: 16, color: Colors.black),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: _pickImageFromGallery,
                icon: Icon(Icons.upload_rounded, color: widget.theme.secondaryTextColor, size: 18),
                label: Text(
                  'Upload Custom Photo',
                  style: TextStyle(
                    color: widget.theme.secondaryTextColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Or choose preset avatar
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_presetAvatars.length, (idx) {
                  final bool isSelected = _customAvatarPath == null && _selectedAvatarId == idx;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedAvatarId = idx;
                        _customAvatarPath = null;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.theme.boardBackgroundColor,
                        border: Border.all(
                          color: isSelected
                              ? widget.theme.tileHighlightColor
                              : widget.theme.gridLineColor,
                          width: isSelected ? 2.5 : 1.0,
                        ),
                      ),
                      child: Icon(
                        _presetAvatars[idx],
                        color: isSelected ? widget.theme.tileHighlightColor : Colors.grey,
                        size: 22,
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 18),

              // Player Name Field
              TextField(
                controller: _nameController,
                maxLength: 18,
                style: TextStyle(color: widget.theme.primaryTextColor, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  labelText: 'Player Name',
                  labelStyle: TextStyle(color: widget.theme.secondaryTextColor),
                  counterStyle: TextStyle(color: widget.theme.primaryTextColor.withOpacity(0.5)),
                  prefixIcon: Icon(Icons.badge_outlined, color: widget.theme.tileHighlightColor),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: widget.theme.gridLineColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: widget.theme.tileHighlightColor, width: 2),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Save Button
              ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.theme.tileHighlightColor,
                  foregroundColor: Colors.black,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                ),
                child: const Text(
                  'SAVE PROFILE',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarImage() {
    if (_customAvatarPath != null && !kIsWeb) {
      final file = File(_customAvatarPath!);
      if (file.existsSync()) {
        return Image.file(file, fit: BoxFit.cover);
      }
    }
    return Icon(
      _presetAvatars[_selectedAvatarId % _presetAvatars.length],
      size: 48,
      color: widget.theme.tileHighlightColor,
    );
  }
}
