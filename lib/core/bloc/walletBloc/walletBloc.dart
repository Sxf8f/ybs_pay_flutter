import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repository/walletRepository/walletRepo.dart';
import 'walletEvent.dart';
import 'walletState.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final WalletRepository walletRepository;

  WalletBloc({required this.walletRepository}) : super(WalletInitial()) {
    on<FetchWalletBalance>((event, emit) async {
      emit(WalletLoading());
      try {
        final balance = await walletRepository.getWalletBalance();
        emit(WalletBalanceLoaded(balance: balance));
      } catch (e) {
        emit(WalletError(message: e.toString()));
      }
    });

    on<FetchPaymentMethods>((event, emit) async {
      emit(WalletLoading());
      try {
        final methods = await walletRepository.getPaymentMethods();
        emit(PaymentMethodsLoaded(paymentMethods: methods));
      } catch (e) {
        emit(WalletError(message: e.toString()));
      }
    });

    on<AddMoneyRequested>((event, emit) async {
      print('=== WalletBloc: AddMoneyRequested EVENT RECEIVED ===');
      print('Timestamp: ${DateTime.now()}');
      print('Amount: ${event.amount}');
      print('Operator: ${event.operator}');
      print('Has Secure Key: ${event.secureKey != null && event.secureKey!.isNotEmpty}');
      
      emit(WalletLoading());
      print('Emitted WalletLoading state');
      
      try {
        print('Calling walletRepository.addMoney()...');
        final response = await walletRepository.addMoney(
          event.amount,
          event.operator,
          secureKey: event.secureKey,
        );
        print('=== walletRepository.addMoney() SUCCESS ===');
        print('Response received:');
        print('  - Transaction ID: ${response.transactionId}');
        print('  - Payment URL: ${response.paymentUrl ?? "null"}');
        print('  - Redirect: ${response.redirect}');
        print('  - Success: ${response.success}');
        print('  - Message: ${response.message}');
        
        print('Emitting AddMoneySuccess state...');
        emit(AddMoneySuccess(response: response));
        print('AddMoneySuccess state emitted successfully');
      } catch (e, stackTrace) {
        print('=== WalletBloc: ERROR in AddMoneyRequested ===');
        print('Error: $e');
        print('Error type: ${e.runtimeType}');
        print('Stack trace: $stackTrace');
        print('Emitting WalletError state...');
        emit(WalletError(message: e.toString()));
        print('WalletError state emitted');
      }
    });

    on<CheckPaymentStatus>((event, emit) async {
      emit(WalletLoading());
      try {
        final status = await walletRepository.checkPaymentStatus(event.transactionId);
        emit(PaymentStatusChecked(status: status));
      } catch (e) {
        emit(WalletError(message: e.toString()));
      }
    });

    on<FetchWalletHistory>((event, emit) async {
      emit(WalletLoading());
      try {
        final history = await walletRepository.getWalletHistory(
          status: event.status,
          startDate: event.startDate,
          endDate: event.endDate,
          limit: event.limit,
          search: event.search,
        );
        emit(WalletHistoryLoaded(history: history));
      } catch (e) {
        emit(WalletError(message: e.toString()));
      }
    });

    on<GenerateQRRequested>((event, emit) async {
      emit(WalletLoading());
      try {
        final qrCode = await walletRepository.generateQR();
        emit(QRCodeGenerated(qrCode: qrCode));
      } catch (e) {
        emit(WalletError(message: e.toString()));
      }
    });

    on<ValidateQRRequested>((event, emit) async {
      emit(WalletLoading());
      try {
        final validation = await walletRepository.validateQR(event.qrData);
        emit(QRValidated(validation: validation));
      } catch (e) {
        emit(WalletError(message: e.toString()));
      }
    });

    on<TransferMoneyRequested>((event, emit) async {
      emit(WalletLoading());
      try {
        final response = await walletRepository.transferMoney(
          recipientUserId: event.recipientUserId,
          amount: event.amount,
          remarks: event.remarks,
          qrData: event.qrData,
        );
        emit(TransferMoneySuccess(response: response));
      } catch (e) {
        emit(WalletError(message: e.toString()));
      }
    });

    on<FetchTransferHistory>((event, emit) async {
      emit(WalletLoading());
      try {
        final history = await walletRepository.getTransferHistory(
          type: event.type,
          startDate: event.startDate,
          endDate: event.endDate,
          limit: event.limit,
          offset: event.offset,
        );
        emit(TransferHistoryLoaded(history: history));
      } catch (e) {
        emit(WalletError(message: e.toString()));
      }
    });
  }
}

