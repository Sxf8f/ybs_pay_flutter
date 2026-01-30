import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repository/distributorRepository/distributorRepo.dart';
import '../../models/distributorModels/distributorUserModel.dart';
import '../../models/distributorModels/distributorFundTransferModel.dart';
import 'distributorFundTransferEvent.dart';
import 'distributorFundTransferState.dart';

class DistributorFundTransferBloc
    extends Bloc<DistributorFundTransferEvent, DistributorFundTransferState> {
  final DistributorRepository repository;

  DistributorFundTransferBloc(this.repository)
      : super(DistributorFundTransferInitial()) {
    on<FetchAllUsersForTransferEvent>(_onFetchAllUsers);
    on<SearchUsersForTransferEvent>(_onSearchUsers);
    on<FundTransferEvent>(_onFundTransfer);
  }

  Future<void> _onFetchAllUsers(
    FetchAllUsersForTransferEvent event,
    Emitter<DistributorFundTransferState> emit,
  ) async {
    emit(DistributorFundTransferAllUsersLoading());
    try {
      final userListResponse = await repository.getUserList(
        page: event.page ?? 1,
        limit: event.limit ?? 100,
      );
      // Convert DistributorUserItem to FundTransferUser
      final fundTransferUsers = userListResponse.users
          .where((user) => user.isActive) // Only show active users
          .map((user) => FundTransferUser(
                id: user.id,
                username: user.username,
                name: user.outlet ?? user.username,
                phone: user.phoneNumber,
                email: user.email,
                role: user.role.name,
                balance: user.balance.toStringAsFixed(2),
              ))
          .toList();
      emit(DistributorFundTransferAllUsersLoaded(fundTransferUsers));
    } catch (e) {
      emit(DistributorFundTransferError(e.toString()));
    }
  }

  Future<void> _onSearchUsers(
    SearchUsersForTransferEvent event,
    Emitter<DistributorFundTransferState> emit,
  ) async {
    emit(DistributorFundTransferSearchLoading());
    try {
      final response = await repository.searchUsersForTransfer(
        search: event.search,
        limit: event.limit,
      );
      emit(DistributorFundTransferSearchLoaded(response.users));
    } catch (e) {
      emit(DistributorFundTransferError(e.toString()));
    }
  }

  Future<void> _onFundTransfer(
    FundTransferEvent event,
    Emitter<DistributorFundTransferState> emit,
  ) async {
    emit(DistributorFundTransferLoading());
    try {
      final response = await repository.fundTransfer(
        receiverId: event.receiverId,
        amount: event.amount,
        remark: event.remark,
        secureKey: event.secureKey,
      );
      
      print('🔄 [Fund Transfer BLoC] Response received:');
      print('   Success: ${response.success}');
      print('   Requires Secure Key: ${response.requiresSecureKey}');
      print('   Error: ${response.error}');
      print('   Message: ${response.message}');
      
      // Check if secure key is required
      if (response.requiresSecureKey == true && !response.success) {
        print('🔐 [Fund Transfer BLoC] Secure key required');
        emit(DistributorFundTransferRequiresSecureKey(
          errorMessage: response.error ?? response.message,
        ));
      } 
      // Check if transfer was successful
      else if (response.success) {
        print('✅ [Fund Transfer BLoC] Transfer successful');
        emit(DistributorFundTransferSuccess(response));
      } 
      // Handle error cases
      else {
        // Build detailed error message
        String errorMessage = response.error ?? response.message;
        
        // Add balance information if available
        if (response.currentBalance != null && response.requiredAmount != null) {
          errorMessage = '${errorMessage}\n\nCurrent Balance: ₹${response.currentBalance}\nRequired Amount: ₹${response.requiredAmount}';
        } else if (response.currentBalance != null) {
          errorMessage = '${errorMessage}\n\nCurrent Balance: ₹${response.currentBalance}';
        }
        
        print('❌ [Fund Transfer BLoC] Transfer failed: $errorMessage');
        emit(DistributorFundTransferError(errorMessage));
      }
    } catch (e) {
      print('❌ [Fund Transfer BLoC] Exception: $e');
      emit(DistributorFundTransferError(e.toString()));
    }
  }
}

