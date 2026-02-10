import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import 'add_password_page.dart';

class GeneratorPage extends StatefulWidget {
  final bool isStandalone;
  
  const GeneratorPage({super.key, this.isStandalone = true});

  @override
  State<GeneratorPage> createState() => _GeneratorPageState();
}

class _GeneratorPageState extends State<GeneratorPage> {
  String _generatedPassword = '';
  double _passwordLength = 24;
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

  // Calculate password strength (0-4 segments)
  int _getStrengthLevel() {
    int score = 0;
    if (_passwordLength >= 8) score++;
    if (_passwordLength >= 16) score++;
    if (_passwordLength >= 24) score++;
    
    int typesCount = 0;
    if (_includeUppercase) typesCount++;
    if (_includeLowercase) typesCount++;
    if (_includeNumbers) typesCount++;
    if (_includeSymbols) typesCount++;
    
    if (typesCount >= 3) score++;
    
    return score.clamp(0, 4);
  }

  String _getStrengthLabel() {
    final level = _getStrengthLevel();
    if (level <= 1) return 'Weak';
    if (level == 2) return 'Medium';
    if (level == 3) return 'Strong';
    return 'Very Strong';
  }

  Color _getStrengthColor() {
    final level = _getStrengthLevel();
    if (level <= 1) return AppColors.danger;
    if (level == 2) return Colors.orange;
    return Colors.green;
  }

  String _getEstimatedCrackTime() {
    final length = _passwordLength.toInt();
    int typesCount = 0;
    if (_includeUppercase) typesCount++;
    if (_includeLowercase) typesCount++;
    if (_includeNumbers) typesCount++;
    if (_includeSymbols) typesCount++;

    if (length >= 24 && typesCount >= 3) return '400+ years';
    if (length >= 16 && typesCount >= 3) return '100+ years';
    if (length >= 12 && typesCount >= 2) return '10+ years';
    if (length >= 8) return '1+ years';
    return 'Less than 1 year';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: widget.isStandalone ? AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: Row(
            children: const [
              Icon(Icons.chevron_left, color: AppColors.primary),
              Text(
                'Back',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        leadingWidth: 100,
        title: const Text(
          'Password Generator',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ) : null,
      body: SafeArea(
        top: !widget.isStandalone,
        bottom: false,
        child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Generated password display card
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1.5),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Password text
                Text(
                  _generatedPassword,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                
                // Regenerate and Copy buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildIconButton(
                      icon: Icons.refresh,
                      onTap: _generatePassword,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                    ),
                    const SizedBox(width: 12),
                    _buildIconButton(
                      icon: Icons.copy,
                      onTap: _copyToClipboard,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Security Level
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Security Level',
                      style: TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      _getStrengthLabel(),
                      style: TextStyle(
                        color: _getStrengthColor(),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Strength bar (4 segments)
                Row(
                  children: List.generate(4, (index) {
                    final isActive = index < _getStrengthLevel();
                    return Expanded(
                      child: Container(
                        margin: EdgeInsets.only(right: index < 3 ? 4 : 0),
                        height: 6,
                        decoration: BoxDecoration(
                          color: isActive ? _getStrengthColor() : AppColors.cardBorder,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 8),
                
                // Estimated crack time
                Text(
                  'Estimated time to crack: ${_getEstimatedCrackTime()}',
                  style: TextStyle(
                    color: AppColors.primary.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Password Length
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Password Length',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_passwordLength.toInt()}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Slider
          Row(
            children: [
              const Text('8', style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppColors.primary,
                    inactiveTrackColor: AppColors.cardBorder,
                    thumbColor: AppColors.primary,
                    overlayColor: AppColors.primary.withOpacity(0.2),
                    trackHeight: 6,
                  ),
                  child: Slider(
                    value: _passwordLength,
                    min: 8,
                    max: 64,
                    divisions: 56,
                    onChanged: (value) {
                      setState(() {
                        _passwordLength = value;
                      });
                      _generatePassword();
                    },
                  ),
                ),
              ),
              const Text('64', style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 24),

          // Character type options
          _buildSwitchOption(
            icon: 'Aa',
            title: 'Uppercase Letters',
            subtitle: 'ABC...',
            value: _includeUppercase,
            onChanged: (value) {
              setState(() => _includeUppercase = value);
              _generatePassword();
            },
          ),
          const SizedBox(height: 12),
          _buildSwitchOption(
            icon: 'TT',
            title: 'Lowercase Letters',
            subtitle: 'abc...',
            value: _includeLowercase,
            onChanged: (value) {
              setState(() => _includeLowercase = value);
              _generatePassword();
            },
          ),
          const SizedBox(height: 12),
          _buildSwitchOption(
            icon: '123',
            title: 'Numbers',
            subtitle: '123...',
            value: _includeNumbers,
            onChanged: (value) {
              setState(() => _includeNumbers = value);
              _generatePassword();
            },
          ),
          const SizedBox(height: 12),
          _buildSwitchOption(
            icon: '@',
            title: 'Symbols',
            subtitle: '#\$@...',
            value: _includeSymbols,
            onChanged: (value) {
              setState(() => _includeSymbols = value);
              _generatePassword();
            },
          ),
          const SizedBox(height: 32),

          // Use Password button (only for standalone mode)
          if (widget.isStandalone)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (_generatedPassword.isNotEmpty &&
                      _generatedPassword != 'Select at least one option') {
                    Navigator.pop(context, _generatedPassword);
                  }
                },
                icon: const Icon(Icons.check_circle_outline, color: AppColors.white),
                label: const Text(
                  'Use Password',
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
          
          // Save as New Password button (only for embedded mode in home tab)
          if (!widget.isStandalone)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (_generatedPassword.isNotEmpty &&
                      _generatedPassword != 'Select at least one option') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddPasswordPage(
                          initialPassword: _generatedPassword,
                        ),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.save_outlined, color: AppColors.white),
                label: const Text(
                  'Save as New Password',
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
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color backgroundColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.primary, size: 24),
      ),
    );
  }

  Widget _buildSwitchOption({
    required String icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                icon,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
