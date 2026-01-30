import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/bloc/distributorBloc/distributorFundTransferBloc.dart';
import '../../../core/bloc/distributorBloc/distributorFundTransferEvent.dart';
import '../../../core/bloc/distributorBloc/distributorFundTransferState.dart';
import '../../../core/repository/distributorRepository/distributorRepo.dart';
import '../../../core/models/distributorModels/distributorFundTransferModel.dart';
import '../../../core/const/color_const.dart';
import '../../../main.dart';
import '../../widgets/app_bar.dart';

class FundTransferScreen extends StatefulWidget {
  const FundTransferScreen({super.key});

  @override
  State<FundTransferScreen> createState() => _FundTransferScreenState();
}

class _FundTransferScreenState extends State<FundTransferScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _remarkController = TextEditingController();
  final TextEditingController _secureKeyController = TextEditingController();
  FundTransferUser? _selectedUser;
  bool _showSecureKeyField = false;
  late DistributorFundTransferBloc _fundTransferBloc;

  @override
  void initState() {
    super.initState();
    _fundTransferBloc = DistributorFundTransferBloc(DistributorRepository());
    // Fetch all users when screen loads
    _fundTransferBloc.add(FetchAllUsersForTransferEvent(limit: 100));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _amountController.dispose();
    _remarkController.dispose();
    _secureKeyController.dispose();
    _fundTransferBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DistributorFundTransferBloc>.value(
      value: _fundTransferBloc,
      child: Scaffold(
        appBar: appBar(),
        backgroundColor: Colors.white,
        body: BlocListener<DistributorFundTransferBloc, DistributorFundTransferState>(
          listener: (context, state) {
            if (state is DistributorFundTransferSuccess) {
              _showSuccessDialog(context, state.response);
            } else if (state is DistributorFundTransferError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (state is DistributorFundTransferRequiresSecureKey) {
              setState(() {
                _showSecureKeyField = true;
              });
              // Show error message if available
              if (state.errorMessage != null &&
                  state.errorMessage!.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage!),
                    backgroundColor: Colors.orange,
                    duration: Duration(seconds: 4),
                  ),
                );
              }
            }
          },
          child: SingleChildScrollView(
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
                          Icons.swap_horiz,
                          color: colorConst.primaryColor1,
                          size: scrWidth * 0.05,
                        ),
                      ),
                      SizedBox(width: scrWidth * 0.03),
                      Text(
                        'Fund Transfer',
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
                  padding: EdgeInsets.only(top: scrWidth * 0.04,right: scrWidth * 0.04, left: scrWidth * 0.04, bottom: 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Search Users Section
                      Text(
                        'Search or Select User',
                        style: TextStyle(
                          fontSize: scrWidth * 0.035,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: scrWidth * 0.02),
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search by name, phone, or username...',
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.grey[600],
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(
                                    Icons.clear,
                                    color: Colors.grey[600],
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _searchController.clear();
                                      _selectedUser = null;
                                    });
                                    // Fetch all users when search is cleared
                                    _fundTransferBloc.add(
                                      FetchAllUsersForTransferEvent(limit: 100),
                                    );
                                  },
                                )
                              : null,
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
                        onChanged: (value) {
                          setState(() {});
                          if (value.length >= 2) {
                            _fundTransferBloc.add(
                              SearchUsersForTransferEvent(search: value),
                            );
                          } else if (value.isEmpty) {
                            // When search is cleared, fetch all users again
                            _fundTransferBloc.add(
                              FetchAllUsersForTransferEvent(limit: 100),
                            );
                          }
                        },
                      ),
                      SizedBox(height: scrWidth * 0.03),

                      // User List / Search Results
                      BlocBuilder<
                        DistributorFundTransferBloc,
                        DistributorFundTransferState
                      >(
                        builder: (context, state) {
                          // Show loading for all users
                          if (state is DistributorFundTransferAllUsersLoading) {
                            return Center(
                              child: Padding(
                                padding: EdgeInsets.all(scrWidth * 0.04),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          // Show loading for search
                          if (state is DistributorFundTransferSearchLoading) {
                            return Center(
                              child: Padding(
                                padding: EdgeInsets.all(scrWidth * 0.04),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          // Show search results
                          if (state is DistributorFundTransferSearchLoaded) {
                            if (state.users.isEmpty) {
                              return Container(
                                padding: EdgeInsets.all(scrWidth * 0.04),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    'No users found',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ),
                              );
                            }
                            return _buildUserList(state.users);
                          }
                          // Show all users
                          if (state is DistributorFundTransferAllUsersLoaded) {
                            if (state.users.isEmpty) {
                              return Container(
                                padding: EdgeInsets.all(scrWidth * 0.04),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    'No users available',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ),
                              );
                            }
                            return _buildUserList(state.users);
                          }
                          return SizedBox.shrink();
                        },
                      ),

                      if (_selectedUser != null) ...[
                        SizedBox(height: scrWidth * 0.04),
                        Divider(),
                        SizedBox(height: scrWidth * 0.04),

                        // Selected User Info
                        Container(
                          padding: EdgeInsets.all(scrWidth * 0.04),
                          decoration: BoxDecoration(
                            color: colorConst.primaryColor1.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: colorConst.primaryColor1.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.person,
                                color: colorConst.primaryColor1,
                                size: scrWidth * 0.06,
                              ),
                              SizedBox(width: scrWidth * 0.03),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Transferring to:',
                                      style: TextStyle(
                                        fontSize: scrWidth * 0.028,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    Text(
                                      _selectedUser!.name ??
                                          _selectedUser!.username,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: scrWidth * 0.035,
                                      ),
                                    ),
                                    if (_selectedUser!.phone != null)
                                      Text(
                                        _selectedUser!.phone!,
                                        style: TextStyle(
                                          fontSize: scrWidth * 0.03,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: scrWidth * 0.04),

                        // Amount Field
                        Text(
                          'Amount',
                          style: TextStyle(
                            fontSize: scrWidth * 0.035,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: scrWidth * 0.02),
                        TextField(
                          controller: _amountController,
                          keyboardType: TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Enter amount',
                            prefixIcon: Icon(
                              Icons.currency_rupee,
                              color: Colors.grey[600],
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
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

                        // Remark Field
                        Text(
                          'Remark (Optional)',
                          style: TextStyle(
                            fontSize: scrWidth * 0.035,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: scrWidth * 0.02),
                        TextField(
                          controller: _remarkController,
                          decoration: InputDecoration(
                            hintText: 'Add a note...',
                            prefixIcon: Icon(
                              Icons.note,
                              color: Colors.grey[600],
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
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

                        // Secure Key Field (shown when required)
                        if (_showSecureKeyField) ...[
                          SizedBox(height: scrWidth * 0.03),
                          Text(
                            'Secure Key',
                            style: TextStyle(
                              fontSize: scrWidth * 0.035,
                              fontWeight: FontWeight.w600,
                              color: Colors.red,
                            ),
                          ),
                          SizedBox(height: scrWidth * 0.02),
                          TextField(
                            controller: _secureKeyController,
                            obscureText: true,
                            decoration: InputDecoration(
                              hintText: 'Enter secure key',
                              prefixIcon: Icon(
                                Icons.lock,
                                color: Colors.grey[600],
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.red,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ],

                        SizedBox(height: scrWidth * 0.04),

                        // Transfer Button
                        BlocBuilder<
                          DistributorFundTransferBloc,
                          DistributorFundTransferState
                        >(
                          builder: (blocContext, state) {
                            final isLoading =
                                state is DistributorFundTransferLoading;
                            return SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: isLoading
                                    ? null
                                    : () {
                                        if (_amountController.text.isEmpty) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Please enter amount',
                                              ),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                          return;
                                        }
                                        final amount = double.tryParse(
                                          _amountController.text,
                                        );
                                        if (amount == null || amount <= 0) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Please enter a valid amount',
                                              ),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                          return;
                                        }
                                        // Use the _fundTransferBloc from state
                                        _fundTransferBloc.add(
                                          FundTransferEvent(
                                            receiverId: _selectedUser!.id
                                                .toString(),
                                            amount: _amountController.text,
                                            remark:
                                                _remarkController.text.isEmpty
                                                ? null
                                                : _remarkController.text,
                                            secureKey:
                                                _secureKeyController
                                                    .text
                                                    .isEmpty
                                                ? null
                                                : _secureKeyController.text,
                                          ),
                                        );
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
                                        'Transfer',
                                        style: TextStyle(
                                          fontSize: scrWidth * 0.035,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, FundTransferResponse response) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: Colors.green,
                size: scrWidth * 0.05,
              ),
            ),
            SizedBox(width: scrWidth * 0.02),
            Expanded(
              child: Text(
                'Transfer Successful',
                style: TextStyle(
                  fontSize: scrWidth * 0.04,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(scrWidth * 0.03),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  response.message,
                  style: TextStyle(
                    fontSize: scrWidth * 0.035,
                    fontWeight: FontWeight.w500,
                    color: Colors.green.shade900,
                  ),
                ),
              ),
              SizedBox(height: scrWidth * 0.03),
              if (response.transactionId != null)
                _buildInfoRow('Transaction ID', response.transactionId!),
              if (response.amount != null)
                _buildInfoRow('Amount', '₹${response.amount}'),
              if (response.sender != null) ...[
                SizedBox(height: scrWidth * 0.02),
                Divider(),
                SizedBox(height: scrWidth * 0.02),
                Text(
                  'Sender Details',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: scrWidth * 0.035,
                  ),
                ),
                SizedBox(height: scrWidth * 0.01),
                _buildInfoRow('Username', response.sender!.username),
                if (response.sender!.oldBalance != null)
                  _buildInfoRow(
                    'Previous Balance',
                    '₹${response.sender!.oldBalance}',
                  ),
                if (response.sender!.newBalance != null)
                  _buildInfoRow(
                    'New Balance',
                    '₹${response.sender!.newBalance}',
                  ),
              ],
              if (response.receiver != null) ...[
                SizedBox(height: scrWidth * 0.02),
                Divider(),
                SizedBox(height: scrWidth * 0.02),
                Text(
                  'Receiver Details',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: scrWidth * 0.035,
                  ),
                ),
                SizedBox(height: scrWidth * 0.01),
                _buildInfoRow('Username', response.receiver!.username),
                if (response.receiver!.phone != null)
                  _buildInfoRow('Phone', response.receiver!.phone!),
                if (response.receiver!.oldBalance != null)
                  _buildInfoRow(
                    'Previous Balance',
                    '₹${response.receiver!.oldBalance}',
                  ),
                if (response.receiver!.newBalance != null)
                  _buildInfoRow(
                    'New Balance',
                    '₹${response.receiver!.newBalance}',
                  ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to previous screen
            },
            style: TextButton.styleFrom(
              foregroundColor: colorConst.primaryColor1,
            ),
            child: Text(
              'OK',
              style: TextStyle(
                fontSize: scrWidth * 0.035,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(top: scrWidth * 0.01),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildUserList(List<FundTransferUser> users) {
    return Container(
      constraints: BoxConstraints(maxHeight: scrWidth * 1.5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          final isSelected = _selectedUser?.id == user.id;
          return InkWell(
            onTap: () {
              setState(() {
                _selectedUser = user;
              });
            },
            child: Container(
              padding: EdgeInsets.all(scrWidth * 0.04),
              decoration: BoxDecoration(
                color: isSelected
                    ? colorConst.primaryColor1.withOpacity(0.1)
                    : Colors.transparent,
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey.shade300,
                    width: index < users.length - 1 ? 1 : 0,
                  ),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: isSelected
                        ? colorConst.primaryColor1
                        : Colors.grey.shade300,
                    child: Icon(
                      Icons.person,
                      color: isSelected ? Colors.white : Colors.grey[600],
                    ),
                  ),
                  SizedBox(width: scrWidth * 0.03),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name ?? user.username,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: scrWidth * 0.035,
                          ),
                        ),
                        SizedBox(height: scrWidth * 0.01),
                        Text(
                          user.phone ?? user.email ?? '',
                          style: TextStyle(
                            fontSize: scrWidth * 0.03,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (user.role != null)
                          Text(
                            user.role!,
                            style: TextStyle(
                              fontSize: scrWidth * 0.028,
                              color: Colors.grey[500],
                            ),
                          ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${user.balance}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: scrWidth * 0.035,
                          color: colorConst.primaryColor1,
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check_circle,
                          color: colorConst.primaryColor1,
                          size: scrWidth * 0.05,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
