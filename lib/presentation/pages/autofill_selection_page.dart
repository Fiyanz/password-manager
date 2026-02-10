import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_autofill_service/flutter_autofill_service.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../domain/entities/password_entity.dart';
import '../viewmodels/password_viewmodel.dart';

class AutofillSelectionPage extends StatefulWidget {
  final AutofillMetadata metadata;

  const AutofillSelectionPage({super.key, required this.metadata});

  @override
  State<AutofillSelectionPage> createState() => _AutofillSelectionPageState();
}

class _AutofillSelectionPageState extends State<AutofillSelectionPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Pre-fill search with domain or app name if possible?
    // Or just filter the list automatically.
    // For now, let's just show all, but maybe prioritize matches.
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Trigger load if not loaded? Main page usually loads it.
      // But if launched fresh, we might need to load.
      context.read<PasswordViewModel>().loadPasswords();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onPasswordSelected(PasswordEntity password) async {
    final success = await AutofillService().resultWithDataset(
      label: password.title,
      username: password.username,
      password: password.password,
    );

    if (mounted) {
      if (success) {
        // Close the app/activity
        SystemNavigator.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to set autofill dataset')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Extract hints like package name or domain
    final packageNames = widget.metadata.packageNames;
    final webDomains = widget.metadata.webDomains.map((e) => e.domain).toList();
    
    final hintText = webDomains.isNotEmpty 
        ? webDomains.join(', ') 
        : packageNames.isNotEmpty 
            ? packageNames.join(', ') 
            : 'Unknown App';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Password', style: TextStyle(fontSize: 18)),
            Text(
              'For: $hintText',
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        actions: [
            IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => SystemNavigator.pop(),
            ),
        ],
      ),
      body: Consumer<PasswordViewModel>(
        builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
                return const Center(child: CircularProgressIndicator());
            }

            // Filter logic:
            // 1. Matches domain/package (High priority)
            // 2. Matches search query (if any)
            
            // For now, simple implementation: Show all, allow search.
            // Ideally should filter by domain automatically.
            
            var passwords = viewModel.passwords;
            if (_searchQuery.isNotEmpty) {
                passwords = passwords.where((p) => 
                    p.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                    p.username.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                    (p.url != null && p.url!.toLowerCase().contains(_searchQuery.toLowerCase()))
                ).toList();
            } else {
                // Try to prioritize matches?
                // For simplicity in this iteration, just list all.
                // User can search.
            }

            return Column(
                children: [
                    Padding(
                        padding: const EdgeInsets.all(16),
                        child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                                hintText: 'Search passwords...',
                                prefixIcon: const Icon(Icons.search),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: AppColors.white,
                            ),
                            onChanged: (val) {
                                setState(() {
                                    _searchQuery = val;
                                });
                            },
                        ),
                    ),
                    Expanded(
                        child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: passwords.length,
                            itemBuilder: (context, index) {
                                final password = passwords[index];
                                return Card(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: ListTile(
                                        leading: CircleAvatar(
                                            backgroundColor: AppColors.textDark,
                                            child: Text(
                                                password.title.isNotEmpty ? password.title[0].toUpperCase() : '?',
                                                style: const TextStyle(color: AppColors.white),
                                            ),
                                        ),
                                        title: Text(password.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                                        subtitle: Text(password.username),
                                        trailing: const Icon(Icons.touch_app, color: AppColors.primary),
                                        onTap: () => _onPasswordSelected(password),
                                    ),
                                );
                            },
                        ),
                    ),
                ],
            );
        },
      ),
    );
  }
}
