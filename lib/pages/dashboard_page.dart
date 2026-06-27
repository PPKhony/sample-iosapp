import 'package:flutter/cupertino.dart';
import '../theme/colors.dart';
import '../providers/app_state.dart';
import '../widgets/donut_chart.dart';
import '../models/transaction.dart';

class DashboardPage extends StatelessWidget {
  final AppState state;
  final VoidCallback onNavigateToHistory;

  const DashboardPage({
    super.key,
    required this.state,
    required this.onNavigateToHistory,
  });

  String _formatCurrency(double amount) {
    final prefix = amount < 0 ? '-฿' : '฿';
    final absAmount = amount.abs();
    return '$prefix${absAmount.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        )}';
  }

  @override
  Widget build(BuildContext context) {
    final balanceColor = state.netBalance >= 0 ? AppColors.success : AppColors.expense;
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;

    return CupertinoPageScaffold(
      backgroundColor: AppColors.background(context),
      child: CustomScrollView(
        slivers: [
          const CupertinoSliverNavigationBar(
            largeTitle: Text('สรุปผล'),
            border: null,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Balance Summary Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [const Color(0xFF2C2C2E), const Color(0xFF1C1C1E)]
                            : [const Color(0xFFFFFFFF), const Color(0xFFF9F9FB)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? const Color(0x30000000)
                              : const Color(0x08000000),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ยอดเงินคงเหลือสุทธิ',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.secondaryLabel(context),
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _formatCurrency(state.netBalance),
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: balanceColor,
                            letterSpacing: -1.0,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Income & Expense Split
                        Row(
                          children: [
                            // Income box
                            Expanded(
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.success.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      CupertinoIcons.arrow_down_right,
                                      color: AppColors.success,
                                      size: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'รายรับ',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.secondaryLabel(context),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          _formatCurrency(state.totalIncome),
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.label(context),
                                            letterSpacing: -0.4,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: 35,
                              width: 1,
                              color: AppColors.divider(context),
                            ),
                            // Expense box
                            Expanded(
                              child: Row(
                                children: [
                                  const SizedBox(width: 12),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.expense.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      CupertinoIcons.arrow_up_left,
                                      color: AppColors.expense,
                                      size: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'รายจ่าย',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.secondaryLabel(context),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          _formatCurrency(state.totalExpenses),
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.label(context),
                                            letterSpacing: -0.4,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 2. Chart Section Title
                  Text(
                    'สัดส่วนการใช้จ่าย',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.label(context),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Chart Card
                  CupertinoDonutChart(
                    categoryRatios: state.expensesByCategory,
                    totalAmount: state.totalExpenses,
                  ),

                  const SizedBox(height: 24),

                  // 3. Recent Transactions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'รายการล่าสุด',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.label(context),
                          letterSpacing: -0.5,
                        ),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: onNavigateToHistory,
                        child: const Row(
                          children: [
                            Text(
                              'ดูทั้งหมด',
                              style: TextStyle(fontSize: 14),
                            ),
                            Icon(
                              CupertinoIcons.chevron_forward,
                              size: 14,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Recent items list in iOS Container style
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground(context),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.transactions.length > 4 ? 4 : state.transactions.length,
                      separatorBuilder: (context, index) => Container(
                        height: 1,
                        margin: const EdgeInsets.only(left: 56),
                        color: AppColors.divider(context),
                      ),
                      itemBuilder: (context, index) {
                        final tx = state.transactions[index];
                        final categoryDetails = TransactionCategory.fromString(tx.category);
                        final amtString = '${tx.isExpense ? "-" : "+"}฿${tx.amount.toStringAsFixed(0)}';

                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              // Icon container
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  gradient: AppColors.getCategoryGradient(tx.category),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  categoryDetails.icon,
                                  color: CupertinoColors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 14),
                              // Title and Date
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      tx.title,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.label(context),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      tx.category,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.secondaryLabel(context),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Amount
                              Text(
                                amtString,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: tx.isExpense
                                      ? AppColors.expense
                                      : AppColors.income,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
