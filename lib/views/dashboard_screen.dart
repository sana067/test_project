// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/dashboard_viewmodel.dart';
import '../models/user_model.dart';
import '../widgets/custom_card.dart';
import 'login_screen.dart';

// Dashboard Screen - View layer for displaying users list
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch users when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardViewModel>().fetchUsers();
    });
  }

  void _handleLogout(BuildContext context) {
    // Reset login state and navigate back to login
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _handleLogout(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Consumer<DashboardViewModel>(
        builder: (context, viewModel, child) {
          // Loading state
          if (viewModel.isLoading && viewModel.users.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading users...'),
                ],
              ),
            );
          }

          // Error state
          if (viewModel.hasError && viewModel.users.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading users',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    viewModel.errorMessage ?? 'Unknown error',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => viewModel.fetchUsers(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Success state with data
          if (viewModel.users.isNotEmpty) {
            return RefreshIndicator(
              onRefresh: () async {
                await viewModel.refreshUsers();
                // Show refresh success message if not in error state
                if (!viewModel.hasError && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Users refreshed successfully'),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: Column(
                children: [
                  // Page info
                  if (viewModel.usersResponse.data != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Page ${viewModel.currentPage} of ${viewModel.usersResponse.data!.totalPages}',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            'Total: ${viewModel.usersResponse.data!.total} users',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),

                  // Users list
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: viewModel.users.length,
                      itemBuilder: (context, index) {
                        final user = viewModel.users[index] as UserModel;
                        return _UserCard(user: user);
                      },
                    ),
                  ),

                  // Pagination controls
                  if (viewModel.usersResponse.data != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton.icon(
                            onPressed: viewModel.currentPage > 1
                                ? () => viewModel.loadPreviousPage()
                                : null,
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Previous'),
                          ),
                          Text(
                            'Page ${viewModel.currentPage}',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          ElevatedButton.icon(
                            onPressed:
                                viewModel.currentPage <
                                    viewModel.usersResponse.data!.totalPages
                                ? () => viewModel.loadNextPage()
                                : null,
                            icon: const Icon(Icons.arrow_forward),
                            label: const Text('Next'),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          }

          // Empty state
          return const Center(child: Text('No users found'));
        },
      ),
    );
  }
}

// User Card Widget - Displays individual user information
class _UserCard extends StatelessWidget {
  final UserModel user;

  const _UserCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(user.avatar),
            onBackgroundImageError: (exception, stackTrace) {
              // Handle image loading error
            },
            child: user.avatar.isEmpty
                ? Text(
                    user.firstName[0].toUpperCase(),
                    style: const TextStyle(fontSize: 24),
                  )
                : null,
          ),
          const SizedBox(width: 16),

          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${user.firstName} ${user.lastName}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.email_outlined,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        user.email,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'ID: ${user.id}',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
