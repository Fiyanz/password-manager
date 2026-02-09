import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../viewmodels/password_viewmodel.dart';
import 'add_password_page.dart';
import 'password_detail_page.dart';
import 'generator_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    // Load passwords when page is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PasswordViewModel>().loadPasswords();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _selectedIndex == 0 ? _buildPasswordsTab() : _buildGeneratorTab(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddPasswordPage()),
          );
        },
        backgroundColor: AppColors.primary,
        elevation: 6,
        child: const Icon(Icons.add, color: AppColors.white, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: AppColors.white,
        elevation: 8,
        notchMargin: 8,
        shape: const CircularNotchedRectangle(),
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedIndex = 0;
                    });
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _selectedIndex == 0 ? Icons.home : Icons.home_outlined,
                        color: _selectedIndex == 0
                            ? AppColors.primary
                            : AppColors.textGrey,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Home',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: _selectedIndex == 0
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: _selectedIndex == 0
                              ? AppColors.primary
                              : AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 80), // Space for FAB
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedIndex = 2;
                    });
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.auto_awesome_outlined,
                        color: _selectedIndex == 2
                            ? AppColors.primary
                            : AppColors.textGrey,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Generator',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: _selectedIndex == 2
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: _selectedIndex == 2
                              ? AppColors.primary
                              : AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordsTab() {
    return SafeArea(
      child: Column(
        children: [
          // Header
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    // Avatar
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.background,
                      child: Icon(
                        Icons.person,
                        color: AppColors.textGrey,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // User info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Halo, User',
                                style: TextStyle(
                                  color: AppColors.textDark,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(Icons.favorite, color: Colors.red, size: 18),
                            ],
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'LOCKED • SECURE • CEO NAIKAN GAJIKU',
                            style: TextStyle(
                              color: AppColors.textGrey,
                              fontSize: 10,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Search icon
                    IconButton(
                      icon: const Icon(Icons.search, color: AppColors.textDark),
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Category filters
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildCategoryChip('All', _selectedCategory == 'All'),
                      const SizedBox(width: 8),
                      _buildCategoryChip(
                        'Social',
                        _selectedCategory == 'Social',
                      ),
                      const SizedBox(width: 8),
                      _buildCategoryChip('Work', _selectedCategory == 'Work'),
                      const SizedBox(width: 8),
                      _buildCategoryChip(
                        'Finance',
                        _selectedCategory == 'Finance',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Password list
          Expanded(
            child: Consumer<PasswordViewModel>(
              builder: (context, viewModel, child) {
                // Show loading indicator
                if (viewModel.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                // Show error message
                if (viewModel.errorMessage != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 80,
                          color: AppColors.danger.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error: ${viewModel.errorMessage}',
                          style: const TextStyle(
                            color: AppColors.danger,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => viewModel.loadPasswords(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                          ),
                          child: const Text(
                            'Retry',
                            style: TextStyle(color: AppColors.white),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Show empty state
                if (viewModel.passwords.isEmpty) {
                  return _buildEmptyState();
                }

                // Show password list
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: viewModel.passwords.length,
                  itemBuilder: (context, index) {
                    final password = viewModel.passwords[index];
                    return _buildPasswordCard(
                      id: password.id,
                      title: password.title,
                      username: password.username,
                      url: password.url,
                      passwordValue: password.password,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.cardBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.white : AppColors.textDark,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordCard({
    required String id,
    required String title,
    required String username,
    required String passwordValue,
    String? url,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to password detail page with ID
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PasswordDetailPage()),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon container (app logo)
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.textDark,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    title.isNotEmpty ? title[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Text info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              color: AppColors.textDark,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 20),
                          color: AppColors.textGrey,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            // TODO: Navigate to edit page
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      username,
                      style: const TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            '• • • • • • • •',
                            style: TextStyle(
                              color: AppColors.textGrey,
                              fontSize: 20,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: InkWell(
                            onTap: () {
                              // TODO: Copy password to clipboard
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Password copied to clipboard'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            child: const Icon(
                              Icons.copy,
                              size: 18,
                              color: AppColors.primary,
                            ),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock_outline,
            size: 80,
            color: AppColors.textGrey.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No passwords saved yet',
            style: TextStyle(
              color: AppColors.textGrey,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap the + button to add your first password',
            style: TextStyle(color: AppColors.textGrey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneratorTab() {
    return const GeneratorPage();
  }
}
