import 'package:flutter/material.dart';

enum ResourceRequestType {
  book,
  equipment,
  software,
  furniture,
  supplies,
  other,
}

enum ResourceRequestStatus {
  pending,
  approved,
  rejected,
  fulfilled,
}

class ResourceRequest {
  final String id;
  final String title;
  final String description;
  final ResourceRequestType type;
  final ResourceRequestStatus status;
  final int quantity;
  final double? estimatedCost;
  final String requestedById;
  final String requestedByName;
  final DateTime requestDate;
  final String? notes;
  final String? donorName;
  final DateTime? fulfilledDate;
  final String? approverId;
  final DateTime? approvedDate;

  const ResourceRequest({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.status,
    required this.quantity,
    required this.requestedById,
    required this.requestedByName,
    required this.requestDate,
    this.estimatedCost,
    this.notes,
    this.donorName,
    this.fulfilledDate,
    this.approverId,
    this.approvedDate,
  });

  IconData getTypeIcon() {
    switch (type) {
      case ResourceRequestType.book:
        return Icons.book;
      case ResourceRequestType.equipment:
        return Icons.computer;
      case ResourceRequestType.software:
        return Icons.code;
      case ResourceRequestType.furniture:
        return Icons.chair;
      case ResourceRequestType.supplies:
        return Icons.inventory_2;
      case ResourceRequestType.other:
      default:
        return Icons.category;
    }
  }

  Color getStatusColor() {
    switch (status) {
      case ResourceRequestStatus.pending:
        return Colors.orange;
      case ResourceRequestStatus.approved:
        return Colors.blue;
      case ResourceRequestStatus.rejected:
        return Colors.red;
      case ResourceRequestStatus.fulfilled:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String get typeDisplay {
    switch (type) {
      case ResourceRequestType.book:
        return 'Book';
      case ResourceRequestType.equipment:
        return 'Equipment';
      case ResourceRequestType.software:
        return 'Software';
      case ResourceRequestType.furniture:
        return 'Furniture';
      case ResourceRequestType.supplies:
        return 'Supplies';
      case ResourceRequestType.other:
        return 'Other';
      default:
        return 'Unknown';
    }
  }

  String get statusDisplay {
    switch (status) {
      case ResourceRequestStatus.pending:
        return 'Pending';
      case ResourceRequestStatus.approved:
        return 'Approved';
      case ResourceRequestStatus.rejected:
        return 'Rejected';
      case ResourceRequestStatus.fulfilled:
        return 'Fulfilled';
      default:
        return 'Unknown';
    }
  }

  factory ResourceRequest.fromJson(Map<String, dynamic> json) {
    return ResourceRequest(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: _parseType(json['type']),
      status: _parseStatus(json['status']),
      quantity: json['quantity'] ?? 1,
      estimatedCost: json['estimatedCost']?.toDouble(),
      requestedById: json['requestedById'] ?? '',
      requestedByName: json['requestedByName'] ?? 'Unknown User',
      requestDate: json['requestDate'] != null
          ? DateTime.parse(json['requestDate'])
          : DateTime.now(),
      notes: json['notes'],
      donorName: json['donorName'],
      fulfilledDate: json['fulfilledDate'] != null
          ? DateTime.parse(json['fulfilledDate'])
          : null,
      approverId: json['approverId'],
      approvedDate: json['approvedDate'] != null
          ? DateTime.parse(json['approvedDate'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'quantity': quantity,
      'estimatedCost': estimatedCost,
      'requestedById': requestedById,
      'requestedByName': requestedByName,
      'requestDate': requestDate.toIso8601String(),
      'notes': notes,
      'donorName': donorName,
      'fulfilledDate': fulfilledDate?.toIso8601String(),
      'approverId': approverId,
      'approvedDate': approvedDate?.toIso8601String(),
    };
  }

  static ResourceRequestType _parseType(String? typeStr) {
    if (typeStr == null) return ResourceRequestType.other;
    
    switch (typeStr.toLowerCase()) {
      case 'book':
        return ResourceRequestType.book;
      case 'equipment':
        return ResourceRequestType.equipment;
      case 'software':
        return ResourceRequestType.software;
      case 'furniture':
        return ResourceRequestType.furniture;
      case 'supplies':
        return ResourceRequestType.supplies;
      case 'other':
      default:
        return ResourceRequestType.other;
    }
  }

  static ResourceRequestStatus _parseStatus(String? statusStr) {
    if (statusStr == null) return ResourceRequestStatus.pending;
    
    switch (statusStr.toLowerCase()) {
      case 'approved':
        return ResourceRequestStatus.approved;
      case 'rejected':
        return ResourceRequestStatus.rejected;
      case 'fulfilled':
        return ResourceRequestStatus.fulfilled;
      case 'pending':
      default:
        return ResourceRequestStatus.pending;
    }
  }
}