import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';

class GeneratorPage extends StatefulWidget {
  const GeneratorPage({super.key});

  @override
  State<GeneratorPage> createState() => _GeneratorPageState();
}

class _GeneratorPageState extends State<GeneratorPage> {
  String _generatedPassword = '';
  double _passwordLength = 12;
  bool _includeUppercase = true;
  bool _includeLowercase = true;
  bool _includeNumbers = true;
  bool _includeSymbols = true;

  @override
  void initState() {
    super.initState();
    _generatePassword();
  }

  void _generatePassword() {
    const String lowercase = 'abcdefghijklmnopqrstuvwxyz';
    const String uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const String numbers = '0123456789';
    const String symbols = '!@#\$%^&*()_+-=[]{}|;:,.<>?';

    String chars = '';
    if (_includeLowercase) chars += lowercase;
    if (_includeUppercase) chars += uppercase;
    if (_includeNumbers) chars += numbers;
    if (_includeSymbols) chars += symbols;

    if (chars.isEmpty) {
      setState(() {
        _generatedPassword = 'Select at least one option';
      });
      return;
    }

    Random random = Random.secure();
    String password = '';
    for (int i = 0; i < _passwordLength.toInt(); i++) {
      password += chars[random.nextInt(chars.length)];
    }

    setState(() {
      _generatedPassword = password;
    });
  }

  void _copyToClipboard() {
    if (_generatedPassword.isNotEmpty &&
        _generatedPassword != 'Select at least one option') {
      Clipboard.setData(ClipboardData(text: _generatedPassword));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password copied to clipboard'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Color _getStrengthColor() {
    if (_passwordLength < 8) return AppColors.danger;
    if (_passwordLength < 12) return Colors.orange;
    return Colors.green;
  }

  String _getStrengthLabel() {
    if (_passwordLength < 8) return 'Weak';
    if (_passwordLength < 12) return 'Medium';
    return 'Strong';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Password Generator',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Generated password display
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.cardBorder),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _generatedPassword,
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getStrengthColor().withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getStrengthLabel(),
                        style: TextStyle(
                          color: _getStrengthColor(),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Password length slider
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.cardBorder),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Password Length',
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${_passwordLength.toInt()}',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _passwordLength,
                  min: 4,
                  max: 32,
                  divisions: 28,
                  activeColor: AppColors.primary,
                  onChanged: (value) {
                    setState(() {
                      _passwordLength = value;
                    });
                    _generatePassword();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Options
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.cardBorder),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Character Types',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                _buildCheckboxOption('Uppercase (A-Z)', _includeUppercase, (
                  value,
                ) {
                  setState(() {
                    _includeUppercase = value!;
                  });
                  _generatePassword();
                }),
                _buildCheckboxOption('Lowercase (a-z)', _includeLowercase, (
                  value,
                ) {
                  setState(() {
                    _includeLowercase = value!;
                  });
                  _generatePassword();
                }),
                _buildCheckboxOption('Numbers (0-9)', _includeNumbers, (value) {
                  setState(() {
                    _includeNumbers = value!;
                  });
                  _generatePassword();
                }),
                _buildCheckboxOption('Symbols (!@#\$%)', _includeSymbols, (
                  value,
                ) {
                  setState(() {
                    _includeSymbols = value!;
                  });
                  _generatePassword();
                }),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _generatePassword,
                  icon: const Icon(Icons.refresh, color: AppColors.primary),
                  label: const Text(
                    'Regenerate',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: AppColors.primary, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _copyToClipboard,
                  icon: const Icon(Icons.copy, color: AppColors.white),
                  label: const Text(
                    'Copy',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxOption(
    String label,
    bool value,
    Function(bool?) onChanged,
  ) {
    return CheckboxListTile(
      title: Text(
        label,
        style: const TextStyle(color: AppColors.textDark, fontSize: 14),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primary,
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }
}
