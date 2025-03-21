import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/user_model.dart';
import '../providers/admin_provider.dart';

class UserManagementScreen extends StatefulWidget {
  static const routeName = '/user-management';
  final String? initialFilter;

  const UserManagementScreen({Key? key, this.initialFilter}) : super(key: key);

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';
  UserRole? _selectedRole;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Set initial filter if provided
    if (widget.initialFilter != null) {
      switch (widget.initialFilter) {
        case 'student':
          _selectedRole = UserRole.student;
          break;
        case 'teacher':
          _selectedRole = UserRole.teacher;
          break;
        case 'admin':
          _selectedRole = UserRole.admin;
          break;
        case 'parent':
          _selectedRole = UserRole.parent;
          break;
      }
    }
    
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await Provider.of<AdminProvider>(context, listen: false)
          .loadUsers(role: _selectedRole, searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null);
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  void _handleSearch() {
    _searchQuery = _searchController.text.trim();
    _loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUsers,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilterBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Error loading users',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(_error!),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadUsers,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _buildUsersList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement adding a new user
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Add new user functionality coming soon!'),
            ),
          );
        },
        child: const Icon(Icons.person_add),
      ),
    );
  }

  Widget _buildSearchAndFilterBar() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by name or email',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  if (_searchQuery.isNotEmpty) {
                    _searchQuery = '';
                    _loadUsers();
                  }
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            onSubmitted: (_) => _handleSearch(),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _filterChip('All', null),
                const SizedBox(width: 8),
                _filterChip('Students', UserRole.student),
                const SizedBox(width: 8),
                _filterChip('Teachers', UserRole.teacher),
                const SizedBox(width: 8),
                _filterChip('Admins', UserRole.admin),
                const SizedBox(width: 8),
                _filterChip('Parents', UserRole.parent),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, UserRole? role) {
    final isSelected = _selectedRole == role;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedRole = selected ? role : null;
        });
        _loadUsers();
      },
      backgroundColor: Colors.grey[200],
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      checkmarkColor: Theme.of(context).primaryColor,
    );
  }

  Widget _buildUsersList() {
    final adminProvider = Provider.of<AdminProvider>(context);
    final users = adminProvider.users;
    
    if (users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'No users found',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _selectedRole != null 
                  ? 'No ${_selectedRole.toString().split('.').last}s found' 
                  : _searchQuery.isNotEmpty 
                      ? 'No users match "$_searchQuery"' 
                      : 'No users available in the system',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadUsers,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: users.length,
        itemBuilder: (ctx, index) {
          final user = users[index];
          return _buildUserListItem(user);
        },
      ),
    );
  }

  Widget _buildUserListItem(UserModel user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        leading: CircleAvatar(
          backgroundColor: _getUserRoleColor(user.role).withOpacity(0.2),
          child: Text(
            user.initials,
            style: TextStyle(
              color: _getUserRoleColor(user.role),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          user.fullName ?? user.displayName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email),
            const SizedBox(height: 4),
            Chip(
              label: Text(_getUserRoleDisplay(user.role)),
              backgroundColor: _getUserRoleColor(user.role).withOpacity(0.1),
              labelStyle: TextStyle(
                color: _getUserRoleColor(user.role),
                fontSize: 12,
              ),
              padding: EdgeInsets.zero,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () => _showUserOptionsDialog(user),
        ),
        onTap: () {
          // TODO: Navigate to user details screen
        },
      ),
    );
  }

  Color _getUserRoleColor(UserRole role) {
    switch (role) {
      case UserRole.student:
        return Colors.blue;
      case UserRole.teacher:
        return Colors.green;
      case UserRole.admin:
        return Colors.purple;
      case UserRole.parent:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getUserRoleDisplay(UserRole role) {
    switch (role) {
      case UserRole.student:
        return 'Student';
      case UserRole.teacher:
        return 'Teacher';
      case UserRole.admin:
        return 'Administrator';
      case UserRole.parent:
        return 'Parent';
      default:
        return 'Unknown Role';
    }
  }

  void _showUserOptionsDialog(UserModel user) {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text('Options for ${user.fullName ?? user.displayName}'),
        children: [
          SimpleDialogOption(
            onPressed: () {
              Navigator.of(ctx).pop();
              // TODO: Implement view user details
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('View user details functionality coming soon!'),
                ),
              );
            },
            child: const Row(
              children: [
                Icon(Icons.person),
                SizedBox(width: 12),
                Text('View Details'),
              ],
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.of(ctx).pop();
              // TODO: Implement edit user
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Edit user functionality coming soon!'),
                ),
              );
            },
            child: const Row(
              children: [
                Icon(Icons.edit),
                SizedBox(width: 12),
                Text('Edit'),
              ],
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.of(ctx).pop();
              _showDeactivateUserDialog(user);
            },
            child: Row(
              children: [
                Icon(Icons.block, color: Colors.orange.shade700),
                const SizedBox(width: 12),
                const Text('Deactivate'),
              ],
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.of(ctx).pop();
              _showDeleteUserDialog(user);
            },
            child: const Row(
              children: [
                Icon(Icons.delete, color: Colors.red),
                SizedBox(width: 12),
                Text('Delete', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeactivateUserDialog(UserModel user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Deactivate User'),
        content: Text(
          'Are you sure you want to deactivate ${user.fullName ?? user.displayName}? '
          'This action can be undone later.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              // TODO: Implement deactivate user
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Deactivate user functionality coming soon!'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );
  }

  void _showDeleteUserDialog(UserModel user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete User'),
        content: Text(
          'Are you sure you want to permanently delete ${user.fullName ?? user.displayName}? '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              // TODO: Implement delete user
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Delete user functionality coming soon!'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}