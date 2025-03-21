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
  ApprovalStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    final provider = Provider.of<AdminProvider>(context, listen: false);
    await provider.loadApprovalRequests(status: _selectedStatus);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Approvals'),
      ),
      body: Consumer<AdminProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(child: Text(provider.error!));
          }

          final requests = provider.approvalRequests;
          
          if (requests.isEmpty) {
            return const Center(child: Text('No approval requests found'));
          }

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              return ApprovalRequestCard(
                request: requests[index],
                onApprove: (id, approved) {
                  provider.processApprovalRequest(id, approved);
                },
              );
            },
          );
        },
      ),
    );
  }
}