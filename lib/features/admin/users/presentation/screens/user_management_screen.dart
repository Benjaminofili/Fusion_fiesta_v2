import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/di/service_locator.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_roles.dart';
import '../../../../../data/models/user.dart';
import '../../../../../data/repositories/user_repository.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen>
    with SingleTickerProviderStateMixin {
  final _repo = serviceLocator<UserRepository>();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  // --- ACTIONS ---

  Future<void> _updateUser(User user) async {
    await _repo.updateUser(user);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('User updated successfully'),
            backgroundColor: AppColors.success),
      );
    }
  }

  void _showEditDialog(User user) {
    showDialog(
      context: context,
      builder: (context) => _EditUserDialog(
        user: user,
        onSave: (updatedUser) {
          _updateUser(updatedUser);
          context.pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'All Users'),
            Tab(text: 'Pending Staff'),
          ],
        ),
      ),
      // ✅ CHANGED: Use StreamBuilder for Real-Time Updates
      body: StreamBuilder<List<User>>(
        stream: _repo.getUsersStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!;

          return TabBarView(
            controller: _tabController,
            children: [
              // 1. ALL USERS TAB
              _UserList(
                users: users,
                onTap: _showEditDialog,
                isPendingTab: false,
              ),

              // 2. PENDING TAB
              _UserList(
                users: users
                    .where((u) =>
                        !u.isApproved &&
                        (u.role == AppRole.organizer ||
                            u.role == AppRole.admin))
                    .toList(),
                onTap: (user) {
                  _updateUser(user.copyWith(isApproved: true));
                },
                isPendingTab: true,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _UserList extends StatelessWidget {
  final List<User> users;
  final Function(User) onTap;
  final bool isPendingTab;

  const _UserList(
      {required this.users, required this.onTap, this.isPendingTab = false});

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.group_off_outlined, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(isPendingTab ? "No pending requests" : "No users found",
                style: TextStyle(color: Colors.grey[500])),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        final isActive = user.isApproved;

        return Card(
          elevation: 0,
          margin: EdgeInsets.only(bottom: 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: AppColors.border),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isPendingTab
                  ? Colors.orange[50]
                  : (isActive
                      ? AppColors.primary.withValues(alpha:0.1)
                      : Colors.red[50]),
              child: Icon(
                Icons.person,
                color: isPendingTab
                    ? Colors.orange
                    : (isActive ? AppColors.primary : Colors.red),
              ),
            ),
            title: Text(user.name,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.email, style: TextStyle(fontSize: 12.sp)),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    _RoleBadge(role: user.role),
                    if (!isActive && !isPendingTab) ...[
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                            color: Colors.red[100],
                            borderRadius: BorderRadius.circular(4)),
                        child: Text('DEACTIVATED',
                            style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.red)),
                      ),
                    ]
                  ],
                ),
              ],
            ),
            trailing: isPendingTab
                ? IconButton.filled(
                    icon: const Icon(Icons.check),
                    style: IconButton.styleFrom(
                        backgroundColor: AppColors.success),
                    tooltip: 'Approve Staff',
                    onPressed: () => onTap(user),
                  )
                : const Icon(Icons.edit, size: 20, color: Colors.grey),
            onTap: isPendingTab ? null : () => onTap(user),
          ),
        );
      },
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final AppRole role;
  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (role) {
      case AppRole.admin:
        color = Colors.red;
        break;
      case AppRole.organizer:
        color = Colors.purple;
        break;
      case AppRole.student:
        color = Colors.blue;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha:0.3)),
      ),
      child: Text(
        role.name.toUpperCase(),
        style: TextStyle(
            fontSize: 10.sp, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}

// --- DIALOG FOR EDITING USER ---
class _EditUserDialog extends StatefulWidget {
  final User user;
  final Function(User) onSave;

  const _EditUserDialog({required this.user, required this.onSave});

  @override
  State<_EditUserDialog> createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<_EditUserDialog> {
  late AppRole _selectedRole;
  late bool _isApproved;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.user.role;
    _isApproved = widget.user.isApproved;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit User: ${widget.user.name}',
          style: TextStyle(fontSize: 18.sp)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Role Assignment
          DropdownButtonFormField<AppRole>(
            initialValue: _selectedRole,
            decoration: const InputDecoration(labelText: 'Role'),
            items: AppRole.values
                .map((role) => DropdownMenuItem(
                      value: role,
                      child: Text(role.name.toUpperCase()),
                    ))
                .toList(),
            onChanged: (val) => setState(() => _selectedRole = val!),
          ),
          SizedBox(height: 16.h),

          // 2. Account Control (Active/Deactive)
          SwitchListTile(
            title: const Text('Account Active'),
            subtitle:
                Text(_isApproved ? 'User can log in' : 'User access revoked'),
            value: _isApproved,
            activeThumbColor: AppColors.success,
            onChanged: (val) => setState(() => _isApproved = val),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => context.pop(), child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            final updated = widget.user.copyWith(
              role: _selectedRole,
              isApproved: _isApproved,
            );
            widget.onSave(updated);
          },
          child: const Text('Save Changes'),
        ),
      ],
    );
  }
}
