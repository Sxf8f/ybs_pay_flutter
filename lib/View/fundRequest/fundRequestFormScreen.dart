import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ybs_pay/core/repository/fundRequestRepository/fundRequestRepo.dart';
import 'package:ybs_pay/core/models/fundRequestModels/fundRequestModel.dart';
import 'package:ybs_pay/core/const/color_const.dart';
import 'package:ybs_pay/main.dart';
import 'package:ybs_pay/View/widgets/snackBar.dart';

class FundRequestFormScreen extends StatefulWidget {
  const FundRequestFormScreen({super.key});

  @override
  State<FundRequestFormScreen> createState() => _FundRequestFormScreenState();
}

class _FundRequestFormScreenState extends State<FundRequestFormScreen> {
  final FundRequestRepository _repository = FundRequestRepository();
  
  // Form controllers
  final TextEditingController amountController = TextEditingController();
  final TextEditingController accountHolderController = TextEditingController();
  final TextEditingController accountNumberController = TextEditingController();
  final TextEditingController ifscCodeController = TextEditingController();
  final TextEditingController branchController = TextEditingController();
  final TextEditingController remarkController = TextEditingController();

  // Dropdown values
  List<Bank> banks = [];
  List<TransferMode> transferModes = [];
  List<WalletType> walletTypes = [];
  
  int? selectedBankId;
  int? selectedTransferModeId;
  int? selectedWalletTypeId;
  
  Bank? selectedBank;
  
  // Receipt
  File? selectedReceipt;
  
  // Loading states
  bool isLoading = false;
  bool isSubmitting = false;
  
  @override
  void initState() {
    super.initState();
    _loadFormData();
  }

  @override
  void dispose() {
    amountController.dispose();
    accountHolderController.dispose();
    accountNumberController.dispose();
    ifscCodeController.dispose();
    branchController.dispose();
    remarkController.dispose();
    super.dispose();
  }

  Future<void> _loadFormData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await _repository.getFormData();
      setState(() {
        banks = response.data.banks;
        transferModes = response.data.transferModes;
        walletTypes = response.data.walletTypes;
        
        // Set default wallet type (usually Prepaid)
        if (walletTypes.isNotEmpty) {
          selectedWalletTypeId = walletTypes.first.id;
        }
        
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        showSnack(context, 'Failed to load form data: $e');
      }
    }
  }

  Future<void> _loadBankDetails(int bankId) async {
    try {
      final response = await _repository.getBankDetails(bankId);
      final bank = response.bank;
      
      setState(() {
        selectedBank = bank;
        accountHolderController.text = bank.accountHolder;
        accountNumberController.text = bank.accountNumber;
        ifscCodeController.text = bank.ifscCode;
        branchController.text = bank.branchName;
      });
    } catch (e) {
      if (mounted) {
        showSnack(context, 'Failed to load bank details: $e');
      }
    }
  }

  Future<void> _pickReceipt(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        selectedReceipt = File(pickedFile.path);
      });
    }
  }

  void _showReceiptPickerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          'Select Receipt',
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
                style: TextStyle(fontSize: scrWidth * 0.032),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickReceipt(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library, size: scrWidth * 0.05),
              title: Text(
                'Gallery',
                style: TextStyle(fontSize: scrWidth * 0.032),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickReceipt(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitFundRequest() async {
    // Validation
    if (amountController.text.trim().isEmpty) {
      showSnack(context, 'Please enter amount');
      return;
    }

    final amount = double.tryParse(amountController.text.trim());
    if (amount == null || amount <= 0) {
      showSnack(context, 'Please enter a valid amount');
      return;
    }

    if (selectedTransferModeId == null) {
      showSnack(context, 'Please select transfer mode');
      return;
    }

    if (accountNumberController.text.trim().isEmpty) {
      showSnack(context, 'Please enter account number');
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      FundRequestSubmitResponse response;

      if (selectedReceipt != null) {
        // Submit with receipt
        response = await _repository.submitFundRequestWithReceipt(
          amount: amountController.text.trim(),
          bankId: selectedBankId,
          transferModeId: selectedTransferModeId!,
          walletTypeId: selectedWalletTypeId,
          accountHolder: accountHolderController.text.trim(),
          accountNumber: accountNumberController.text.trim(),
          ifscCode: ifscCodeController.text.trim(),
          branch: branchController.text.trim(),
          remark: remarkController.text.trim(),
          receiptFile: selectedReceipt!,
        );
      } else {
        // Submit without receipt
        response = await _repository.submitFundRequest(
          amount: amountController.text.trim(),
          bankId: selectedBankId,
          transferModeId: selectedTransferModeId!,
          walletTypeId: selectedWalletTypeId,
          accountHolder: accountHolderController.text.trim(),
          accountNumber: accountNumberController.text.trim(),
          ifscCode: ifscCodeController.text.trim(),
          branch: branchController.text.trim(),
          remark: remarkController.text.trim(),
        );
      }

      setState(() {
        isSubmitting = false;
      });

      if (mounted) {
        // Show success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Text('Success'),
            content: Text(response.message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      setState(() {
        isSubmitting = false;
      });
      if (mounted) {
        showSnack(context, 'Failed to submit fund request: $e');
      }
    }
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    int? maxLength,
    bool enabled = true,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: scrWidth * 0.03),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: scrWidth * 0.035,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: scrWidth * 0.02),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType ?? TextInputType.text,
            maxLength: maxLength,
            enabled: enabled,
            style: TextStyle(
              fontSize: scrWidth * 0.035,
              color: Colors.black,
              fontWeight: FontWeight.w400,
            ),
            textInputAction: TextInputAction.next,
            cursorColor: colorConst.primaryColor1,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey.shade50,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              counterText: '',
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
                borderSide: BorderSide(color: colorConst.primaryColor1, width: 2),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required List<T> items,
    required T? selectedValue,
    required String Function(T) getLabel,
    required int Function(T) getId,
    required Function(T?) onChanged,
  }) {
    // Find the matching item in the list by ID to avoid instance mismatch
    T? matchingValue;
    if (selectedValue != null && items.isNotEmpty) {
      final selectedId = getId(selectedValue);
      try {
        matchingValue = items.firstWhere(
          (item) => getId(item) == selectedId,
          orElse: () => items.first,
        );
      } catch (e) {
        matchingValue = null;
      }
    }

    return Padding(
      padding: EdgeInsets.only(bottom: scrWidth * 0.03),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: scrWidth * 0.035,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: scrWidth * 0.02),
          DropdownButtonFormField<T>(
            value: matchingValue,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey.shade50,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                borderSide: BorderSide(color: colorConst.primaryColor1, width: 2),
              ),
            ),
            hint: Text(
              'Select $label',
              style: TextStyle(fontSize: scrWidth * 0.035, color: Colors.grey[600]),
            ),
            items: items.map((item) {
              return DropdownMenuItem<T>(
                value: item,
                child: Text(
                  getLabel(item),
                  style: TextStyle(fontSize: scrWidth * 0.035),
                ),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back_ios, color: Colors.black),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: Text(
          'Fund Request',
          style: TextStyle(
            fontSize: scrWidth * 0.04,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              physics: BouncingScrollPhysics(),
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
                            Icons.account_balance_wallet_outlined,
                            color: colorConst.primaryColor1,
                            size: scrWidth * 0.05,
                          ),
                        ),
                        SizedBox(width: scrWidth * 0.03),
                        Text(
                          'Fund Request',
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
                    child: Column(
                      children: [
                    
                    // Amount
                    _buildTextField(
                      label: 'Amount',
                      controller: amountController,
                      keyboardType: TextInputType.number,
                    ),
                    
                    // Bank Dropdown
                    _buildDropdown<Bank>(
                      label: 'Bank',
                      items: banks,
                      selectedValue: selectedBank,
                      getLabel: (bank) => bank.bankName,
                      getId: (bank) => bank.id,
                      onChanged: (bank) {
                        setState(() {
                          selectedBank = bank;
                          selectedBankId = bank?.id;
                        });
                        if (bank != null) {
                          _loadBankDetails(bank.id);
                        }
                      },
                    ),
                    
                    // Transfer Mode Dropdown
                    transferModes.isEmpty
                        ? SizedBox.shrink()
                        : _buildDropdown<TransferMode>(
                            label: 'Transfer Mode',
                            items: transferModes,
                            selectedValue: selectedTransferModeId != null
                                ? transferModes.firstWhere(
                                    (tm) => tm.id == selectedTransferModeId,
                                    orElse: () => transferModes.first,
                                  )
                                : null,
                            getLabel: (tm) => tm.name,
                            getId: (tm) => tm.id,
                            onChanged: (tm) {
                              setState(() {
                                selectedTransferModeId = tm?.id;
                              });
                            },
                          ),
                    
                    // Account Holder
                    _buildTextField(
                      label: 'Account Holder',
                      controller: accountHolderController,
                    ),
                    
                    // Account Number
                    _buildTextField(
                      label: 'Account Number',
                      controller: accountNumberController,
                      keyboardType: TextInputType.number,
                    ),
                    
                    // IFSC Code
                    _buildTextField(
                      label: 'IFSC Code',
                      controller: ifscCodeController,
                    ),
                    
                    // Branch
                    _buildTextField(
                      label: 'Branch',
                      controller: branchController,
                    ),
                    
                    // Remark
                    _buildTextField(
                      label: 'Remark (Optional)',
                      controller: remarkController,
                      keyboardType: TextInputType.multiline,
                    ),
                    
                        // Receipt Section
                        Padding(
                          padding: EdgeInsets.only(bottom: scrWidth * 0.03),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Receipt (Optional)',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: scrWidth * 0.035,
                                  color: Colors.grey[700],
                                ),
                              ),
                              SizedBox(height: scrWidth * 0.02),
                              Row(
                                children: [
                                  if (selectedReceipt != null)
                                    Container(
                                      width: scrWidth * 0.2,
                                      height: scrWidth * 0.2,
                                      margin: EdgeInsets.only(right: 12),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.grey.shade300),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.file(
                                          selectedReceipt!,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  Expanded(
                                    child: InkWell(
                                      onTap: _showReceiptPickerDialog,
                                      child: Container(
                                        height: scrWidth * 0.12,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: Colors.grey.shade300),
                                          color: Colors.grey.shade50,
                                        ),
                                        child: Center(
                                          child: Text(
                                            selectedReceipt != null ? 'Change Receipt' : 'Choose Receipt',
                                            style: TextStyle(
                                              fontSize: scrWidth * 0.035,
                                              color: Colors.grey.shade700,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (selectedReceipt != null) ...[
                                    SizedBox(width: 8),
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          selectedReceipt = null;
                                        });
                                      },
                                      child: Container(
                                        width: scrWidth * 0.12,
                                        height: scrWidth * 0.12,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.red.shade300),
                                          color: Colors.red.shade50,
                                        ),
                                        child: Icon(Icons.close, color: Colors.red.shade700, size: scrWidth * 0.05),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        SizedBox(height: scrWidth * 0.04),
                        
                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isSubmitting ? null : _submitFundRequest,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorConst.primaryColor1,
                              padding: EdgeInsets.symmetric(vertical: scrWidth * 0.04),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: isSubmitting
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : Text(
                                    'Submit Fund Request',
                                    style: TextStyle(
                                      fontSize: scrWidth * 0.035,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                        
                        SizedBox(height: scrWidth * 0.04),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

