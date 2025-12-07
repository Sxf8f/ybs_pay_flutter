import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/loginService.dart';

final loginServiceProvider = Provider<LoginService>((ref) => LoginService());

final loginStateProvider = StateNotifierProvider<LoginNotifier, AsyncValue<Map<String, dynamic>>>(
      (ref) => LoginNotifier(ref),
);

class LoginNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  final Ref ref;
  LoginNotifier(this.ref) : super(const AsyncValue.data({}));

  Future<void> login(String userID, String password) async {
    state = const AsyncValue.loading();
    try {
      final result = await ref.read(loginServiceProvider).login(
        userID: userID,
        password: password,
      );
      state = AsyncValue.data(result);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
