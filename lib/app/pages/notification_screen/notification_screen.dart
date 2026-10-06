import 'package:agro_app/app/pages/notification_screen/notification_controller.dart';
import 'package:agro_app/app/theme/colors_value.dart';
import 'package:agro_app/app/theme/styles.dart';
import 'package:agro_app/domain/models/notification_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NotificationController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: ColorsValue.bgMain,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0.5,
            centerTitle: false,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.black87,
                size: 20,
              ),
              onPressed: () => Get.back(),
            ),
            title: Row(
              children: [
                Text(
                  'Notifications',
                  style: Styles.txtBlackColorW70020.copyWith(fontSize: 18),
                ),
                if (controller.unreadCount > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: ColorsValue.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${controller.unreadCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              if (controller.notifications.isNotEmpty &&
                  controller.unreadCount > 0)
                TextButton.icon(
                  onPressed: controller.markAllAsRead,
                  icon: const Icon(
                    Icons.done_all_rounded,
                    size: 16,
                    color: ColorsValue.primary,
                  ),
                  label: const Text(
                    'Mark all read',
                    style: TextStyle(
                      color: ColorsValue.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
            ],
          ),
          body: Column(
            children: [
              // ── Search Bar & Filter Section ─────────────────────────────
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Column(
                  children: [
                    // Search Bar
                    TextField(
                      controller: controller.searchController,
                      onChanged: controller.onSearchChanged,
                      decoration: InputDecoration(
                        hintText: 'Search notifications...',
                        hintStyle: Styles.txtGreyColorW40014,
                        prefixIcon: const Icon(
                          Icons.search,
                          color: ColorsValue.primary,
                          size: 22,
                        ),
                        suffixIcon: controller.searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.clear,
                                  size: 18,
                                  color: Colors.grey,
                                ),
                                onPressed: controller.clearSearch,
                              )
                            : null,
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: ColorsValue.primary,
                            width: 1.2,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Filter Row: [All] [Unread] [Read] and [Date Filter]
                    Row(
                      children: [
                        _buildFilterChip(
                          label: 'All',
                          isSelected: controller.isReadFilter == null,
                          onTap: () => controller.filterByReadStatus(null),
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          label: 'Unread',
                          isSelected: controller.isReadFilter == false,
                          onTap: () => controller.filterByReadStatus(false),
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          label: 'Read',
                          isSelected: controller.isReadFilter == true,
                          onTap: () => controller.filterByReadStatus(true),
                        ),
                        const Spacer(),

                        // Start & End Date Range Picker Button
                        InkWell(
                          onTap: () async {
                            final DateTimeRange? picked =
                                await showDateRangePicker(
                              context: context,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2035),
                              initialDateRange: controller.isDateFilterActive
                                  ? DateTimeRange(
                                      start: controller.startDate!,
                                      end: controller.endDate!,
                                    )
                                  : null,
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: ColorScheme.light(
                                      primary: ColorsValue.primary,
                                      onPrimary: Colors.white,
                                      primaryContainer: ColorsValue.primary
                                          .withValues(alpha: 0.18),
                                      onPrimaryContainer: ColorsValue.primary,
                                      surface: Colors.white,
                                      onSurface: Colors.black87,
                                      secondary: ColorsValue.primary,
                                      onSecondary: Colors.white,
                                    ),
                                    datePickerTheme: DatePickerThemeData(
                                      headerBackgroundColor: ColorsValue.primary,
                                      headerForegroundColor: Colors.white,
                                      rangePickerHeaderBackgroundColor:
                                          ColorsValue.primary,
                                      rangePickerHeaderForegroundColor:
                                          Colors.white,
                                      rangeSelectionBackgroundColor:
                                          ColorsValue.primary
                                              .withValues(alpha: 0.18),
                                      rangeSelectionOverlayColor:
                                          WidgetStateProperty.all(
                                        ColorsValue.primary
                                            .withValues(alpha: 0.12),
                                      ),
                                      todayBorder: const BorderSide(
                                        color: ColorsValue.primary,
                                      ),
                                      todayForegroundColor:
                                          WidgetStateProperty.all(
                                        ColorsValue.primary,
                                      ),
                                      dayForegroundColor:
                                          WidgetStateProperty.resolveWith(
                                              (states) {
                                        if (states
                                            .contains(WidgetState.selected)) {
                                          return Colors.white;
                                        }
                                        return Colors.black87;
                                      }),
                                      dayBackgroundColor:
                                          WidgetStateProperty.resolveWith(
                                              (states) {
                                        if (states
                                            .contains(WidgetState.selected)) {
                                          return ColorsValue.primary;
                                        }
                                        return null;
                                      }),
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (picked != null) {
                              controller.setDateRange(picked);
                            }
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: controller.isDateFilterActive
                                  ? ColorsValue.primary
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: controller.isDateFilterActive
                                    ? ColorsValue.primary
                                    : Colors.grey.shade300,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.calendar_today_outlined,
                                  size: 13,
                                  color: controller.isDateFilterActive
                                      ? Colors.white
                                      : Colors.grey.shade700,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  controller.isDateFilterActive
                                      ? controller.formattedDateRange
                                      : 'Date Range',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: controller.isDateFilterActive
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                    color: controller.isDateFilterActive
                                        ? Colors.white
                                        : Colors.grey.shade800,
                                  ),
                                ),
                                if (controller.isDateFilterActive) ...[
                                  const SizedBox(width: 6),
                                  GestureDetector(
                                    onTap: controller.clearDateFilter,
                                    child: const Icon(
                                      Icons.close,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Notifications Content List ──────────────────────────────
              Expanded(
                child: RefreshIndicator(
                  color: ColorsValue.primary,
                  onRefresh: () => controller.fetchNotifications(refresh: true),
                  child: controller.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: ColorsValue.primary,
                          ),
                        )
                      : controller.notifications.isEmpty
                          ? _buildEmptyState(controller)
                          : ListView.separated(
                              controller: controller.scrollController,
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              itemCount: controller.notifications.length +
                                  (controller.isMoreLoading ? 1 : 0),
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                if (index == controller.notifications.length) {
                                  return const Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        color: ColorsValue.primary,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  );
                                }
                                final item = controller.notifications[index];
                                return _buildNotificationCard(
                                  item: item,
                                  onTap: () =>
                                      controller.onNotificationTap(item),
                                  onToggleRead: () =>
                                      controller.toggleReadStatus(item),
                                  onDelete: () => controller
                                      .deleteNotification(item.id ?? ''),
                                );
                              },
                            ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? ColorsValue.primary : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? ColorsValue.primary : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard({
    required NotificationDoc item,
    required VoidCallback onTap,
    required VoidCallback onToggleRead,
    required VoidCallback onDelete,
  }) {
    final bool isUnread = item.isRead != true;
    final iconData = _getTypeIcon(item.type);
    final iconBgColor = _getTypeColor(item.type);

    return Dismissible(
      key: Key(item.id ?? UniqueKey().toString()),
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        decoration: BoxDecoration(
          color: isUnread ? Colors.teal.shade500 : Colors.indigo.shade500,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              isUnread ? Icons.done_all : Icons.mark_email_unread_outlined,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              isUnread ? 'Mark as Read' : 'Mark as Unread',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          onToggleRead();
          return false; // Don't remove the item from list on toggle read
        } else {
          return true; // Dismiss on delete
        }
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          onDelete();
        }
      },
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isUnread ? Colors.white : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isUnread
                  ? ColorsValue.primary.withValues(alpha: 0.35)
                  : Colors.grey.shade200,
              width: isUnread ? 1.2 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isUnread ? 0.04 : 0.015),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: iconBgColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  iconData,
                  color: iconBgColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.title ?? 'Notification',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight:
                                  isUnread ? FontWeight.w700 : FontWeight.w600,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isUnread)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(left: 6, top: 4),
                            decoration: const BoxDecoration(
                              color: ColorsValue.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        // 3-dots popup menu for actions
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: PopupMenuButton<String>(
                            padding: EdgeInsets.zero,
                            icon: Icon(
                              Icons.more_vert,
                              size: 18,
                              color: Colors.grey.shade600,
                            ),
                            onSelected: (value) {
                              if (value == 'toggle_read') {
                                onToggleRead();
                              } else if (value == 'delete') {
                                onDelete();
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'toggle_read',
                                child: Row(
                                  children: [
                                    Icon(
                                      isUnread
                                          ? Icons.mark_email_read_outlined
                                          : Icons.mark_email_unread_outlined,
                                      size: 18,
                                      color: ColorsValue.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      isUnread
                                          ? 'Mark as read'
                                          : 'Mark as unread',
                                      style: Styles.txtBlackColorW50014,
                                    ),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: const [
                                    Icon(
                                      Icons.delete_outline,
                                      size: 18,
                                      color: Colors.red,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Delete',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (item.body != null && item.body!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.body!,
                        style: TextStyle(
                          fontSize: 13,
                          color:
                              isUnread ? Colors.black87 : Colors.grey.shade600,
                          fontWeight:
                              isUnread ? FontWeight.w500 : FontWeight.normal,
                          height: 1.3,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Quick Mark as Read / Mark as Unread text button
                        InkWell(
                          onTap: onToggleRead,
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: isUnread
                                  ? ColorsValue.primary.withValues(alpha: 0.08)
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: isUnread
                                    ? ColorsValue.primary.withValues(alpha: 0.25)
                                    : Colors.grey.shade300,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isUnread
                                      ? Icons.done_rounded
                                      : Icons.mark_email_unread_outlined,
                                  size: 13,
                                  color: isUnread
                                      ? ColorsValue.primary
                                      : Colors.grey.shade700,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isUnread ? 'Mark as read' : 'Mark as unread',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: isUnread
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                    color: isUnread
                                        ? ColorsValue.primary
                                        : Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Text(
                          _formatTimeAgo(item.createdAt),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(NotificationController controller) {
    final bool hasFilter = controller.isReadFilter != null ||
        controller.isDateFilterActive ||
        controller.searchQuery.isNotEmpty;

    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  hasFilter
                      ? Icons.filter_alt_off_outlined
                      : Icons.notifications_off_outlined,
                  size: 56,
                  color: Colors.grey.shade400,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                hasFilter
                    ? 'No Matching Notifications'
                    : 'No Notifications Yet',
                style: Styles.txtBlackColorW70016,
              ),
              const SizedBox(height: 6),
              Text(
                hasFilter
                    ? 'Try clearing or changing your search or date filter.'
                    : 'When you receive updates and alerts, they will appear here.',
                textAlign: TextAlign.center,
                style: Styles.txtGreyColorW40014,
              ),
              if (hasFilter) ...[
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () {
                    controller.clearSearch();
                    controller.filterByReadStatus(null);
                    controller.clearDateFilter();
                  },
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Reset Filters'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ColorsValue.primary,
                    side: const BorderSide(color: ColorsValue.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _getTypeIcon(String? type) {
    switch ((type ?? '').toLowerCase()) {
      case 'task':
        return Icons.assignment_outlined;
      case 'order':
        return Icons.shopping_bag_outlined;
      case 'customerorder':
      case 'customer_order':
        return Icons.list_alt_outlined;
      case 'attendance':
        return Icons.access_time_outlined;
      case 'leave':
        return Icons.beach_access_outlined;
      case 'collection':
        return Icons.account_balance_wallet_outlined;
      case 'expense':
        return Icons.receipt_long_outlined;
      default:
        return Icons.notifications_active_outlined;
    }
  }

  Color _getTypeColor(String? type) {
    switch ((type ?? '').toLowerCase()) {
      case 'task':
        return Colors.teal;
      case 'order':
        return Colors.orange;
      case 'customerorder':
      case 'customer_order':
        return Colors.deepOrange;
      case 'attendance':
        return Colors.blue;
      case 'leave':
        return Colors.purple;
      case 'collection':
        return Colors.deepPurple;
      case 'expense':
        return Colors.redAccent;
      default:
        return ColorsValue.primary;
    }
  }

  String _formatTimeAgo(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final dateTime = DateTime.parse(dateStr).toLocal();
      final difference = DateTime.now().difference(dateTime);

      if (difference.inDays > 7) {
        return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
      } else if (difference.inDays >= 1) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours >= 1) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes >= 1) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (_) {
      return dateStr;
    }
  }
}
