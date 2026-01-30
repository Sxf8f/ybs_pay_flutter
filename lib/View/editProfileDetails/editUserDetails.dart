import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ybs_pay/View/editProfileDetails/widgets/appBarEditUserDetails.dart';
import 'package:ybs_pay/View/editProfileDetails/widgets/containerBackground.dart';
import 'package:ybs_pay/core/repository/userRepository/userRepo.dart';
import 'package:ybs_pay/core/models/userModels/profileModel.dart';
import 'package:ybs_pay/core/const/color_const.dart';
import 'package:ybs_pay/main.dart';
import '../widgets/snackBar.dart';

class editUserDetails extends StatefulWidget {
  const editUserDetails({super.key});

  @override
  State<editUserDetails> createState() => _editUserDetailsState();
}

class _editUserDetailsState extends State<editUserDetails> {
  final UserRepository _userRepository = UserRepository();
  
  // Controllers for API fields only
  final TextEditingController emailController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController outletController = TextEditingController();
  
  bool isGst = false;
  bool isLoading = false;
  bool isSaving = false;
  
  File? selectedProfilePicture;
  String? currentProfilePictureUrl;
  
  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  @override
  void dispose() {
    emailController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    phoneNumberController.dispose();
    pincodeController.dispose();
    addressController.dispose();
    outletController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await _userRepository.getProfileForEditing();
      final profile = response.profile;

      setState(() {
        emailController.text = profile.email;
        firstNameController.text = profile.firstName;
        lastNameController.text = profile.lastName;
        phoneNumberController.text = profile.phoneNumber;
        pincodeController.text = profile.pincode;
        addressController.text = profile.address;
        outletController.text = profile.outlet;
        isGst = profile.isGst;
        currentProfilePictureUrl = profile.profilePictureUrl;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        showSnack(context, 'Failed to load profile: $e');
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        selectedProfilePicture = File(pickedFile.path);
      });
    }
  }

  void _showImagePickerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          'Select Profile Picture',
          style: TextStyle(
            fontSize: scrWidth * 0.035,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt, size: scrWidth * 0.05),
              title: Text(
                'Camera',
                style: TextStyle(
                  fontSize: scrWidth * 0.032,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library, size: scrWidth * 0.05),
              title: Text(
                'Gallery',
                style: TextStyle(
                  fontSize: scrWidth * 0.032,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateProfile() async {
    // Validation
    if (emailController.text.trim().isEmpty) {
      showSnack(context, 'Please enter email');
      return;
    }

    if (firstNameController.text.trim().isEmpty) {
      showSnack(context, 'Please enter first name');
      return;
    }

    if (lastNameController.text.trim().isEmpty) {
      showSnack(context, 'Please enter last name');
      return;
    }

    if (phoneNumberController.text.trim().isEmpty) {
      showSnack(context, 'Please enter phone number');
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      ProfileUpdateResponse response;

      if (selectedProfilePicture != null) {
        // Update with profile picture
        response = await _userRepository.updateProfileWithPicture(
          email: emailController.text.trim(),
          firstName: firstNameController.text.trim(),
          lastName: lastNameController.text.trim(),
          phoneNumber: phoneNumberController.text.trim(),
          pincode: pincodeController.text.trim(),
          address: addressController.text.trim(),
          outlet: outletController.text.trim(),
          isGst: isGst,
          profilePicture: selectedProfilePicture!,
        );
      } else {
        // Update without profile picture
        response = await _userRepository.updateProfile(
          email: emailController.text.trim(),
          firstName: firstNameController.text.trim(),
          lastName: lastNameController.text.trim(),
          phoneNumber: phoneNumberController.text.trim(),
          pincode: pincodeController.text.trim(),
          address: addressController.text.trim(),
          outlet: outletController.text.trim(),
          isGst: isGst,
        );
      }

      setState(() {
        isSaving = false;
        selectedProfilePicture = null;
        currentProfilePictureUrl = response.user.profilePictureUrl;
      });

      if (mounted) {
        showSnack(context, response.message);
        Navigator.pop(context, true); // Return true to indicate profile was updated
      }
    } catch (e) {
      setState(() {
        isSaving = false;
      });
      if (mounted) {
        showSnack(context, 'Failed to update profile: $e');
      }
    }
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    int? maxLength,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0, left: 8, bottom: 16),
      child: Container(
        width: scrWidth * 0.88,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: scrWidth * 0.03,
                ),
              ),
            ),
            Container(
              width: scrWidth * 0.88,
              height: scrWidth * 0.12,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(scrWidth * 0.02),
                border: Border.all(color: Colors.grey),
              ),
              child: TextFormField(
                controller: controller,
                keyboardType: keyboardType ?? TextInputType.text,
                maxLength: maxLength,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                ),
                textInputAction: TextInputAction.next,
                cursorColor: Colors.grey,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.transparent,
                  contentPadding: EdgeInsets.all(10),
                  counterText: '',
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePictureSection() {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0, left: 8, bottom: 16),
      child: Container(
        width: scrWidth * 0.88,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Profile Picture",
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: scrWidth * 0.03,
                ),
              ),
            ),
            Row(
              children: [
                // Profile picture preview
                Container(
                  width: scrWidth * 0.2,
                  height: scrWidth * 0.2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey),
                  ),
                  child: ClipOval(
                    child: selectedProfilePicture != null
                        ? Image.file(
                            selectedProfilePicture!,
                            fit: BoxFit.cover,
                          )
                        : currentProfilePictureUrl != null
                            ? CachedNetworkImage(
                                imageUrl: currentProfilePictureUrl!,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Icon(Icons.person),
                                errorWidget: (context, url, error) => Icon(Icons.person),
                              )
                            : Icon(Icons.person, size: scrWidth * 0.1),
                  ),
                ),
                SizedBox(width: 16),
                // Choose file button
                Expanded(
                  child: InkWell(
                    onTap: _showImagePickerDialog,
                    child: Container(
                      height: scrWidth * 0.12,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(scrWidth * 0.02),
                        border: Border.all(color: Colors.grey),
                        color: Colors.grey.shade100,
                      ),
                      child: Center(
                        child: Text(
                          selectedProfilePicture != null ? 'Change Picture' : 'Choose Picture',
                          style: TextStyle(
                            fontSize: scrWidth * 0.03,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (selectedProfilePicture != null) ...[
                  SizedBox(width: 8),
                  InkWell(
                    onTap: () {
                      setState(() {
                        selectedProfilePicture = null;
                      });
                    },
                    child: Container(
                      width: scrWidth * 0.12,
                      height: scrWidth * 0.12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.red),
                        color: Colors.red.shade50,
                      ),
                      child: Icon(Icons.close, color: Colors.red, size: scrWidth * 0.05),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGstCheckbox() {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0, left: 8, bottom: 16),
      child: Container(
        width: scrWidth * 0.88,
        child: Row(
          children: [
            Checkbox(
              value: isGst,
              onChanged: (value) {
                setState(() {
                  isGst = value ?? false;
                });
              },
            ),
            Text(
              'GST Registered',
              style: TextStyle(
                fontSize: scrWidth * 0.03,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Center(
        child: backgroundContainer(
          Widgets: [
            SizedBox(height: 20),
            // Profile Picture Skeleton
            Padding(
              padding: const EdgeInsets.only(right: 8.0, left: 8, bottom: 16),
              child: Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: scrWidth * 0.2,
                      height: scrWidth * 0.03,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.grey[300],
                          radius: scrWidth * 0.1,
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Container(
                            height: scrWidth * 0.12,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(scrWidth * 0.02),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Text Fields Skeleton
            ...List.generate(7, (index) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0, left: 8, bottom: 16),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: scrWidth * 0.3,
                        height: scrWidth * 0.03,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        width: scrWidth * 0.88,
                        height: scrWidth * 0.12,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(scrWidth * 0.02),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            // GST Checkbox Skeleton
            Padding(
              padding: const EdgeInsets.only(right: 8.0, left: 8, bottom: 16),
              child: Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      width: scrWidth * 0.3,
                      height: scrWidth * 0.03,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            // Update Button Skeleton
            Padding(
              padding: const EdgeInsets.only(top: 14, right: 16, bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(scrWidth * 0.04),
                      ),
                      child: Container(
                        width: scrWidth * 0.25,
                        height: scrWidth * 0.03,
                        color: Colors.grey[300],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarEditScreen(),
      backgroundColor: Colors.white,
      body: isLoading
          ? _buildSkeletonLoader()
          : SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Center(
                child: Column(
                  children: [
                    backgroundContainer(
                      Widgets: [
                      SizedBox(height: 20),
                      
                      // Profile Picture
                      _buildProfilePictureSection(),
                      
                      SizedBox(height: 10),
                      
                      // First Name
                      _buildTextField(
                        label: 'First Name',
                        controller: firstNameController,
                      ),
                      
                      // Last Name
                      _buildTextField(
                        label: 'Last Name',
                        controller: lastNameController,
                      ),
                      
                      // Email
                      _buildTextField(
                        label: 'Email',
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      
                      // Phone Number
                      _buildTextField(
                        label: 'Phone Number',
                        controller: phoneNumberController,
                        keyboardType: TextInputType.phone,
                        maxLength: 15,
                      ),
                      
                      // Outlet
                      _buildTextField(
                        label: 'Outlet',
                        controller: outletController,
                      ),
                      
                      // Pincode
                      _buildTextField(
                        label: 'Pincode',
                        controller: pincodeController,
                        keyboardType: TextInputType.number,
                        maxLength: 10,
                      ),
                      
                      // Address
                      _buildTextField(
                        label: 'Address',
                        controller: addressController,
                        keyboardType: TextInputType.multiline,
                      ),
                      
                      // GST Checkbox
                      _buildGstCheckbox(),
                      
                      SizedBox(height: 20),
                      
                      // Update Button
                      Padding(
                        padding: const EdgeInsets.only(top: 14, right: 16, bottom: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              child: InkWell(
                                onTap: isSaving ? null : _updateProfile,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(scrWidth * 0.04),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 10,
                                        offset: Offset(0, 5),
                                      ),
                                    ],
                                    gradient: LinearGradient(
                                      colors: [
                                        colorConst.primaryColor3,
                                        colorConst.primaryColor3,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: isSaving
                                        ? SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                            ),
                                          )
                                        : Text(
                                            'Update Profile',
                                            style: TextStyle(
                                              fontSize: scrWidth * 0.03,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.white,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    ),
                    SizedBox(height: scrWidth * 0.1),
                  ],
                ),
              ),
            ),
    );
  }
}
