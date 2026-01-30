import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/bloc/distributorBloc/distributorUserBloc.dart';
import '../../../core/bloc/distributorBloc/distributorUserEvent.dart';
import '../../../core/bloc/distributorBloc/distributorUserState.dart';
import '../../../core/models/distributorModels/distributorUserModel.dart';
import '../../../core/const/color_const.dart';
import '../../../main.dart';
import '../../widgets/app_bar.dart';
import 'createUserScreen.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedRole;

  @override
  void initState() {
    super.initState();
    context.read<DistributorUserBloc>().add(FetchUserListEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      backgroundColor: Colors.white,
      body: BlocListener<DistributorUserBloc, DistributorUserState>(
        listener: (context, state) {
          // Automatically refresh the list when a user is created
          if (state is DistributorUserCreated) {
            context.read<DistributorUserBloc>().add(FetchUserListEvent(
              search: _searchController.text.isNotEmpty ? _searchController.text : null,
              role: _selectedRole,
            ));
          }
        },
        child: BlocBuilder<DistributorUserBloc, DistributorUserState>(
          builder: (context, state) {
            if (state is DistributorUserLoading) {
              return Center(child: CircularProgressIndicator());
            }

            if (state is DistributorUserError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red),
                    SizedBox(height: 16),
                    Text('Error: ${state.message}'),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<DistributorUserBloc>().add(FetchUserListEvent());
                      },
                      child: Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            // Handle DistributorUserCreated state - show loading while refreshing
            if (state is DistributorUserCreated) {
              return Center(child: CircularProgressIndicator());
            }

            if (state is DistributorUserListLoaded) {
              final userList = state.userList;
              return SingleChildScrollView(
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(scrWidth * 0.025),
                              decoration: BoxDecoration(
                                color: colorConst.primaryColor1.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(scrWidth * 0.01),
                              ),
                              child: Icon(
                                Icons.people_outline,
                                color: colorConst.primaryColor1,
                                size: scrWidth * 0.05,
                              ),
                            ),
                            SizedBox(width: scrWidth * 0.03),
                            Text(
                              'User Management',
                              style: TextStyle(
                                fontSize: scrWidth * 0.04,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Search and Filter Section
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: scrWidth * 0.04),
                    child: _buildSearchAndFilters(userList.filters),
                  ),

                  // User List
                  userList.users.isEmpty
                      ? Container(
                          padding: EdgeInsets.all(scrWidth * 0.04),
                          child: Center(
                            child: Text(
                              'No users found',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.all(scrWidth * 0.04),
                          itemCount: userList.users.length,
                          itemBuilder: (context, index) {
                            final user = userList.users[index];
                            return _buildUserCard(user);
                          },
                        ),
                ],
              ),
            );
          }

          return Center(child: CircularProgressIndicator());
        },
      ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<DistributorUserBloc>(),
                child: CreateUserScreen(),
              ),
            ),
          );
        },
        backgroundColor: colorConst.primaryColor1,
        elevation: 4,
        child: Icon(Icons.add, color: Colors.white, size: scrWidth * 0.06),
      ),
    );
  }

  Widget _buildSearchAndFilters(UserListFilters filters) {
    return Container(
      padding: EdgeInsets.all(scrWidth * 0.04),
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
      child: Column(
        children: [
          // Search Field
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search users...',
              prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear, color: Colors.grey[600]),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                        });
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
                borderSide: BorderSide(color: colorConst.primaryColor1, width: 2),
              ),
            ),
            onChanged: (value) {
              setState(() {});
            },
          ),
          SizedBox(height: scrWidth * 0.03),
          // Filter Dropdown
          if (filters.roles.isNotEmpty)
            DropdownButtonFormField<String>(
              value: _selectedRole,
              decoration: InputDecoration(
                labelText: 'Filter by Role',
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
                  borderSide: BorderSide(color: colorConst.primaryColor1, width: 2),
                ),
              ),
              items: filters.roles
                  .map((role) => DropdownMenuItem(
                        value: role.name,
                        child: Text(role.name),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedRole = value;
                });
              },
            ),
          SizedBox(height: scrWidth * 0.03),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                context.read<DistributorUserBloc>().add(
                      FetchUserListEvent(
                        search: _searchController.text.isNotEmpty ? _searchController.text : null,
                        role: _selectedRole,
                      ),
                    );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorConst.primaryColor1,
                padding: EdgeInsets.symmetric(vertical: scrWidth * 0.035),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                'Apply Filters',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: scrWidth * 0.035,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(DistributorUserItem user) {
    return Container(
      margin: EdgeInsets.only(bottom: scrWidth * 0.03),
      padding: EdgeInsets.all(scrWidth * 0.04),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.username,
                      style: TextStyle(
                        fontSize: scrWidth * 0.04,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: scrWidth * 0.01),
                    Text(
                      user.email,
                      style: TextStyle(
                        fontSize: scrWidth * 0.032,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: scrWidth * 0.025,
                  vertical: scrWidth * 0.012,
                ),
                decoration: BoxDecoration(
                  color: user.isActive ? Colors.green.shade50 : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: user.isActive ? Colors.green.shade300 : Colors.red.shade300,
                    width: 1,
                  ),
                ),
                child: Text(
                  user.isActive ? 'Active' : 'Inactive',
                  style: TextStyle(
                    fontSize: scrWidth * 0.028,
                    color: user.isActive ? Colors.green.shade700 : Colors.red.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: scrWidth * 0.02),
          Divider(height: 1, color: Colors.grey.shade200),
          SizedBox(height: scrWidth * 0.02),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoItem('Phone', user.phoneNumber),
              _buildInfoItem('Balance', '₹${user.balance.toStringAsFixed(2)}'),
            ],
          ),
          SizedBox(height: scrWidth * 0.015),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoItem('Role', user.role.name),
              _buildInfoItem('Slab', user.slab.slabName),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: scrWidth * 0.028,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: scrWidth * 0.005),
        Text(
          value,
          style: TextStyle(
            fontSize: scrWidth * 0.032,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

