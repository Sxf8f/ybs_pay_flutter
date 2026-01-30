import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repository/distributorRepository/distributorRepo.dart';
import 'distributorScanPayEvent.dart';
import 'distributorScanPayState.dart';

class DistributorScanPayBloc
    extends Bloc<DistributorScanPayEvent, DistributorScanPayState> {
  final DistributorRepository repository;

  DistributorScanPayBloc(this.repository) : super(DistributorScanPayInitial()) {
    on<ValidateQREvent>(_onValidateQR);
    on<TransferViaQREvent>(_onTransferViaQR);
  }

  Future<void> _onValidateQR(
    ValidateQREvent event,
    Emitter<DistributorScanPayState> emit,
  ) async {
    emit(DistributorScanPayLoading());
    try {
      final response = await repository.validateQR(event.qrData);
      emit(DistributorScanPayQRValidated(
        validation: response,
        qrData: event.qrData,
      ));
    } catch (e) {
      emit(DistributorScanPayError(e.toString()));
    }
  }

  Future<void> _onTransferViaQR(
    TransferViaQREvent event,
    Emitter<DistributorScanPayState> emit,
  ) async {
    emit(DistributorScanPayTransferLoading());
    try {
      final response = await repository.transferViaQR(
        recipientUserId: event.recipientUserId,
        amount: event.amount,
        qrData: event.qrData,
        remarks: event.remarks,
        secureKey: event.secureKey,
      );

      if (response.requiresSecureKey == true) {
        emit(DistributorScanPayRequiresSecureKey());
      } else if (response.success) {
        emit(DistributorScanPayTransferSuccess(response));
      } else {
        emit(DistributorScanPayError(
          response.error ?? response.message,
        ));
      }
    } catch (e) {
      emit(DistributorScanPayError(e.toString()));
    }
  }
}

