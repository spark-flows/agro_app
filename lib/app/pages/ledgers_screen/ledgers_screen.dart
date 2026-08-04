import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agro_app/app/app.dart';

class LedgersScreen extends StatefulWidget {
  const LedgersScreen({super.key});

  @override
  State<LedgersScreen> createState() => _LedgersScreenState();
}

class _LedgersScreenState extends State<LedgersScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      Get.find<LedgersController>().fetchLedgers(isRefresh: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LedgersController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: ColorsValue.bgMain,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black87),
              onPressed: () => Get.back(),
            ),
            title: Text('Ledgers', style: Styles.txtBlackColorW70020),
          ),
          body: Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextField(
                  onChanged: controller.onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search ledgers...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 0,
                      horizontal: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                ),
              ),

              // List View
              Expanded(
                child: controller.isLoading && controller.ledgers.isEmpty
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: ColorsValue.primary,
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () =>
                            controller.fetchLedgers(isRefresh: true),
                        child: _buildList(controller),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildList(LedgersController controller) {
    if (controller.ledgers.isEmpty) {
      return const Center(
        child: Text(
          'No ledgers found.',
          style: TextStyle(color: ColorsValue.textMuted),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(12),
      itemCount:
          controller.ledgers.length + (controller.isFetchingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == controller.ledgers.length) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: CircularProgressIndicator(color: ColorsValue.primary),
            ),
          );
        }

        final item = controller.ledgers[index];
        final parentText = item.parent != null
            ? (item.parent is Map
                  ? (item.parent['name'] ??
                        item.parent['particularname'] ??
                        item.parent.toString())
                  : item.parent.toString())
            : 'General';

        final closing =
            double.tryParse(item.closingbalance?.toString() ?? '0') ?? 0.0;
        final opening =
            double.tryParse(item.openingbalance?.toString() ?? '0') ?? 0.0;

        return Card(
          elevation: 1,
          margin: const EdgeInsets.symmetric(vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              RouteManagement.goToLedgerStatementScreen(
                item.id ?? '',
                item.name ?? 'Unknown Ledger'
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: ColorsValue.primary.withValues(alpha: 0.1),
                    child: const Icon(
                      Icons.account_balance_wallet,
                      color: ColorsValue.primary,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name ?? '',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: ColorsValue.textH1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Parent: $parentText',
                          style: const TextStyle(
                            fontSize: 12,
                            color: ColorsValue.textBody,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              'Opening: ₹${opening.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: ColorsValue.textMuted,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Closing: ₹${closing.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: closing >= 0
                                    ? ColorsValue.statusCancelled
                                    : ColorsValue.statusComplete,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
