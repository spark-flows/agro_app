import 'package:agro_app/domain/domain.dart';

class SalaryUsecases {
  SalaryUsecases(this.repository);

  final Repository repository;

  Future<ResponseModel?> postCreateSalaryApi({
    required String? salaryid,
    required String? date,
    required String? userid,
    required String? branchid,
    required String? month,
    required String? year,
    required int? workdays,
    required int? basicsalary,
    required int? bonus,
    required int? allowance,
    required int? deduction,
    required int? netsalary,
    required String? paymentmode,
    required String? paymentstatus,
    required String? transactionid,
    required String? remark,
    bool isLoading = false,
  }) async => await repository.postCreateSalaryApi(
    salaryid: salaryid,
    date: date,
    userid: userid,
    branchid: branchid,
    month: month,
    year: year,
    workdays: workdays,
    basicsalary: basicsalary,
    bonus: bonus,
    allowance: allowance,
    deduction: deduction,
    netsalary: netsalary,
    paymentmode: paymentmode,
    paymentstatus: paymentstatus,
    transactionid: transactionid,
    remark: remark,
    isLoading: isLoading,
  );

  Future<SalaryModel?> postSalaryListApi({
    required int page,
    required int limit,
    required String month,
    required String year,
    required String branchId,
    bool isLoading = false,
  }) async => await repository.postSalaryListApi(
    page: page,
    limit: limit,
    month: month,
    year: year,
    branchId: branchId,
    isLoading: isLoading,
  );

  Future<GetSalaryModel?> getSalaryApi({
    bool isLoading = false,
    required String? userid,
    required String? month,
    required String? year,
    String? workdays,
  }) async => await repository.getSalaryApi(
    userid: userid,
    month: month,
    year: year,
    workdays: workdays,
    isLoading: isLoading,
  );

  Future<UserModel?> getUserList({bool isLoading = false}) async =>
      await repository.getUserList(isLoading: isLoading);

  Future<ResponseModel?> deleteSalaryApi({
    bool isLoading = false,
    required String? salaryid,
  }) async => await repository.deleteSalaryApi(
    salaryid: salaryid,
    isLoading: isLoading,
  );
}
