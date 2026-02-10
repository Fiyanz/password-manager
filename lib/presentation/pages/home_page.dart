import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/password_entity.dart';
import '../viewmodels/password_viewmodel.dart';
import 'add_password_page.dart';
import 'generator_page.dart';
import 'password_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedTabIndex = 0;
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchVisible = false;


  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
    });
    context.read<PasswordViewModel>().filterByCategory(category);
  }

  void _copyPassword(String password) {
    Clipboard.setData(ClipboardData(text: password));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Password copied to clipboard'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _navigateToDetail(PasswordEntity password) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PasswordDetailPage(passwordId: password.id),
      ),
    ).then((_) {
      // Refresh list when returning
      context.read<PasswordViewModel>().loadPasswords();
    });
  }

  void _navigateToAdd() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddPasswordPage()),
    );
    if (result == true) {
      // Password was saved, refresh list
      context.read<PasswordViewModel>().loadPasswords();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _selectedTabIndex == 0 ? _buildPasswordList() : const GeneratorPage(isStandalone: false),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAdd,
        backgroundColor: AppColors.primary,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: AppColors.white, size: 28),
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
              // Home Tab
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _selectedTabIndex = 0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _selectedTabIndex == 0 ? Icons.home : Icons.home_outlined,
                        color: _selectedTabIndex == 0 ? AppColors.primary : AppColors.textGrey,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Home',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: _selectedTabIndex == 0 ? FontWeight.w600 : FontWeight.w500,
                          color: _selectedTabIndex == 0 ? AppColors.primary : AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 80), // Space for FAB
              // Generator Tab
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _selectedTabIndex = 1),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.auto_awesome_outlined,
                        color: _selectedTabIndex == 1 ? AppColors.primary : AppColors.textGrey,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Generator',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: _selectedTabIndex == 1 ? FontWeight.w600 : FontWeight.w500,
                          color: _selectedTabIndex == 1 ? AppColors.primary : AppColors.textGrey,
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

  Widget _buildPasswordList() {
    return SafeArea(
      child: Column(
        children: [
          // Header
          _buildHeader(),
          
          // Search bar (when visible)
          if (_isSearchVisible) _buildSearchBar(),
          
          // Category chips
          _buildCategoryChips(),
          
          // Password list
          Expanded(
            child: Consumer<PasswordViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                if (viewModel.errorMessage != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.danger, size: 48),
                        const SizedBox(height: 16),
                        Text(
                          viewModel.errorMessage!,
                          style: const TextStyle(color: AppColors.textGrey),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => viewModel.loadPasswords(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                          ),
                          child: const Text('Retry', style: TextStyle(color: AppColors.white)),
                        ),
                      ],
                    ),
                  );
                }

                if (viewModel.passwords.isEmpty) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  onRefresh: () => viewModel.loadPasswords(),
                  color: AppColors.primary,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: viewModel.passwords.length,
                    itemBuilder: (context, index) {
                      final password = viewModel.passwords[index];
                      return _buildPasswordCard(password);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: AppColors.primary, size: 28),
          ),
          const SizedBox(width: 12),
          // Greeting
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Text(
                      'Halo, User ',
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    // Text('💙', style: TextStyle(fontSize: 20)),
                  ],
                ),
                const SizedBox(height: 2),
                const Text(
                  'Your passwords are safe',
                  style: TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // Search icon
          IconButton(
            onPressed: () {
              setState(() {
                _isSearchVisible = !_isSearchVisible;
                if (!_isSearchVisible) {
                  _searchController.clear();
                  context.read<PasswordViewModel>().searchPasswords('');
                }
              });
            },
            icon: Icon(
              _isSearchVisible ? Icons.close : Icons.search,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          context.read<PasswordViewModel>().searchPasswords(value);
        },
        decoration: InputDecoration(
          hintText: 'Search passwords...',
          hintStyle: const TextStyle(color: AppColors.textGrey),
          prefixIcon: const Icon(Icons.search, color: AppColors.textGrey),
          filled: true,
          fillColor: AppColors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.cardBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.cardBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    final viewModel = context.watch<PasswordViewModel>();
    final categories = viewModel.categories;
    return Container(
      height: 50,
      padding: const EdgeInsets.only(left: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = _selectedCategory == category;
          
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (_) => _onCategorySelected(category),
              backgroundColor: AppColors.white,
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.white : AppColors.textDark,
                fontWeight: FontWeight.w500,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? AppColors.primary : AppColors.cardBorder,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPasswordCard(PasswordEntity password) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _navigateToDetail(password),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // App icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.textDark,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    password.title.isNotEmpty ? password.title[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Title and username
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            password.title,
                            style: const TextStyle(
                              color: AppColors.textDark,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, color: AppColors.textGrey, size: 20),
                          onPressed: () => _navigateToDetail(password),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            password.username,
                            style: const TextStyle(
                              color: AppColors.textGrey,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (password.category != null && password.category!.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              password.category!,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text(
                          '••••••••••',
                          style: TextStyle(
                            color: AppColors.textGrey,
                            fontSize: 14,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () => _copyPassword(password.password),
                          borderRadius: BorderRadius.circular(4),
                          child: const Padding(
                            padding: EdgeInsets.all(4),
                            child: Icon(Icons.copy, color: AppColors.primary, size: 18),
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
            color: AppColors.primary.withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          const Text(
            'No passwords saved yet',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap + to add your first password',
            style: TextStyle(
              color: AppColors.textGrey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
