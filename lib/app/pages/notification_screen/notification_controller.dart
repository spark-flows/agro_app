import 'package:agro_app/app/navigators/routes_management.dart';
import 'package:agro_app/app/pages/home_screen/home_controller.dart';
import 'package:agro_app/app/utils/utility.dart';
import 'package:agro_app/domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class NotificationController extends GetxController {
  final Repository _repository = Get.find<Repository>();

  List<NotificationDoc> notifications = [];
  bool isLoading = false;
  bool isMoreLoading = false;
  int currentPage = 1;
  int totalPages = 1;
  int unreadCount = 0;

  String searchQuery = '';
  bool? isReadFilter; // null = All, false = Unread, true = Read
  DateTime? startDate;
  DateTime? endDate;

  final TextEditingController searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  bool get isDateFilterActive => startDate != null && endDate != null;

  String get formattedDateRange {
    if (startDate == null || endDate == null) return 'All Dates';
    final now = DateTime.now();
    final isToday = startDate!.year == now.year &&
        startDate!.month == now.month &&
        startDate!.day == now.day &&
        endDate!.year == now.year &&
        endDate!.month == now.month &&
        endDate!.day == now.day;
    if (isToday) return 'Today';

    final isSameDay = startDate!.year == endDate!.year &&
        startDate!.month == endDate!.month &&
        startDate!.day == endDate!.day;
    if (isSameDay) {
      return DateFormat('dd MMM').format(startDate!);
    }

    final DateFormat formatter = DateFormat('dd MMM');
    if (startDate!.year != endDate!.year) {
      return '${DateFormat('dd MMM yy').format(startDate!)} - ${DateFormat('dd MMM yy').format(endDate!)}';
    }
    return '${formatter.format(startDate!)} - ${formatter.format(endDate!)}';
  }

  @override
  void onInit() {
    super.onInit();
    final now = DateTime.now();
    startDate = DateTime(now.year, now.month, now.day);
    endDate = DateTime(now.year, now.month, now.day);
    scrollController.addListener(_onScroll);
    fetchNotifications(refresh: true);
  }

  @override
  void onClose() {
    scrollController.dispose();
    searchController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      if (!isMoreLoading && !isLoading && currentPage < totalPages) {
        fetchNotifications(loadMore: true);
      }
    }
  }

  Future<void> fetchNotifications({
    bool refresh = false,
    bool loadMore = false,
  }) async {
    if (refresh) {
      currentPage = 1;
      isLoading = true;
      update();
    } else if (loadMore) {
      currentPage++;
      isMoreLoading = true;
      update();
    }

    try {
      final String startStr = startDate != null
          ? DateFormat('yyyy-MM-dd').format(startDate!)
          : '';
      final String endStr = endDate != null
          ? DateFormat('yyyy-MM-dd').format(endDate!)
          : '';

      final response = await _repository.getNotificationListApi(
        page: currentPage,
        limit: 20,
        search: searchQuery,
        isRead: isReadFilter,
        type: '',
        startDate: startStr,
        endDate: endStr,
        isLoading: false,
      );

      if (response != null && response.data != null) {
        final docs = response.data!.docs ?? [];
        totalPages = response.data!.totalPages ?? 1;
        unreadCount = response.data!.unreadCount ?? 0;

        if (refresh) {
          notifications = docs;
        } else {
          notifications.addAll(docs);
        }

        _syncUnreadCountWithHome(unreadCount);
      }
    } catch (e) {
      // Handled in repository
    } finally {
      isLoading = false;
      isMoreLoading = false;
      update();
    }
  }

  void onSearchChanged(String value) {
    searchQuery = value.trim();
    fetchNotifications(refresh: true);
  }

  void clearSearch() {
    searchController.clear();
    searchQuery = '';
    fetchNotifications(refresh: true);
  }

  void filterByReadStatus(bool? isRead) {
    isReadFilter = isRead;
    fetchNotifications(refresh: true);
  }

  void setDateRange(DateTimeRange? pickedRange) {
    if (pickedRange != null) {
      startDate = pickedRange.start;
      endDate = pickedRange.end;
      fetchNotifications(refresh: true);
    }
  }

  void clearDateFilter() {
    startDate = null;
    endDate = null;
    fetchNotifications(refresh: true);
  }

  Future<void> markAsRead(NotificationDoc doc) async {
    if (doc.id == null || doc.isRead == true) return;

    // Optimistic update
    doc.isRead = true;
    if (unreadCount > 0) unreadCount--;
    _syncUnreadCountWithHome(unreadCount);
    update();

    final success = await _repository.markNotificationReadApi(
      notificationId: doc.id,
      isRead: true,
      isLoading: false,
    );

    if (!success) {
      doc.isRead = false;
      unreadCount++;
      _syncUnreadCountWithHome(unreadCount);
      update();
    }
  }

  Future<void> markAsUnread(NotificationDoc doc) async {
    if (doc.id == null || doc.isRead == false) return;

    // Optimistic update
    doc.isRead = false;
    unreadCount++;
    _syncUnreadCountWithHome(unreadCount);
    update();

    final success = await _repository.markNotificationReadApi(
      notificationId: doc.id,
      isRead: false,
      isLoading: false,
    );

    if (!success) {
      doc.isRead = true;
      if (unreadCount > 0) unreadCount--;
      _syncUnreadCountWithHome(unreadCount);
      update();
    }
  }

  Future<void> toggleReadStatus(NotificationDoc doc) async {
    if (doc.isRead == true) {
      await markAsUnread(doc);
    } else {
      await markAsRead(doc);
    }
  }

  Future<void> markAllAsRead() async {
    if (unreadCount == 0 && notifications.every((n) => n.isRead == true)) {
      return;
    }

    // Optimistic update
    for (var doc in notifications) {
      doc.isRead = true;
    }
    final previousCount = unreadCount;
    unreadCount = 0;
    _syncUnreadCountWithHome(0);
    update();

    final success = await _repository.markNotificationReadApi(
      markAll: true,
      isLoading: true,
    );

    if (success) {
      Utility.showMessage('All notifications marked as read', MessageType.success, null, '');
    } else {
      unreadCount = previousCount;
      _syncUnreadCountWithHome(previousCount);
      update();
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    final index = notifications.indexWhere((n) => n.id == notificationId);
    if (index == -1) return;

    final removedDoc = notifications[index];
    notifications.removeAt(index);
    if (removedDoc.isRead != true && unreadCount > 0) {
      unreadCount--;
      _syncUnreadCountWithHome(unreadCount);
    }
    update();

    final success = await _repository.deleteNotificationApi(
      notificationId: notificationId,
      isLoading: false,
    );

    if (!success) {
      notifications.insert(index, removedDoc);
      if (removedDoc.isRead != true) {
        unreadCount++;
        _syncUnreadCountWithHome(unreadCount);
      }
      update();
    }
  }

  void onNotificationTap(NotificationDoc doc) {
    if (doc.isRead != true) {
      markAsRead(doc);
    }

    final type = (doc.type ?? '').toLowerCase();
    switch (type) {
      case 'task':
        RouteManagement.goToTasksScreen();
        break;
      case 'order':
        RouteManagement.goToOrdersScreen();
        break;
      case 'customerorder':
      case 'customer_order':
        RouteManagement.goToCustomerOrdersScreen();
        break;
      case 'attendance':
        RouteManagement.goToAttendanceScreen();
        break;
      case 'leave':
        RouteManagement.goToLeaveScreen();
        break;
      case 'collection':
        RouteManagement.goToCollectionScreen();
        break;
      case 'expense':
        RouteManagement.goToExpenseScreen();
        break;
      default:
        break;
    }
  }

  void _syncUnreadCountWithHome(int count) {
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().setUnreadNotificationCount(count);
    }
  }
}
