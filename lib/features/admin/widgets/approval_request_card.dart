import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/user_approval_request.dart';
import '../../../core/models/user_model.dart';

class ApprovalRequestCard extends StatelessWidget {
  final UserApprovalRequest request;
  final Function(String, bool) onApprove;

  const ApprovalRequestCard({
    Key? key,
    required this.request,
    required this.onApprove,
  }) : super(key: key);

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.teacher:
        return Colors.blue;
      case UserRole.student:
        return Colors.green;
      case UserRole.admin:
        return Colors.red;
      case UserRole.parent:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  request.displayName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Chip(
                  label: Text(request.role.toString().split('.').last),
                  backgroundColor: _getRoleColor(request.role),
                  labelStyle: const TextStyle(color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(request.email),
            const SizedBox(height: 16),
            if (request.message != null && request.message!.isNotEmpty) ...[
              const Text(
                'Message:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(request.message!),
              const SizedBox(height: 16),
            ],
            Text(
              'Date: ${DateFormat('MMM d, yyyy').format(request.requestDate)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => onApprove(request.id, false),
                  child: const Text('Reject'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () => onApprove(request.id, true),
                  child: const Text('Approve'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}