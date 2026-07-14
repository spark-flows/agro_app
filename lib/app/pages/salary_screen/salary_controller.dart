import 'package:agro_app/app/pages/salary_screen/salary_presenter.dart';
import 'package:agro_app/app/utils/utility.dart';
import 'package:agro_app/domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';

class SalaryController extends GetxController {
  SalaryController(this.salaryPresenter);

  final SalaryPresenter salaryPresenter;

  @override
  void onInit() {
    super.onInit();
    filterMonth = DateFormat('MMMM').format(DateTime.now());
    filterYear = DateTime.now().year.toString();
  }

  GlobalKey<FormState> salaryKey = GlobalKey<FormState>();
  TextEditingController dateController = TextEditingController();
  TextEditingController salaryMonthController = TextEditingController();
  TextEditingController workDayController = TextEditingController();
  TextEditingController basicSalaryController = TextEditingController();
  TextEditingController allowanceController = TextEditingController();
  TextEditingController bounsController = TextEditingController();
  TextEditingController deductionController = TextEditingController();
  TextEditingController netSalaryController = TextEditingController();
  TextEditingController remarkController = TextEditingController();

  String? selectUser;
  String? selectPaymentMode;
  String? selectPaymentStatus;

  List<String> paymentMode = ["Cash", "Bank", "UPI", "Cheque"];

  List<String> paymentStatus = ["Pending", "Paid"];

  List<UserData> userDataList = [];

  // ── Search & Filter ──────────────────────────────────────────────────────
  String searchQuery = '';
  String? filterMonth;
  String? filterYear;
  String? filterPaymentStatus;

  bool get isFilterActive =>
      filterMonth != null || filterYear != null || filterPaymentStatus != null;

  void searchSalary(String query) {
    searchQuery = query;
    salaryPagingController.refresh();
    update();
  }

  void applyFilters() {
    salaryPagingController.refresh();
    update();
  }

  void clearFilters() {
    searchQuery = '';
    filterMonth = null;
    filterYear = null;
    filterPaymentStatus = null;
    salaryPagingController.refresh();
    update();
  }

  String editingSalaryId = '';

  void populateSalaryForm(SalaryDoc? salary) {
    if (salary == null) {
      editingSalaryId = '';
      dateController.clear();
      salaryMonthController.clear();
      workDayController.clear();
      basicSalaryController.clear();
      allowanceController.clear();
      bounsController.clear();
      deductionController.clear();
      netSalaryController.clear();
      remarkController.clear();
      selectUser = null;
      selectPaymentMode = null;
      selectPaymentStatus = null;
    } else {
      editingSalaryId = salary.id ?? '';

      if (salary.date != null && salary.date!.isNotEmpty) {
        try {
          final parsed = DateTime.parse(salary.date!);
          dateController.text = DateFormat('dd/MM/yyyy').format(parsed);
        } catch (_) {
          try {
            final parsed = DateFormat('yyyy-MM-dd').parse(salary.date!);
            dateController.text = DateFormat('dd/MM/yyyy').format(parsed);
          } catch (_) {
            dateController.text = salary.date!;
          }
        }
      } else {
        dateController.clear();
      }

      if (salary.month != null && salary.month!.isNotEmpty) {
        String mStr = salary.month!;
        String yStr = salary.year ?? '';
        salaryMonthController.text = yStr.isNotEmpty ? '$mStr, $yStr' : mStr;
      } else {
        salaryMonthController.clear();
      }

      workDayController.text = salary.workdays?.toString() ?? '';
      basicSalaryController.text = salary.basicsalary?.toString() ?? '';
      bounsController.text = salary.bonus?.toString() ?? '';
      deductionController.text = salary.deduction?.toString() ?? '';
      netSalaryController.text = salary.netsalary?.toString() ?? '';
      remarkController.text = salary.remark ?? '';
      selectUser = salary.userid?.id;
      selectPaymentMode = salary.paymentmode;
      selectPaymentStatus = salary.paymentstatus != null
          ? (salary.paymentstatus![0].toUpperCase() +
                salary.paymentstatus!.substring(1).toLowerCase())
          : null;
    }
    update();
  }

  /// Clears the salary form fields before navigating to AddSalaryScreen
  void clearSalaryForm() {
    populateSalaryForm(null);
  }

  Future<void> getUserList() async {
    var response = await Get.find<Repository>().getUsersListApi(
      page: 1,
      limit: 1000,
      type: 'user',
      isLoading: true,
    );
    userDataList.clear();
    if (response?.data != null) {
      userDataList = response!.data.docs
          .map(
            (doc) => UserData(
              id: doc.id,
              name: doc.name,
              surname: doc.surname,
              fathername: doc.fathername,
              email: doc.email,
              mobile: doc.mobile,
            ),
          )
          .toList();
      update();
    }
  }

  Future<void> deleteSalaryApi({required String salaryid}) async {
    var response = await salaryPresenter.deleteSalaryApi(
      isLoading: true,
      salaryid: salaryid,
    );
    if (response?.statusCode == 200) {
      salaryPagingController.refresh();
      update();
    }
  }

  PagingController<int, SalaryDoc> salaryPagingController = PagingController(
    firstPageKey: 1,
  );

  List<SalaryDoc> salaryDocList = [];

  Future<void> postSalaryListApi(int pageKey) async {
    final savedBranchId = await Get.find<Repository>().getSecureValue(
      LocalKeys.selectedBranchId,
    );
    var response = await salaryPresenter.postSalaryListApi(
      page: pageKey,
      limit: 10,
      month: filterMonth ?? "",
      year: filterYear ?? "",
      branchId: savedBranchId,
      isLoading: true,
    );
    if (response?.data != null) {
      if (pageKey == 1) {
        salaryDocList.clear();
        salaryPagingController.itemList?.clear();
      }
      salaryDocList = response?.data?.docs ?? [];

      // ── Client-side search filter ──
      if (searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        salaryDocList = salaryDocList.where((s) {
          final name = (s.userid?.name ?? '').toLowerCase();
          final remark = (s.remark ?? '').toLowerCase();
          final mode = (s.paymentmode ?? '').toLowerCase();
          return name.contains(q) || remark.contains(q) || mode.contains(q);
        }).toList();
      }

      // ── Client-side payment status filter ──
      if (filterPaymentStatus != null) {
        salaryDocList = salaryDocList.where((s) {
          return (s.paymentstatus ?? '').toLowerCase() ==
              filterPaymentStatus!.toLowerCase();
        }).toList();
      }

      final isLastPage = salaryDocList.length < 10;
      if (isLastPage) {
        salaryPagingController.appendLastPage(salaryDocList);
      } else {
        var nextPageKey = pageKey + 1;
        salaryPagingController.appendPage(salaryDocList, nextPageKey);
      }
      update();
    }
  }

  List<GetSalaryData> getSalaryList = [];
  int workingHours = 0;

  void calculateNetSalary() {
    double basic = double.tryParse(basicSalaryController.text) ?? 0.0;
    double workDays = double.tryParse(workDayController.text) ?? 0.0;
    double bonus = double.tryParse(bounsController.text) ?? 0.0;
    double deduction = double.tryParse(deductionController.text) ?? 0.0;

    if (workDays > 0) {
      double ans = basic / workDays / 8;
      double calculatedSalary = ans * workingHours;
      double netSalary = calculatedSalary + bonus - deduction;
      netSalaryController.text = netSalary.round().toString();
    } else {
      netSalaryController.text = "0";
    }
    update();
  }

  Future<void> getSalaryApi(int pageKey) async {
    String targetMonth = DateTime.now().month.toString();
    String targetYear = DateTime.now().year.toString();
    if (salaryMonthController.text.isNotEmpty) {
      try {
        final parsed = DateFormat(
          'MMMM, yyyy',
        ).parse(salaryMonthController.text);
        targetMonth = parsed.month.toString();
        targetYear = parsed.year.toString();
      } catch (_) {}
    }

    var response = await salaryPresenter.getSalaryApi(
      userid: selectUser,
      month: targetMonth,
      year: targetYear,
      workdays: workDayController.text.trim(),
      isLoading: true,
    );
    getSalaryList.clear();
    if (response?.data != null) {
      basicSalaryController.text =
          response?.data?.basicsalary?.toString() ?? "0";
      if (response?.data?.presentdays != null &&
          response?.data?.presentdays != 0) {
        workDayController.text = response!.data!.presentdays!.toString();
      } else if (workDayController.text.trim().isEmpty) {
        workDayController.text = "0";
      }
      workingHours = response?.data?.workinghours ?? 0;
      calculateNetSalary();
      update();
    }
  }

  Future<void> postCreateSalaryApi() async {
    final savedBranchId = await Get.find<Repository>().getSecureValue(
      LocalKeys.selectedBranchId,
    );
    var response = await salaryPresenter.postCreateSalaryApi(
      salaryid: editingSalaryId.isNotEmpty ? editingSalaryId : "",
      date: dateController.text.isNotEmpty
          ? Utility.convertddMMYYYTOYYYYMMDD(dateController.text)
          : DateFormat("yyyy-MM-dd").format(DateTime.now()),
      userid: selectUser,
      branchid: savedBranchId,
      month: Utility.formatDateTime(salaryMonthController.text, 'MMMM'),
      year: Utility.formatDateTime(salaryMonthController.text, 'yyyy'),
      workdays: workDayController.text.isEmpty
          ? 0
          : int.parse(workDayController.text),
      basicsalary: basicSalaryController.text.isEmpty
          ? 0
          : int.parse(basicSalaryController.text),
      bonus: bounsController.text.isEmpty ? 0 : int.parse(bounsController.text),
      allowance: 0,
      deduction: deductionController.text.isEmpty
          ? 0
          : int.parse(deductionController.text),
      netsalary: netSalaryController.text.isEmpty
          ? 0
          : int.parse(netSalaryController.text),
      paymentmode: selectPaymentMode ?? "",
      paymentstatus: selectPaymentStatus ?? "",
      transactionid: "",
      remark: remarkController.text,
      isLoading: true,
    );
    if (response?.statusCode == 200) {
      Get.back();
      salaryPagingController.refresh();
      update();
    }
  }
}
