import '../../../core/models/user_model.dart';

enum UserRole {
  student,
  teacher,
  admin,
  parent,
}

enum ApprovalStatus {
  pending,
  approved,
  rejected,
}

class UserApprovalRequest {
  final String id;
  final String email;
  final String displayName;
  final UserRole role;
  final ApprovalStatus status;
  final DateTime createdAt;
  final String? message;
  final String? notes;
  final DateTime requestDate;

  UserApprovalRequest({
    required this.id,
    required this.email,
    required this.displayName,
    required this.role,
    required this.status,
    required this.createdAt,
    this.message,
    this.notes,
    required this.requestDate,
  });

  String get userInitials {
    if (displayName.isEmpty) return '';
    
    final nameParts = displayName.split(' ');
    if (nameParts.length == 1) {
      return nameParts[0][0].toUpperCase();
    } else {
      return '${nameParts[0][0]}${nameParts[nameParts.length - 1][0]}'.toUpperCase();
    }
  }

  String get roleDisplay {
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
        return 'Unknown';
    }
  }

  String get statusDisplay {
    switch (status) {
      case ApprovalStatus.pending:
        return 'Pending';
      case ApprovalStatus.approved:
        return 'Approved';
      case ApprovalStatus.rejected:
        return 'Rejected';
      default:
        return 'Unknown';
    }
  }

  factory UserApprovalRequest.fromJson(Map<String, dynamic> json) {
    return UserApprovalRequest(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      displayName: json['displayName'] ?? '',
      role: _parseRole(json['role']),
      status: _parseStatus(json['status']),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      message: json['message'],
      notes: json['notes'],
      requestDate: json['requestDate'] != null
          ? DateTime.parse(json['requestDate'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'role': role.toString().split('.').last,
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'message': message,
      'notes': notes,
      'requestDate': requestDate.toIso8601String(),
    };
  }

  static UserRole _parseRole(String? roleStr) {
    if (roleStr == null) return UserRole.student;
    
    switch (roleStr.toLowerCase()) {
      case 'teacher':
        return UserRole.teacher;
      case 'admin':
        return UserRole.admin;
      case 'parent':
        return UserRole.parent;
      case 'student':
      default:
        return UserRole.student;
    }
  }

  static ApprovalStatus _parseStatus(String? statusStr) {
    if (statusStr == null) return ApprovalStatus.pending;
    
    switch (statusStr.toLowerCase()) {
      case 'approved':
        return ApprovalStatus.approved;
      case 'rejected':
        return ApprovalStatus.rejected;
      case 'pending':
      default:
        return ApprovalStatus.pending;
    }
  }
}