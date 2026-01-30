import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repository/userRepository/userRepo.dart';
import '../../models/userModels/userDetailsModel.dart';
import 'userEvent.dart';
import 'userState.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository repository;

  UserBloc(this.repository) : super(UserInitial()) {
    on<FetchUserDetailsEvent>(_onFetchUserDetails);
    on<RefreshBalanceOnlyEvent>(_onRefreshBalanceOnly);
  }

  Future<void> _onFetchUserDetails(
    FetchUserDetailsEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());
    try {
      final user = await repository.fetchUserDetails();
      emit(UserLoaded(user));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> _onRefreshBalanceOnly(
    RefreshBalanceOnlyEvent event,
    Emitter<UserState> emit,
  ) async {
    final currentState = state;
    // Only refresh if we have a loaded user state
    if (currentState is UserLoaded) {
      try {
        // Fetch new user details
        final updatedUser = await repository.fetchUserDetails();
        // Preserve profile picture from current state if new one is null/empty
        // This prevents the flash of default profile icon
        final preservedProfilePicture = (updatedUser.profilePictureUrl != null && 
                                         updatedUser.profilePictureUrl!.isNotEmpty)
                                         ? updatedUser.profilePictureUrl
                                         : currentState.user.profilePictureUrl;
        
        // Create updated user with preserved profile picture
        final preservedUser = UserDetails(
          id: updatedUser.id,
          username: updatedUser.username,
          email: updatedUser.email,
          firstName: updatedUser.firstName,
          lastName: updatedUser.lastName,
          phoneNumber: updatedUser.phoneNumber,
          pincode: updatedUser.pincode,
          address: updatedUser.address,
          outlet: updatedUser.outlet,
          balance: updatedUser.balance, // Updated balance
          roleName: updatedUser.roleName,
          roleCode: updatedUser.roleCode,
          roleId: updatedUser.roleId,
          slabName: updatedUser.slabName,
          slabId: updatedUser.slabId,
          isGst: updatedUser.isGst,
          commissionRate: updatedUser.commissionRate,
          loginId: updatedUser.loginId,
          createdAt: updatedUser.createdAt,
          updatedAt: updatedUser.updatedAt,
          forcePasswordChange: updatedUser.forcePasswordChange,
          liveid: updatedUser.liveid,
          profilePictureUrl: preservedProfilePicture, // Preserved profile picture
        );
        emit(UserLoaded(preservedUser));
        print('✅ [UserBloc] Balance refreshed, profile picture preserved');
      } catch (e) {
        // On error, keep current state (don't emit error to avoid flashing)
        print('⚠️ [UserBloc] Error refreshing balance: $e');
      }
    } else {
      // If no user loaded, do a full fetch
      await _onFetchUserDetails(FetchUserDetailsEvent(), emit);
    }
  }
}
