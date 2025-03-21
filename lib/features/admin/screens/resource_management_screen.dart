import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';
import '../models/resource_request_model.dart';
import '../widgets/resource_request_card.dart';

class ResourceManagementScreen extends StatefulWidget {
  static const routeName = '/resource-management';
  
  const ResourceManagementScreen({Key? key}) : super(key: key);

  @override
  State<ResourceManagementScreen> createState() => _ResourceManagementScreenState();
}

class _ResourceManagementScreenState extends State<ResourceManagementScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  String? _error;
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabChange);
    _loadResourceRequests();
  }
  
  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }
  
  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      _loadResourceRequests(_getStatusFromTabIndex(_tabController.index));
    }
  }
  
  ResourceRequestStatus? _getStatusFromTabIndex(int index) {
    switch (index) {
      case 0:
        return null; // All
      case 1:
        return ResourceRequestStatus.pending;
      case 2:
        return ResourceRequestStatus.approved;
      case 3:
        return ResourceRequestStatus.fulfilled;
      default:
        return null;
    }
  }

  Future<void> _loadResourceRequests([ResourceRequestStatus? status]) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await Provider.of<AdminProvider>(context, listen: false)
          .loadResourceRequests(status: status);
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
        title: const Text('Resource Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadResourceRequests(_getStatusFromTabIndex(_tabController.index)),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'All Requests'),
            Tab(text: 'Pending'),
            Tab(text: 'Approved'),
            Tab(text: 'Fulfilled'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildResourceRequestsTab(null),
          _buildResourceRequestsTab(ResourceRequestStatus.pending),
          _buildResourceRequestsTab(ResourceRequestStatus.approved),
          _buildResourceRequestsTab(ResourceRequestStatus.fulfilled),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement creating a new resource request
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Create new resource request functionality coming soon!'),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildResourceRequestsTab(ResourceRequestStatus? status) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_error != null) {
      return Center(
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
              onPressed: () => _loadResourceRequests(status),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    final adminProvider = Provider.of<AdminProvider>(context);
    final requests = adminProvider.resourceRequests;
    
    // Filter requests by status if specified
    final filteredRequests = status == null
        ? requests
        : requests.where((req) => req.status == status).toList();
    
    if (filteredRequests.isEmpty) {
      return Center(
        child: Text(
          'No ${status == null ? '' : status.toString().split('.').last} resource requests found',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadResourceRequests(status),
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: filteredRequests.length,
        itemBuilder: (ctx, index) {
          final request = filteredRequests[index];
          return ResourceRequestCard(
            request: request,
            onProcess: (newStatus, donorName, notes) async {
              await adminProvider.processResourceRequest(
                requestId: request.id,
                newStatus: newStatus,
                donorName: donorName,
                notes: notes,
              );
              _loadResourceRequests(status);
            },
          );
        },
      ),
    );
  }
}