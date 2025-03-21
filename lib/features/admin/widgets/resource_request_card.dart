import 'package:flutter/material.dart';
import '../models/resource_request_model.dart';
import 'package:intl/intl.dart';

class ResourceRequestCard extends StatelessWidget {
  final ResourceRequest request;
  final Function(String, bool) onProcess;
  final currencyFormat = NumberFormat.currency(symbol: '\$');

  ResourceRequestCard({
    Key? key,
    required this.request,
    required this.onProcess,
  }) : super(key: key);

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
                Expanded(
                  child: Text(
                    request.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Chip(
                  label: Text('Qty: ${request.quantity}'),
                  backgroundColor: Colors.grey[200],
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text(request.getStatusText()),
                  backgroundColor: request.getStatusColor().withOpacity(0.1),
                  labelStyle: TextStyle(color: request.getStatusColor()),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(request.description),
            const SizedBox(height: 16),
            Text(
              'Requested by: ${request.userName}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Text(
              'Date: ${DateFormat('MMM d, yyyy').format(request.requestDate)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (request.estimatedCost != null) ...[
              const SizedBox(height: 4),
              Text(
                'Estimated Cost: ${currencyFormat.format(request.estimatedCost)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            if (request.status == ResourceRequestStatus.completed &&
                request.donorName != null) ...[
              const SizedBox(height: 8),
              Text(
                'Completed by: ${request.donorName}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (request.completedDate != null)
                Text(
                  'Completed on: ${DateFormat('MMM d, yyyy').format(request.completedDate!)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
            if (request.status == ResourceRequestStatus.pending) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => onProcess(request.id, false),
                    child: const Text('Reject'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () => onProcess(request.id, true),
                    child: const Text('Approve'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}