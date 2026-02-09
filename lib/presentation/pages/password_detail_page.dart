import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';

class PasswordDetailPage extends StatefulWidget {
  const PasswordDetailPage({super.key});

  @override
  State<PasswordDetailPage> createState() => _PasswordDetailPageState();
}

class _PasswordDetailPageState extends State<PasswordDetailPage> {
  bool _obscurePassword = true;

  // Mock data - will come from navigation args
  final String _title = 'Gmail';
  final String _username = 'user@gmail.com';
  final String _password = 'SecurePass123!';
  final String _url = 'https://gmail.com';
  final String _createdAt = '2024-01-15';

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

  void _deletePassword() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Delete Password',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const Text(
          'Are you sure you want to delete this password? This action cannot be undone.',
          style: TextStyle(color: AppColors.textDark),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textGrey),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to home
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
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
          'Password Details',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.danger),
            onPressed: _deletePassword,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Title section
          _buildDetailCard(
            icon: Icons.title,
            label: 'Title',
            value: _title,
            onCopy: () => _copyToClipboard(_title, 'Title'),
          ),
          const SizedBox(height: 12),

          // Username section
          _buildDetailCard(
            icon: Icons.person_outline,
            label: 'Username/Email',
            value: _username,
            onCopy: () => _copyToClipboard(_username, 'Username'),
          ),
          const SizedBox(height: 12),

          // Password section
          _buildPasswordCard(),
          const SizedBox(height: 12),

          // URL section
          _buildDetailCard(
            icon: Icons.link,
            label: 'Website URL',
            value: _url,
            onCopy: () => _copyToClipboard(_url, 'URL'),
          ),
          const SizedBox(height: 12),

          // Created date section
          _buildInfoCard(
            icon: Icons.calendar_today,
            label: 'Created',
            value: _createdAt,
          ),
          const SizedBox(height: 24),

          // Edit button
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to edit page
            },
            icon: const Icon(Icons.edit, color: AppColors.white),
            label: const Text(
              'Edit Password',
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
        ],
      ),
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onCopy,
  }) {
    return Container(
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
            children: [
              Icon(icon, color: AppColors.textGrey, size: 20),
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
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.copy,
                  color: AppColors.primary,
                  size: 20,
                ),
                onPressed: onCopy,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordCard() {
    return Container(
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
            children: [
              const Icon(
                Icons.lock_outline,
                color: AppColors.textGrey,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Password',
                style: TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  _obscurePassword ? '••••••••••' : _password,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.primary,
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
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(
                  Icons.copy,
                  color: AppColors.primary,
                  size: 20,
                ),
                onPressed: () => _copyToClipboard(_password, 'Password'),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
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
            children: [
              Icon(icon, color: AppColors.textGrey, size: 20),
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
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
