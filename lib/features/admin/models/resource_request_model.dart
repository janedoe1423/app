import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
  completed
}

enum ResourceType {
  book,
  equipment,
  supplies,
  other
}

class ResourceRequest {
  final String id;
  final String title;
  final String description;
  final String userId;
  final String userName;
  final ResourceRequestStatus status;
  final DateTime createdAt;
  final DateTime requestDate;
  final String? notes;
  final ResourceType type;
  final int quantity;
  final double? estimatedCost;
  final String? donorName;
  final DateTime? completedDate;

  const ResourceRequest({
    required this.id,
    required this.title,
    required this.description,
    required this.userId,
    required this.userName,
    required this.status,
    required this.createdAt,
    required this.requestDate,
    required this.type,
    required this.quantity,
    this.notes,
    this.estimatedCost,
    this.donorName,
    this.completedDate,
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
      case ResourceRequestStatus.completed:
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
      case ResourceRequestStatus.completed:
        return 'Completed';
      default:
        return 'Unknown';
    }
  }

  factory ResourceRequest.fromJson(Map<String, dynamic> json) {
    return ResourceRequest(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? 'Unknown User',
      status: ResourceRequestStatus.values.firstWhere(
        (s) => s.toString() == json['status'],
        orElse: () => ResourceRequestStatus.pending,
      ),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      requestDate: json['requestDate'] != null
          ? DateTime.parse(json['requestDate'])
          : DateTime.now(),
      notes: json['notes'],
      type: ResourceType.values.firstWhere(
        (t) => t.toString().split('.').last == json['type'],
        orElse: () => ResourceType.other,
      ),
      quantity: json['quantity'] ?? 0,
      estimatedCost: json['estimatedCost'] as double?,
      donorName: json['donorName'],
      completedDate: json['completedDate'] != null
          ? DateTime.parse(json['completedDate'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'userId': userId,
      'userName': userName,
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'requestDate': requestDate.toIso8601String(),
      'notes': notes,
      'type': type.toString().split('.').last,
      'quantity': quantity,
      'estimatedCost': estimatedCost,
      'donorName': donorName,
      'completedDate': completedDate?.toIso8601String(),
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
      case 'completed':
        return ResourceRequestStatus.completed;
      case 'pending':
      default:
        return ResourceRequestStatus.pending;
    }
  }

  factory ResourceRequest.fromMap(Map<String, dynamic> data) {
    return ResourceRequest(
      id: data['id'] as String,
      title: data['title'] as String,
      description: data['description'] as String,
      userId: data['userId'] as String,
      userName: data['userName'] as String,
      status: ResourceRequestStatus.values.firstWhere(
        (s) => s.toString().split('.').last == data['status'],
        orElse: () => ResourceRequestStatus.pending,
      ),
      type: ResourceType.values.firstWhere(
        (t) => t.toString().split('.').last == data['type'],
        orElse: () => ResourceType.other,
      ),
      createdAt: DateTime.parse(data['createdAt']),
      requestDate: DateTime.parse(data['requestDate']),
      quantity: data['quantity'] as int,
      estimatedCost: data['estimatedCost'] as double?,
      notes: data['notes'] as String?,
      donorName: data['donorName'] as String?,
      completedDate: data['completedDate'] != null 
          ? DateTime.parse(data['completedDate'])
          : null,
    );
  }

  String getStatusText() {
    switch (status) {
      case ResourceRequestStatus.pending:
        return 'Pending';
      case ResourceRequestStatus.approved:
        return 'Approved';
      case ResourceRequestStatus.rejected:
        return 'Rejected';
      case ResourceRequestStatus.completed:
        return 'Completed';
    }
  }
}