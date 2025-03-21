import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';
import '../models/user_approval_request.dart';
import '../widgets/approval_request_card.dart';

class UserApprovalScreen extends StatefulWidget {
  static const routeName = '/user-approvals';
  
  const UserApprovalScreen({Key? key}) : super(key: key);

  @override
  State<UserApprovalScreen> createState() => _UserApprovalScreenState();
}

class _UserApprovalScreenState extends State<UserApprovalScreen> {
  bool _isLoading = true;
  String? _error;
  String _currentFilter = 'pending';

  @override
  void initState() {
    super.initState();
    _loadApprovalRequests(_currentFilter);
  }

  Future<void> _loadApprovalRequests(String? status) async {
    setState(() {
      _isLoading = true;
      _error = null;
      if (status != null) {
        _currentFilter = status;
      }
    });

    try {
      await Provider.of<AdminProvider>(context, listen: false)
          .loadApprovalRequests(status: status);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Approval Requests'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadApprovalRequests(_currentFilter),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Error loading requests',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(_error!),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => _loadApprovalRequests(_currentFilter),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _buildRequestsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _filterChip('All', null),
            const SizedBox(width: 8),
            _filterChip('Pending', 'pending'),
            const SizedBox(width: 8),
            _filterChip('Approved', 'approved'),
            const SizedBox(width: 8),
            _filterChip('Rejected', 'rejected'),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, String? value) {
    final isSelected = (value == null && _currentFilter == 'all') || value == _currentFilter;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          _loadApprovalRequests(value ?? 'all');
        }
      },
      backgroundColor: Colors.grey[200],
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      checkmarkColor: Theme.of(context).primaryColor,
    );
  }

  Widget _buildRequestsList() {
    final adminProvider = Provider.of<AdminProvider>(context);
    final requests = adminProvider.approvalRequests;
    
    if (requests.isEmpty) {
      return Center(
        child: Text(
          'No ${_currentFilter == 'all' ? '' : _currentFilter} approval requests found',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadApprovalRequests(_currentFilter),
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: requests.length,
        itemBuilder: (ctx, index) {
          final request = requests[index];
          return ApprovalRequestCard(
            request: request,
            onProcess: (approved, notes) async {
              await adminProvider.processUserApproval(
                requestId: request.id,
                approved: approved,
                notes: notes,
              );
              _loadApprovalRequests(_currentFilter);
            },
          );
        },
      ),
    );
  }
}