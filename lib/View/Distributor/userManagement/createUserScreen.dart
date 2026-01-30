import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/bloc/distributorBloc/distributorUserBloc.dart';
import '../../../core/bloc/distributorBloc/distributorUserEvent.dart';
import '../../../core/bloc/distributorBloc/distributorUserState.dart';
import '../../../core/const/color_const.dart';
import '../../../main.dart';
import '../../widgets/app_bar.dart';

class CreateUserScreen extends StatefulWidget {
  const CreateUserScreen({super.key});

  @override
  State<CreateUserScreen> createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _addressController = TextEditingController();
  final _outletController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _pincodeController.dispose();
    _addressController.dispose();
    _outletController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(scrWidth * 0.04),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(
                      color: colorConst.primaryColor1.withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(scrWidth * 0.025),
                      decoration: BoxDecoration(
                        color: colorConst.primaryColor1.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(scrWidth * 0.01),
                      ),
                      child: Icon(
                        Icons.person_add_outlined,
                        color: colorConst.primaryColor1,
                        size: scrWidth * 0.05,
                      ),
                    ),
                    SizedBox(width: scrWidth * 0.03),
                    Text(
                      'Create New Retailer',
                      style: TextStyle(
                        fontSize: scrWidth * 0.04,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              // Form Section
              Padding(
                padding: EdgeInsets.all(scrWidth * 0.04),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Username Field
                      TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: colorConst.primaryColor1,
                              width: 2,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter username';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: scrWidth * 0.03),
          
                      // Email Field
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: colorConst.primaryColor1,
                              width: 2,
                            ),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter email';
                          }
                          if (!value.contains('@')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: scrWidth * 0.03),
          
                      // Phone Number Field
                      TextFormField(
                        controller: _phoneController,
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: colorConst.primaryColor1,
                              width: 2,
                            ),
                          ),
                        ),
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter phone number';
                          }
                          if (value.length != 10) {
                            return 'Phone number must be 10 digits';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: scrWidth * 0.03),
          
                      // Pincode Field (Optional)
                      TextFormField(
                        controller: _pincodeController,
                        decoration: InputDecoration(
                          labelText: 'Pincode (Optional)',
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: colorConst.primaryColor1,
                              width: 2,
                            ),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                      ),
                      SizedBox(height: scrWidth * 0.03),
          
                      // Address Field (Optional)
                      TextFormField(
                        controller: _addressController,
                        decoration: InputDecoration(
                          labelText: 'Address (Optional)',
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: colorConst.primaryColor1,
                              width: 2,
                            ),
                          ),
                        ),
                        maxLines: 3,
                      ),
                      SizedBox(height: scrWidth * 0.03),
          
                      // Outlet Field (Optional)
                      TextFormField(
                        controller: _outletController,
                        decoration: InputDecoration(
                          labelText: 'Outlet (Optional)',
                          hintText: 'Shop/Store name',
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: colorConst.primaryColor1,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: scrWidth * 0.03),
          
                      // Info Text about Slab Assignment
                      Container(
                        padding: EdgeInsets.all(scrWidth * 0.03),
                        decoration: BoxDecoration(
                          color: colorConst.primaryColor1.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: colorConst.primaryColor1.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: colorConst.primaryColor1,
                              size: scrWidth * 0.04,
                            ),
                            SizedBox(width: scrWidth * 0.02),
                            Expanded(
                              child: Text(
                                'Slab will be automatically assigned. User will be created as a Retailer.',
                                style: TextStyle(
                                  fontSize: scrWidth * 0.028,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: scrWidth * 0.05),
          
                      // Create Button
                      BlocListener<DistributorUserBloc, DistributorUserState>(
                        listener: (context, state) {
                          if (state is DistributorUserCreated) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('User created successfully'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            Navigator.pop(context, true);
                          } else if (state is DistributorUserError) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error: ${state.message}'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        child: BlocBuilder<DistributorUserBloc, DistributorUserState>(
                          builder: (context, state) {
                            final isLoading = state is DistributorUserCreating;
                            return SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: isLoading
                                    ? null
                                    : () {
                                        if (_formKey.currentState!.validate()) {
                                          context.read<DistributorUserBloc>().add(
                                            CreateUserEvent(
                                              username: _usernameController.text
                                                  .trim(),
                                              email: _emailController.text.trim(),
                                              phoneNumber: _phoneController.text
                                                  .trim(),
                                              pincode:
                                                  _pincodeController.text
                                                      .trim()
                                                      .isEmpty
                                                  ? null
                                                  : _pincodeController.text
                                                        .trim(),
                                              address:
                                                  _addressController.text
                                                      .trim()
                                                      .isEmpty
                                                  ? null
                                                  : _addressController.text
                                                        .trim(),
                                              outlet:
                                                  _outletController.text
                                                      .trim()
                                                      .isEmpty
                                                  ? null
                                                  : _outletController.text.trim(),
                                              // roleId not passed - API defaults to 6 (Retailer) for distributors
                                            ),
                                          );
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colorConst.primaryColor1,
                                  padding: EdgeInsets.symmetric(
                                    vertical: scrWidth * 0.04,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: isLoading
                                    ? SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                    : Text(
                                        'Create User',
                                        style: TextStyle(
                                          color: colorConst.white,
                                          fontSize: scrWidth * 0.035,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
