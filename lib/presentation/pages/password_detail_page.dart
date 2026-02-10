import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/password_entity.dart';
import '../viewmodels/password_viewmodel.dart';
import 'add_password_page.dart';

class PasswordDetailPage extends StatefulWidget {
  final String passwordId;

  const PasswordDetailPage({super.key, required this.passwordId});

  @override
  State<PasswordDetailPage> createState() => _PasswordDetailPageState();
}

class _PasswordDetailPageState extends State<PasswordDetailPage> {
  bool _obscurePassword = true;
  PasswordEntity? _password;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPassword();
  }

  Future<void> _loadPassword() async {
    final viewModel = context.read<PasswordViewModel>();
    final password = await viewModel.getPasswordById(widget.passwordId);
    setState(() {
      _password = password;
      _isLoading = false;
    });
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  int _calculateStrength(String password) {
    int score = 0;
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[a-z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) score++;
    return (score / 6 * 100).round().clamp(0, 100);
  }

  String _getStrengthLabel(int score) {
    if (score >= 80) return 'STRONG';
    if (score >= 50) return 'MEDIUM';
    return 'WEAK';
  }

  Color _getStrengthColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 50) return Colors.orange;
    return AppColors.danger;
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Password'),
        content: const Text('Are you sure you want to delete this password? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textGrey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final viewModel = context.read<PasswordViewModel>();
              final success = await viewModel.deletePassword(widget.passwordId);
              if (success && context.mounted) {
                Navigator.pop(context, true);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Delete', style: TextStyle(color: AppColors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToEdit() async {
    if (_password == null) return;
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddPasswordPage(
          existingPassword: _password,
        ),
      ),
    );
    if (result == true && mounted) {
      _loadPassword();
    }
  }

  String _getDomain(String? url) {
    if (url == null || url.isEmpty) return '';
    try {
      final uri = Uri.parse(url.contains('://') ? url : 'https://$url');
      return uri.host;
    } catch (_) {
      return url;
    }
  }

  Future<void> _launchUrl(String? urlString) async {
    if (urlString == null || urlString.isEmpty) return;

    final Uri url = Uri.parse(
      urlString.contains('://') ? urlString : 'https://$urlString',
    );

    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not launch URL'),
              backgroundColor: AppColors.danger,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error launching URL: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final strengthScore = _password != null ? _calculateStrength(_password!.password) : 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
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
          'Password Details',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _password == null
              ? const Center(child: Text('Password not found'))
              : ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    // App icon and title
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: AppColors.textDark,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(
                                _password!.title.isNotEmpty ? _password!.title[0].toUpperCase() : '?',
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 36,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _password!.title,
                            style: const TextStyle(
                              color: AppColors.textDark,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          GestureDetector(
                            onTap: () => _launchUrl(_password!.url),
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textGrey,
                                ),
                                children: [
                                  TextSpan(text: '${_password!.category ?? 'Personal Account'} • '),
                                  TextSpan(
                                    text: _getDomain(_password!.url),
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Username/Email card
                    _buildDetailCard(
                      icon: Icons.person_outline,
                      label: 'USERNAME/EMAIL',
                      value: _password!.username,
                      onCopy: () => _copyToClipboard(_password!.username, 'Username'),
                    ),
                    const SizedBox(height: 12),

                    // Password card
                    _buildPasswordCard(),
                    const SizedBox(height: 12),

                    // Website card
                    if (_password!.url != null && _password!.url!.isNotEmpty)
                      _buildDetailCard(
                        icon: Icons.language,
                        label: 'WEBSITE',
                        value: _password!.url!,
                        onCopy: () => _copyToClipboard(_password!.url!, 'Website'),
                        isLink: true,
                        onTapValue: () => _launchUrl(_password!.url),
                        trailing: IconButton(
                          icon: const Icon(Icons.open_in_new, color: AppColors.primary, size: 20),
                          onPressed: () => _launchUrl(_password!.url),
                        ),
                      ),
                    if (_password!.url != null && _password!.url!.isNotEmpty)
                      const SizedBox(height: 12),

                    // Notes card
                    if (_password!.notes != null && _password!.notes!.isNotEmpty)
                      _buildDetailCard(
                        icon: Icons.notes,
                        label: 'NOTES',
                        value: _password!.notes!,
                      ),
                    if (_password!.notes != null && _password!.notes!.isNotEmpty)
                      const SizedBox(height: 12),

                    // Security Score
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Security Score',
                                style: TextStyle(
                                  color: AppColors.textGrey,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                _getStrengthLabel(strengthScore),
                                style: TextStyle(
                                  color: _getStrengthColor(strengthScore),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: strengthScore / 100,
                              backgroundColor: AppColors.cardBorder,
                              valueColor: AlwaysStoppedAnimation<Color>(_getStrengthColor(strengthScore)),
                              minHeight: 8,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Last updated
                    Center(
                      child: Text(
                        'Last updated: ${DateFormat('MMMM d, y \'at\' h:mm a').format(_password!.updatedAt)}',
                        style: const TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Edit button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _navigateToEdit,
                        icon: const Icon(Icons.edit_outlined, color: AppColors.white),
                        label: const Text(
                          'Edit Credentials',
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
                    const SizedBox(height: 12),

                    // Delete button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _showDeleteDialog,
                        icon: const Icon(Icons.delete_outline, color: AppColors.danger),
                        label: const Text(
                          'Delete Account',
                          style: TextStyle(
                            color: AppColors.danger,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: const BorderSide(color: AppColors.danger),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onCopy,
    Widget? trailing,
    bool isLink = false,
    VoidCallback? onTapValue,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.textGrey, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onTapValue,
                  child: Text(
                    value,
                    style: TextStyle(
                      color: isLink ? AppColors.primary : AppColors.textDark,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      decoration: isLink ? TextDecoration.underline : null,
                      decorationColor: AppColors.primary,
                    ),
                  ),
                ),
              ),
              if (onCopy != null)
                IconButton(
                  icon: const Icon(Icons.copy, color: AppColors.primary, size: 20),
                  onPressed: onCopy,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              if (trailing != null) trailing,
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.lock_outline, color: AppColors.textGrey, size: 18),
              SizedBox(width: 8),
              Text(
                'PASSWORD',
                style: TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  _obscurePassword ? '••••••••••••' : _password!.password,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: AppColors.textGrey,
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.copy, color: AppColors.primary, size: 20),
                onPressed: () => _copyToClipboard(_password!.password, 'Password'),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
