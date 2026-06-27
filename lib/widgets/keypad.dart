import 'package:flutter/cupertino.dart';
import '../theme/colors.dart';

class CupertinoKeypad extends StatelessWidget {
  final Function(String) onKeyPress;
  final VoidCallback onDelete;

  const CupertinoKeypad({
    super.key,
    required this.onKeyPress,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final List<List<String>> keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['.', '0', '⌫'],
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: AppColors.background(context),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: keys.map((row) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: row.map((key) {
                return _KeypadButton(
                  value: key,
                  onTap: () {
                    if (key == '⌫') {
                      onDelete();
                    } else {
                      onKeyPress(key);
                    }
                  },
                );
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _KeypadButton extends StatefulWidget {
  final String value;
  final VoidCallback onTap;

  const _KeypadButton({
    required this.value,
    required this.onTap,
  });

  @override
  State<_KeypadButton> createState() => _KeypadButtonState();
}

class _KeypadButtonState extends State<_KeypadButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    final isSpecial = widget.value == '⌫' || widget.value == '.';

    Color buttonColor;
    if (_isPressed) {
      buttonColor = isDark ? const Color(0xFF48484A) : const Color(0xFFD1D1D6);
    } else {
      buttonColor = isSpecial
          ? (isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA))
          : (isDark ? const Color(0xFF3A3A3C) : const Color(0xFFFFFFFF));
    }

    final double size = MediaQuery.of(context).size.width * 0.25;

    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _isPressed = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          _isPressed = false;
        });
        widget.onTap();
      },
      onTapCancel: () {
        setState(() {
          _isPressed = false;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 60),
        width: size,
        height: 60,
        decoration: BoxDecoration(
          color: buttonColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            if (!_isPressed)
              BoxShadow(
                color: isDark ? const Color(0x30000000) : const Color(0x08000000),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Center(
          child: widget.value == '⌫'
              ? Icon(
                  CupertinoIcons.delete_left,
                  color: AppColors.label(context),
                  size: 22,
                )
              : Text(
                  widget.value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: AppColors.label(context),
                  ),
                ),
        ),
      ),
    );
  }
}
