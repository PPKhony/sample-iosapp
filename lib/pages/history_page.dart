import 'package:flutter/cupertino.dart';
import '../theme/colors.dart';
import '../providers/app_state.dart';
import '../models/transaction.dart';

class HistoryPage extends StatefulWidget {
  final AppState state;

  const HistoryPage({
    super.key,
    required this.state,
  });

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  int _selectedFilterIndex = 0; // 0: All, 1: Expenses, 2: Income

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final compareDate = DateTime(date.year, date.month, date.day);

    if (compareDate == today) {
      return 'วันนี้ (Today)';
    } else if (compareDate == yesterday) {
      return 'เมื่อวานนี้ (Yesterday)';
    }

    final List<String> thaiMonths = [
      'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.',
      'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.'
    ];

    return '${date.day} ${thaiMonths[date.month - 1]} ${date.year}';
  }

  String _formatCurrency(double amount) {
    return '฿${amount.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        )}';
  }

  @override
  Widget build(BuildContext context) {
    // 1. Filter transactions based on selection
    final List<Transaction> allTx = widget.state.transactions;
    List<Transaction> filteredTx = [];
    if (_selectedFilterIndex == 0) {
      filteredTx = allTx;
    } else if (_selectedFilterIndex == 1) {
      filteredTx = allTx.where((tx) => tx.isExpense).toList();
    } else {
      filteredTx = allTx.where((tx) => !tx.isExpense).toList();
    }

    // 2. Group filtered transactions by date
    final Map<DateTime, List<Transaction>> groupedGroups = {};
    for (var tx in filteredTx) {
      final dateOnly = DateTime(tx.date.year, tx.date.month, tx.date.day);
      if (!groupedGroups.containsKey(dateOnly)) {
        groupedGroups[dateOnly] = [];
      }
      groupedGroups[dateOnly]!.add(tx);
    }

    // Sort dates descending
    final sortedKeys = groupedGroups.keys.toList()..sort((a, b) => b.compareTo(a));

    return CupertinoPageScaffold(
      backgroundColor: AppColors.background(context),
      child: CustomScrollView(
        slivers: [
          const CupertinoSliverNavigationBar(
            largeTitle: Text('ประวัติ'),
            border: null,
          ),
          // Filter segmented control
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: SizedBox(
                width: double.infinity,
                child: CupertinoSegmentedControl<int>(
                  groupValue: _selectedFilterIndex,
                  children: const {
                    0: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text('ทั้งหมด', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                    1: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text('รายจ่าย', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                    2: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text('รายรับ', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  },
                  onValueChanged: (int val) {
                    setState(() {
                      _selectedFilterIndex = val;
                    });
                  },
                ),
              ),
            ),
          ),
          if (sortedKeys.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.square_list,
                      size: 64,
                      color: AppColors.secondaryLabel(context).withOpacity(0.5),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'ไม่มีรายการในช่วงนี้',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.secondaryLabel(context),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final dateKey = sortedKeys[index];
                  final dayTx = groupedGroups[dateKey]!;

                  return CupertinoListSection.insetGrouped(
                    header: Text(
                      _formatDateHeader(dateKey),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondaryLabel(context),
                      ),
                    ),
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    children: dayTx.map((tx) {
                      final categoryDetails = TransactionCategory.fromString(tx.category);
                      final amtPrefix = tx.isExpense ? '-' : '+';
                      final amtColor = tx.isExpense ? AppColors.expense : AppColors.success;

                      return Dismissible(
                        key: ValueKey(tx.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20.0),
                          color: AppColors.expense,
                          child: const Icon(
                            CupertinoIcons.trash,
                            color: CupertinoColors.white,
                          ),
                        ),
                        confirmDismiss: (direction) async {
                          // Play a very subtle confirmation or just return true
                          return true;
                        },
                        onDismissed: (direction) {
                          widget.state.deleteTransaction(tx.id);
                        },
                        child: CupertinoListTile.notched(
                          title: Text(
                            tx.title,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.label(context),
                            ),
                          ),
                          subtitle: Row(
                            children: [
                              Text(
                                tx.category,
                                style: TextStyle(
                                  color: AppColors.secondaryLabel(context),
                                  fontSize: 12,
                                ),
                              ),
                              if (tx.isMonthlyRecurring) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 1,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.warning.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(
                                        CupertinoIcons.repeat,
                                        size: 10,
                                        color: AppColors.warning,
                                      ),
                                      SizedBox(width: 2),
                                      Text(
                                        'รายเดือน',
                                        style: TextStyle(
                                          fontSize: 9,
                                          color: AppColors.warning,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ]
                            ],
                          ),
                          leading: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              gradient: AppColors.getCategoryGradient(tx.category),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              categoryDetails.icon,
                              color: CupertinoColors.white,
                              size: 18,
                            ),
                          ),
                          additionalInfo: Text(
                            '$amtPrefix${_formatCurrency(tx.amount)}',
                            style: TextStyle(
                              color: amtColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
                childCount: sortedKeys.length,
              ),
            ),
          // Extra bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 32),
          ),
        ],
      ),
    );
  }
}
