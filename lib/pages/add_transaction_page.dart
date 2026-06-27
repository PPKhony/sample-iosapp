import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors; // Standard Material Colors for very subtle highlights if needed
import '../theme/colors.dart';
import '../providers/app_state.dart';
import '../models/transaction.dart';
import '../widgets/keypad.dart';
import '../widgets/success_anim.dart';

class AddTransactionPage extends StatefulWidget {
  final AppState state;

  const AddTransactionPage({
    super.key,
    required this.state,
  });

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  // Input fields state
  bool _isExpense = true;
  String _amountStr = '0';
  final TextEditingController _titleController = TextEditingController();
  String _selectedCategory = 'Food & Drinks';
  DateTime _selectedDate = DateTime.now();
  bool _isMonthlyRecurring = false;

  // Overlay state
  bool _showSuccessAnim = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _handleKeyPress(String value) {
    setState(() {
      if (_amountStr == '0' && value != '.') {
        _amountStr = value;
      } else {
        // Prevent multiple decimals
        if (value == '.' && _amountStr.contains('.')) return;
        
        // Prevent more than 2 decimal places
        if (_amountStr.contains('.')) {
          final parts = _amountStr.split('.');
          if (parts.length > 1 && parts[1].length >= 2) return;
        }

        // Maximum limit of 9 digits to prevent UI overflow
        if (_amountStr.replaceAll('.', '').length >= 9) return;

        _amountStr += value;
      }
    });
  }

  void _handleDelete() {
    setState(() {
      if (_amountStr.length <= 1) {
        _amountStr = '0';
      } else {
        _amountStr = _amountStr.substring(0, _amountStr.length - 1);
      }
    });
  }

  void _showCategoryPicker() {
    // Get categories depending on income/expense
    final List<String> categories = _isExpense
        ? [
            'Food & Drinks',
            'Shopping',
            'Transportation',
            'Entertainment',
            'Bills & Utilities',
            'Investment',
            'Other'
          ]
        : ['Salary', 'Side Hustle', 'Other'];

    // Auto switch category to default if not matching the group
    if (!categories.contains(_selectedCategory)) {
      _selectedCategory = categories.first;
    }

    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('เลือกหมวดหมู่'),
        message: const Text('เลือกหมวดหมู่ที่เหมาะสมกับรายการของคุณ'),
        actions: categories.map((cat) {
          return CupertinoActionSheetAction(
            onPressed: () {
              setState(() {
                _selectedCategory = cat;
              });
              Navigator.pop(context);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  TransactionCategory.fromString(cat).icon,
                  color: AppColors.getCategoryColor(cat),
                ),
                const SizedBox(width: 8),
                Text(
                  cat,
                  style: TextStyle(
                    color: AppColors.label(context),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('ยกเลิก'),
        ),
      ),
    );
  }

  void _showDatePicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => Container(
        height: 280,
        padding: const EdgeInsets.only(top: 6.0),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        color: AppColors.cardBackground(context),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              // Header bar
              Container(
                color: AppColors.background(context),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.pop(context),
                      child: const Text('ยกเลิก'),
                    ),
                    const Text(
                      'เลือกวันที่',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.pop(context),
                      child: const Text('เสร็จสิ้น'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.dateAndTime,
                  initialDateTime: _selectedDate,
                  maximumDate: DateTime.now().add(const Duration(days: 365)),
                  onDateTimeChanged: (DateTime newDateTime) {
                    setState(() {
                      _selectedDate = newDateTime;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveTransaction() {
    final amount = double.tryParse(_amountStr) ?? 0.0;
    if (amount <= 0.0) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('กรอกข้อมูลไม่ถูกต้อง'),
          content: const Text('กรุณากรอกจำนวนเงินมากกว่า 0 บาท'),
          actions: [
            CupertinoDialogAction(
              child: const Text('ตกลง'),
              onPressed: () => Navigator.pop(context),
            )
          ],
        ),
      );
      return;
    }

    final title = _titleController.text.trim().isNotEmpty
        ? _titleController.text.trim()
        : (_isExpense ? 'รายจ่ายทั่วไป' : 'รายรับทั่วไป');

    // Create item
    final tx = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      amount: amount,
      date: _selectedDate,
      category: _selectedCategory,
      isExpense: _isExpense,
      isMonthlyRecurring: _isMonthlyRecurring,
    );

    // Save to State
    widget.state.addTransaction(tx);

    // Display animation
    setState(() {
      _showSuccessAnim = true;
    });
  }

  void _resetForm() {
    setState(() {
      _amountStr = '0';
      _titleController.clear();
      _selectedDate = DateTime.now();
      _isMonthlyRecurring = false;
      _showSuccessAnim = false;
      // Re-assign default category
      _selectedCategory = _isExpense ? 'Food & Drinks' : 'Salary';
    });
  }

  @override
  Widget build(BuildContext context) {
    final amountColor = _isExpense ? AppColors.expense : AppColors.success;
    final formattedAmount = '฿ ${double.parse(_amountStr).toStringAsFixed(2).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        )}';

    return Stack(
      children: [
        CupertinoPageScaffold(
          backgroundColor: AppColors.background(context),
          child: Column(
            children: [
              const CupertinoNavigationBar(
                middle: Text('บันทึกรายการ'),
                border: null,
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      // 1. Transaction Type Toggle (Segmented control)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: CupertinoSegmentedControl<bool>(
                            groupValue: _isExpense,
                            children: const {
                              true: Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Text('รายจ่าย', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              false: Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Text('รายรับ', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            },
                            onValueChanged: (bool val) {
                              setState(() {
                                _isExpense = val;
                                _selectedCategory = val ? 'Food & Drinks' : 'Salary';
                              });
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // 2. Amount Display (Large, responsive size)
                      GestureDetector(
                        onTap: () {}, // Interactive feedback
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Text(
                            formattedAmount,
                            style: TextStyle(
                              fontSize: 44,
                              fontWeight: FontWeight.bold,
                              color: amountColor,
                              letterSpacing: -1.5,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),

                      // 3. Settings Style Form Sections
                      CupertinoFormSection.insetGrouped(
                        backgroundColor: Colors.transparent,
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        children: [
                          // Title / Description
                          CupertinoFormRow(
                            prefix: const Icon(CupertinoIcons.square_pencil, color: CupertinoColors.activeBlue, size: 20),
                            child: CupertinoTextField(
                              controller: _titleController,
                              placeholder: 'คำอธิบาย (เช่น มื้อเย็น, เงินปันผล)',
                              placeholderStyle: TextStyle(
                                color: AppColors.secondaryLabel(context).withOpacity(0.6),
                              ),
                              decoration: null, // Clear border
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                              style: TextStyle(color: AppColors.label(context)),
                            ),
                          ),

                          // Category selection
                          GestureDetector(
                            onTap: _showCategoryPicker,
                            behavior: HitTestBehavior.opaque,
                            child: CupertinoFormRow(
                              prefix: const Icon(CupertinoIcons.tag, color: CupertinoColors.systemPurple, size: 20),
                              helper: null,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          TransactionCategory.fromString(_selectedCategory).icon,
                                          color: AppColors.getCategoryColor(_selectedCategory),
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          _selectedCategory,
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: AppColors.label(context),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Icon(
                                      CupertinoIcons.chevron_down,
                                      size: 16,
                                      color: CupertinoColors.inactiveGray,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Date selector
                          GestureDetector(
                            onTap: _showDatePicker,
                            behavior: HitTestBehavior.opaque,
                            child: CupertinoFormRow(
                              prefix: const Icon(CupertinoIcons.calendar, color: CupertinoColors.systemRed, size: 20),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year} ${_selectedDate.hour.toString().padLeft(2, '0')}:${_selectedDate.minute.toString().padLeft(2, '0')}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: AppColors.label(context),
                                      ),
                                    ),
                                    const Icon(
                                      CupertinoIcons.calendar_badge_plus,
                                      size: 16,
                                      color: CupertinoColors.inactiveGray,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Recurring Expense toggle switch
                          CupertinoFormRow(
                            prefix: const Icon(CupertinoIcons.repeat, color: CupertinoColors.systemOrange, size: 20),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _isExpense ? 'จ่ายเป็นประจำทุกเดือน' : 'รับเป็นประจำทุกเดือน',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: AppColors.label(context),
                                    ),
                                  ),
                                  CupertinoSwitch(
                                    value: _isMonthlyRecurring,
                                    activeColor: AppColors.primary,
                                    onChanged: (bool value) {
                                      setState(() {
                                        _isMonthlyRecurring = value;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      // 4. Save Button
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Container(
                          width: double.infinity,
                          height: 52,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            gradient: LinearGradient(
                              colors: _isExpense
                                  ? [const Color(0xFFFF453A), const Color(0xFFFF2D55)]
                                  : [const Color(0xFF34C759), const Color(0xFF30D158)],
                            ),
                          ),
                          child: CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: _saveTransaction,
                            child: const Text(
                              'บันทึกรายการ',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: CupertinoColors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 5. Custom Keypad at the bottom
              SafeArea(
                top: false,
                child: CupertinoKeypad(
                  onKeyPress: _handleKeyPress,
                  onDelete: _handleDelete,
                ),
              ),
            ],
          ),
        ),

        // Success animation overlay
        if (_showSuccessAnim)
          CupertinoSuccessOverlay(
            onFinished: () {
              _resetForm();
            },
          ),
      ],
    );
  }
}
