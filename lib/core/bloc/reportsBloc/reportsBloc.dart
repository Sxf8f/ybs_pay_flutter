import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repository/reportsRepository/reportsRepo.dart';
import 'reportsEvent.dart';
import 'reportsState.dart';

class ReportsBloc extends Bloc<ReportsEvent, ReportsState> {
  final ReportsRepository repository;

  ReportsBloc({required this.repository}) : super(ReportsInitial()) {
    // Recharge Report
    on<FetchRechargeReport>((event, emit) async {
      emit(ReportsLoading());
      try {
        final response = await repository.getRechargeReport(
          operatorType: event.operatorType,
          operator: event.operator,
          status: event.status,
          criteria: event.criteria,
          search: event.search,
          startDate: event.startDate,
          endDate: event.endDate,
          limit: event.limit,
          usePost: event.usePost,
        );
        emit(RechargeReportLoaded(response: response));
      } catch (e) {
        emit(ReportsError(message: e.toString()));
      }
    });

    // Ledger Report
    on<FetchLedgerReport>((event, emit) async {
      emit(ReportsLoading());
      try {
        final response = await repository.getLedgerReport(
          startDate: event.startDate,
          endDate: event.endDate,
          transactionId: event.transactionId,
          limit: event.limit,
          usePost: event.usePost,
        );
        emit(LedgerReportLoaded(response: response));
      } catch (e) {
        emit(ReportsError(message: e.toString()));
      }
    });

    // Fund Order Report
    on<FetchFundOrderReport>((event, emit) async {
      emit(ReportsLoading());
      try {
        final response = await repository.getFundOrderReport(
          status: event.status,
          transferMode: event.transferMode,
          criteria: event.criteria,
          search: event.search,
          fromDate: event.fromDate,
          toDate: event.toDate,
          limit: event.limit,
          usePost: event.usePost,
        );
        emit(FundOrderReportLoaded(response: response));
      } catch (e) {
        emit(ReportsError(message: e.toString()));
      }
    });

    // Complaint Report
    on<FetchComplaintReport>((event, emit) async {
      emit(ReportsLoading());
      try {
        final response = await repository.getComplaintReport(
          refundStatus: event.refundStatus,
          operator: event.operator,
          status: event.status,
          api: event.api,
          search: event.search,
          startDate: event.startDate,
          endDate: event.endDate,
          limit: event.limit,
          usePost: event.usePost,
        );
        emit(ComplaintReportLoaded(response: response));
      } catch (e) {
        emit(ReportsError(message: e.toString()));
      }
    });

    // Fund Debit Credit Report
    on<FetchFundDebitCreditReport>((event, emit) async {
      emit(ReportsLoading());
      try {
        final response = await repository.getFundDebitCreditReport(
          walletType: event.walletType,
          isSelf: event.isSelf,
          receivedBy: event.receivedBy,
          type: event.type,
          mobile: event.mobile,
          startDate: event.startDate,
          endDate: event.endDate,
          limit: event.limit,
          usePost: event.usePost,
        );
        emit(FundDebitCreditReportLoaded(response: response));
      } catch (e) {
        emit(ReportsError(message: e.toString()));
      }
    });

    // User Daybook Report
    on<FetchUserDaybookReport>((event, emit) async {
      emit(ReportsLoading());
      try {
        final response = await repository.getUserDaybookReport(
          phoneNumber: event.phoneNumber,
          startDate: event.startDate,
          endDate: event.endDate,
          operator: event.operator,
          isDmt: event.isDmt,
          limit: event.limit,
          usePost: event.usePost,
        );
        emit(UserDaybookReportLoaded(response: response));
      } catch (e) {
        emit(ReportsError(message: e.toString()));
      }
    });

    // Commission Slab Report
    on<FetchCommissionSlabReport>((event, emit) async {
      emit(ReportsLoading());
      try {
        final response = await repository.getCommissionSlabReport(
          commissionId: event.commissionId,
          operatorId: event.operatorId,
          operatorType: event.operatorType,
          search: event.search,
          limit: event.limit,
          usePost: event.usePost,
        );
        emit(CommissionSlabReportLoaded(response: response));
      } catch (e) {
        emit(ReportsError(message: e.toString()));
      }
    });

    // W2R Report
    on<FetchW2RReport>((event, emit) async {
      emit(ReportsLoading());
      try {
        final response = await repository.getW2RReport(
          status: event.status,
          transactionId: event.transactionId,
          startDate: event.startDate,
          endDate: event.endDate,
          limit: event.limit,
          usePost: event.usePost,
        );
        emit(W2RReportLoaded(response: response));
      } catch (e) {
        emit(ReportsError(message: e.toString()));
      }
    });

    // Daybook DMT Report
    on<FetchDaybookDMTReport>((event, emit) async {
      emit(ReportsLoading());
      try {
        final response = await repository.getDaybookDMTReport(
          phoneNumber: event.phoneNumber,
          startDate: event.startDate,
          endDate: event.endDate,
          operator: event.operator,
          limit: event.limit,
          usePost: event.usePost,
        );
        emit(DaybookDMTReportLoaded(response: response));
      } catch (e) {
        emit(ReportsError(message: e.toString()));
      }
    });
  }
}

