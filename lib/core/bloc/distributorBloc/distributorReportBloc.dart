import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repository/distributorRepository/distributorRepo.dart';
import 'distributorReportEvent.dart';
import 'distributorReportState.dart';

class DistributorReportBloc extends Bloc<DistributorReportEvent, DistributorReportState> {
  final DistributorRepository repository;

  DistributorReportBloc(this.repository) : super(DistributorReportInitial()) {
    on<FetchUserLedgerEvent>(_onFetchUserLedger);
    on<FetchUserDaybookEvent>(_onFetchUserDaybook);
    on<FetchFundDebitCreditEvent>(_onFetchFundDebitCredit);
    on<FetchDisputeSettlementEvent>(_onFetchDisputeSettlement);
  }

  Future<void> _onFetchUserLedger(
    FetchUserLedgerEvent event,
    Emitter<DistributorReportState> emit,
  ) async {
    emit(DistributorReportLoading());
    try {
      final ledger = await repository.getUserLedger(
        startDate: event.startDate,
        endDate: event.endDate,
        transactionId: event.transactionId,
        limit: event.limit,
      );
      emit(UserLedgerLoaded(ledger));
    } catch (e) {
      emit(DistributorReportError(e.toString()));
    }
  }

  Future<void> _onFetchUserDaybook(
    FetchUserDaybookEvent event,
    Emitter<DistributorReportState> emit,
  ) async {
    emit(DistributorReportLoading());
    try {
      final daybook = await repository.getUserDaybook(
        phoneNumber: event.phoneNumber,
        startDate: event.startDate,
        endDate: event.endDate,
        operator: event.operator,
        limit: event.limit,
      );
      emit(UserDaybookLoaded(daybook));
    } catch (e) {
      emit(DistributorReportError(e.toString()));
    }
  }

  Future<void> _onFetchFundDebitCredit(
    FetchFundDebitCreditEvent event,
    Emitter<DistributorReportState> emit,
  ) async {
    emit(DistributorReportLoading());
    try {
      final report = await repository.getFundDebitCredit(
        walletType: event.walletType,
        type: event.type,
        mobile: event.mobile,
        startDate: event.startDate,
        endDate: event.endDate,
        limit: event.limit,
      );
      emit(FundDebitCreditLoaded(report));
    } catch (e) {
      emit(DistributorReportError(e.toString()));
    }
  }

  Future<void> _onFetchDisputeSettlement(
    FetchDisputeSettlementEvent event,
    Emitter<DistributorReportState> emit,
  ) async {
    emit(DistributorReportLoading());
    try {
      final dispute = await repository.getDisputeSettlement(
        status: event.status,
        startDate: event.startDate,
        endDate: event.endDate,
        limit: event.limit,
      );
      emit(DisputeSettlementLoaded(dispute));
    } catch (e) {
      emit(DistributorReportError(e.toString()));
    }
  }
}

