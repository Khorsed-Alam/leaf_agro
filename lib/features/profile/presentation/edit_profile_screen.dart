import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/user_profile_model.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/profile_provider.dart';
import '../../../../providers/settings_provider.dart';
import 'widgets/profile_avatar.dart';

/// Screen 24 Extension – Edit Profile Screen
/// Allows farmers to update full name, phone number, district, and avatar photo securely.
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  String? _selectedDistrict;
  String? _currentAvatarUrl;
  Uint8List? _pickedImageBytes;
  String? _pickedImageExtension;

  bool _isLoading = false;
  bool _isInitialized = false;

  static const List<String> _districts = [
    'Bagerhat',
    'Bandarban',
    'Barguna',
    'Barishal',
    'Bhola',
    'Bogura',
    'Brahmanbaria',
    'Chandpur',
    'Chattogram',
    'Chuadanga',
    'Cox\'s Bazar',
    'Cumilla',
    'Dhaka',
    'Dinajpur',
    'Faridpur',
    'Feni',
    'Gaibandha',
    'Gazipur',
    'Gopalganj',
    'Habiganj',
    'Jamalpur',
    'Jashore (Jessore)',
    'Jhalokati',
    'Jhenaidah',
    'Joypurhat',
    'Khagrachhari',
    'Khulna',
    'Kishoreganj',
    'Kurigram',
    'Kushtia',
    'Lakshmipur',
    'Lalmonirhat',
    'Madaripur',
    'Magura',
    'Manikganj',
    'Meherpur',
    'Moulvibazar',
    'Munshiganj',
    'Mymensingh',
    'Naogaon',
    'Narail',
    'Narayanganj',
    'Narsingdi',
    'Natore',
    'Netrokona',
    'Nilphamari',
    'Noakhali',
    'Pabna',
    'Panchagarh',
    'Patuakhali',
    'Pirojpur',
    'Rajbari',
    'Rajshahi',
    'Rangamati',
    'Rangpur',
    'Satkhira',
    'Shariatpur',
    'Sherpur',
    'Sirajganj',
    'Sunamganj',
    'Sylhet',
    'Tangail',
    'Thakurgaon',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _initializeValues(UserProfileModel? profile) {
    if (_isInitialized) return;
    _nameController.text = profile?.fullName ?? '';
    _phoneController.text = profile?.phoneNumber ?? '';
    _selectedDistrict = profile?.district;
    _currentAvatarUrl = profile?.avatarUrl;
    _isInitialized = true;
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (picked != null) {
        final bytes = await picked.readAsBytes();
        final ext = picked.path.split('.').last.toLowerCase();
        setState(() {
          _pickedImageBytes = bytes;
          _pickedImageExtension = ext.isNotEmpty ? ext : 'jpg';
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showImageSourceDialog(bool isBn) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isBn ? 'ছবি নির্বাচন করুন' : 'Change Profile Photo',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryText,
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined, color: AppColors.forestGreen),
                title: Text(isBn ? 'ক্যামেরা দিয়ে তুলুন' : 'Take a Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined, color: AppColors.forestGreen),
                title: Text(isBn ? 'গ্যালারি থেকে নিন' : 'Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveProfile(UserProfileModel currentProfile, bool isBn) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userService = ref.read(userServiceProvider);
      String? updatedAvatarUrl = _currentAvatarUrl;

      // 1. Upload new avatar if picked
      if (_pickedImageBytes != null) {
        try {
          updatedAvatarUrl = await userService.uploadProfileImage(
            userId: currentProfile.id,
            bytes: _pickedImageBytes!,
            fileExtension: _pickedImageExtension ?? 'jpg',
          );
        } catch (uploadError) {
          // Preserve old avatar if upload fails, but inform user
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  isBn
                      ? 'ছবি আপলোড ব্যর্থ হয়েছে, পূর্ববর্তী ছবি বহাল রয়েছে।'
                      : 'Avatar upload failed; existing photo was kept.',
                ),
                backgroundColor: AppColors.warning,
              ),
            );
          }
        }
      }

      // 2. Prepare updated profile model
      final updatedProfile = currentProfile.copyWith(
        fullName: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim().isNotEmpty
            ? _phoneController.text.trim()
            : null,
        district: _selectedDistrict,
        avatarUrl: updatedAvatarUrl,
        updatedAt: DateTime.now(),
      );

      // 3. Persist via UserService
      final savedProfile = await userService.updateProfile(updatedProfile);

      // 4. Update local Riverpod states
      ref.read(authProvider.notifier).updateCurrentUser(savedProfile);
      ref.invalidate(profileProvider);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isBn
                ? 'প্রোফাইল সফলভাবে আপডেট করা হয়েছে!'
                : 'Profile updated successfully!',
          ),
          backgroundColor: AppColors.success,
        ),
      );

      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isBn
                ? 'প্রোফাইল আপডেট ব্যর্থ হয়েছে: $e'
                : 'Failed to update profile: $e',
          ),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final isBn = settings.language == 'bn';
    final profileAsync = ref.watch(profileProvider);
    final currentUser = ref.watch(currentUserProvider);

    final profile = profileAsync.value ?? currentUser;

    if (profile == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(isBn ? 'প্রোফাইল সম্পাদনা' : 'Edit Profile'),
        ),
        body: Center(
          child: Text(
            isBn ? 'কোনো প্রোফাইল পাওয়া যায়নি' : 'No user profile found',
            style: const TextStyle(color: AppColors.secondaryText),
          ),
        ),
      );
    }

    _initializeValues(profile);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLowest,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primaryText),
          tooltip: isBn ? 'ফিরে যান' : 'Back',
          onPressed: () => context.pop(),
        ),
        title: Text(
          isBn ? 'প্রোফাইল সম্পাদনা' : 'Edit Profile',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.forestGreen,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Avatar Editor with Camera Overlay
                Center(
                  child: Stack(
                    children: [
                      if (_pickedImageBytes != null)
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.borderGreen, width: 2.5),
                            image: DecorationImage(
                              image: MemoryImage(_pickedImageBytes!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      else
                        ProfileAvatar(
                          avatarUrl: _currentAvatarUrl,
                          fullName: _nameController.text.isNotEmpty
                              ? _nameController.text
                              : profile.fullName,
                          radius: 48,
                          borderColor: AppColors.borderGreen,
                          borderWidth: 2.5,
                        ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: InkWell(
                          onTap: () => _showImageSourceDialog(isBn),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: AppColors.forestGreen,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: TextButton.icon(
                    onPressed: () => _showImageSourceDialog(isBn),
                    icon: const Icon(Icons.photo_camera, size: 16, color: AppColors.forestGreen),
                    label: Text(
                      isBn ? 'ছবি পরিবর্তন করুন' : 'Change Photo',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.forestGreen,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 1. Full Name Input
                Text(
                  isBn ? 'পুরো নাম *' : 'Full Name *',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.forestGreen),
                    hintText: isBn ? 'আপনার পুরো নাম লিখুন' : 'Enter your full name',
                    fillColor: Colors.white,
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.borderGreen),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.borderGreen),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().length < 2) {
                      return isBn
                          ? 'অনুগ্রহ করে কমপক্ষে ২ অক্ষরের নাম লিখুন'
                          : 'Please enter at least 2 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 2. Email (Read-Only)
                Text(
                  isBn ? 'ইমেইল ঠিকানা (পরিবর্তনযোগ্য নয়)' : 'Email Address (Read-Only)',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondaryText,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  initialValue: profile.email ?? 'guest@agricare.ai',
                  readOnly: true,
                  style: const TextStyle(color: AppColors.secondaryText),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.mail_outline_rounded, color: AppColors.secondaryText),
                    suffixIcon: const Icon(Icons.lock_outline_rounded, size: 18, color: AppColors.secondaryText),
                    fillColor: const Color(0xFFF0F4EF),
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.borderGreen),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.borderGreen),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 3. Phone Number Input
                Text(
                  isBn ? 'মোবাইল নম্বর' : 'Phone Number',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.forestGreen),
                    hintText: isBn ? '০১XXXXXXXXX' : '01XXXXXXXXX',
                    fillColor: Colors.white,
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.borderGreen),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.borderGreen),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 4. District / Location Dropdown
                Text(
                  isBn ? 'জেলা / অবস্থান' : 'Location / District',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: _districts.contains(_selectedDistrict)
                      ? _selectedDistrict
                      : null,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.location_on_outlined, color: AppColors.forestGreen),
                    hintText: isBn ? 'আপনার জেলা নির্বাচন করুন' : 'Select your district',
                    fillColor: Colors.white,
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.borderGreen),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.borderGreen),
                    ),
                  ),
                  items: _districts.map((d) {
                    return DropdownMenuItem<String>(
                      value: d,
                      child: Text(d),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() => _selectedDistrict = val);
                  },
                ),
                const SizedBox(height: 32),

                // Save Profile Button
                ElevatedButton(
                  onPressed: _isLoading ? null : () => _saveProfile(profile, isBn),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.forestGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          isBn ? 'সংরক্ষণ করুন' : 'Save Profile',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
