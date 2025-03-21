import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/resource_request_model.dart';
import '../providers/admin_provider.dart';
import '../widgets/resource_request_card.dart';

class ResourceManagementScreen extends StatefulWidget {
  const ResourceManagementScreen({Key? key}) : super(key: key);

  @override
  State<ResourceManagementScreen> createState() => _ResourceManagementScreenState();
}

class _ResourceManagementScreenState extends State<ResourceManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _donorNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadRequests();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _notesController.dispose();
    _donorNameController.dispose();
    super.dispose();
  }

  Future<void> _loadRequests() async {
    final provider = Provider.of<AdminProvider>(context, listen: false);
    await provider.loadResourceRequests();
  }

  ResourceRequestStatus _getStatusFromIndex(int index) {
    switch (index) {
      case 0:
        return ResourceRequestStatus.pending;
      case 1:
        return ResourceRequestStatus.approved;
      case 2:
        return ResourceRequestStatus.rejected;
      case 3:
        return ResourceRequestStatus.completed;
      default:
        return ResourceRequestStatus.pending;
    }
  }

  Future<Map<String, String>?> _showProcessDialog(
    BuildContext context,
    String requestId,
    bool isApproved,
  ) async {
    _notesController.clear();
    _donorNameController.clear();

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isApproved ? 'Approve Request' : 'Reject Request'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isApproved) TextField(
              controller: _donorNameController,
              decoration: const InputDecoration(
                labelText: 'Donor Name (Optional)',
              ),
            ),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, {
                'notes': _notesController.text,
                'donorName': _donorNameController.text,
              });
            },
            child: Text(isApproved ? 'Approve' : 'Reject'),
          ),
        ],
      ),
    );

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resource Management'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Approved'),
            Tab(text: 'Rejected'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildResourceRequestsTab(ResourceRequestStatus.pending),
          _buildResourceRequestsTab(ResourceRequestStatus.approved),
          _buildResourceRequestsTab(ResourceRequestStatus.rejected),
          _buildResourceRequestsTab(ResourceRequestStatus.completed),
        ],
      ),
    );
  }

  Widget _buildResourceRequestsTab(ResourceRequestStatus status) {
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, child) {
        if (adminProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final requests = adminProvider.resourceRequests
            .where((request) => request.status == status)
            .toList();

        if (requests.isEmpty) {
          return Center(
            child: Text('No ${status.toString().split('.').last} requests'),
          );
        }

        return ListView.builder(
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            return ResourceRequestCard(
              request: request,
              onProcess: (requestId, isApproved) async {
                final result = await _showProcessDialog(
                  context,
                  requestId,
                  isApproved,
                );

                if (result != null && mounted) {
                  await adminProvider.processResourceRequest(
                    requestId,
                    isApproved,
                    notes: result['notes'],
                  );
                }
              },
            );
          },
        );
      },
    );
  }
}