class ResourceModel {
  final String id;
  final String title;
  final ResourceType type;
  final String description;
  final String? fileUrl;
  final String? externalUrl;
  final List<String> tags;
  final String createdBy;
  final String creatorName;
  final DateTime createdAt;
  final int downloadCount;
  final int likeCount;
  final List<String> likedBy;
  final List<ResourceComment> comments;
  
  ResourceModel({
    required this.id,
    required this.title,
    required this.type,
    required this.description,
    this.fileUrl,
    this.externalUrl,
    required this.tags,
    required this.createdBy,
    required this.creatorName,
    required this.createdAt,
    required this.downloadCount,
    required this.likeCount,
    required this.likedBy,
    required this.comments,
  });
  
  factory ResourceModel.fromJson(Map<String, dynamic> json) {
    return ResourceModel(
      id: json['id'],
      title: json['title'],
      type: _parseResourceType(json['type']),
      description: json['description'],
      fileUrl: json['file_url'],
      externalUrl: json['external_url'],
      tags: List<String>.from(json['tags']),
      createdBy: json['created_by'],
      creatorName: json['creator_name'],
      createdAt: DateTime.parse(json['created_at']),
      downloadCount: json['download_count'],
      likeCount: json['like_count'],
      likedBy: List<String>.from(json['liked_by']),
      comments: List<ResourceComment>.from(
        json['comments'].map((x) => ResourceComment.fromJson(x)),
      ),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type.toString().split('.').last,
      'description': description,
      'file_url': fileUrl,
      'external_url': externalUrl,
      'tags': tags,
      'created_by': createdBy,
      'creator_name': creatorName,
      'created_at': createdAt.toIso8601String(),
      'download_count': downloadCount,
      'like_count': likeCount,
      'liked_by': likedBy,
      'comments': comments.map((x) => x.toJson()).toList(),
    };
  }
  
  // Helper to parse resource type
  static ResourceType _parseResourceType(String type) {
    switch (type) {
      case 'document':
        return ResourceType.document;
      case 'presentation':
        return ResourceType.presentation;
      case 'worksheet':
        return ResourceType.worksheet;
      case 'video':
        return ResourceType.video;
      case 'link':
        return ResourceType.link;
      case 'other':
        return ResourceType.other;
      default:
        return ResourceType.other;
    }
  }
  
  // Check if resource is liked by a specific user
  bool isLikedBy(String userId) {
    return likedBy.contains(userId);
  }
  
  // Get resource icon
  String getIconName() {
    switch (type) {
      case ResourceType.document:
        return 'file-text';
      case ResourceType.presentation:
        return 'film';
      case ResourceType.worksheet:
        return 'clipboard';
      case ResourceType.video:
        return 'video';
      case ResourceType.link:
        return 'link';
      case ResourceType.other:
        return 'file';
    }
  }
  
  // Create a copy with updated fields
  ResourceModel copyWith({
    String? title,
    ResourceType? type,
    String? description,
    String? fileUrl,
    String? externalUrl,
    List<String>? tags,
    int? downloadCount,
    int? likeCount,
    List<String>? likedBy,
    List<ResourceComment>? comments,
  }) {
    return ResourceModel(
      id: this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      description: description ?? this.description,
      fileUrl: fileUrl ?? this.fileUrl,
      externalUrl: externalUrl ?? this.externalUrl,
      tags: tags ?? this.tags,
      createdBy: this.createdBy,
      creatorName: this.creatorName,
      createdAt: this.createdAt,
      downloadCount: downloadCount ?? this.downloadCount,
      likeCount: likeCount ?? this.likeCount,
      likedBy: likedBy ?? this.likedBy,
      comments: comments ?? this.comments,
    );
  }
  
  // Add a like from a user
  ResourceModel addLike(String userId) {
    if (likedBy.contains(userId)) return this;
    
    List<String> updatedLikedBy = [...likedBy, userId];
    return copyWith(
      likeCount: likeCount + 1,
      likedBy: updatedLikedBy,
    );
  }
  
  // Remove a like from a user
  ResourceModel removeLike(String userId) {
    if (!likedBy.contains(userId)) return this;
    
    List<String> updatedLikedBy = [...likedBy];
    updatedLikedBy.remove(userId);
    
    return copyWith(
      likeCount: likeCount - 1,
      likedBy: updatedLikedBy,
    );
  }
  
  // Increment download count
  ResourceModel incrementDownload() {
    return copyWith(
      downloadCount: downloadCount + 1,
    );
  }
  
  // Add a comment
  ResourceModel addComment(ResourceComment comment) {
    List<ResourceComment> updatedComments = [...comments, comment];
    return copyWith(
      comments: updatedComments,
    );
  }
}

class ResourceComment {
  final String id;
  final String userId;
  final String userName;
  final String text;
  final DateTime createdAt;
  
  ResourceComment({
    required this.id,
    required this.userId,
    required this.userName,
    required this.text,
    required this.createdAt,
  });
  
  factory ResourceComment.fromJson(Map<String, dynamic> json) {
    return ResourceComment(
      id: json['id'],
      userId: json['user_id'],
      userName: json['user_name'],
      text: json['text'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'text': text,
      'created_at': createdAt.toIso8601String(),
    };
  }
  
  // Format creation date
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} years ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
}

// Resource request model for schools
class ResourceRequestModel {
  final String id;
  final String schoolId;
  final String schoolName;
  final String requestTitle;
  final String description;
  final ResourceRequestType type;
  final ResourceRequestStatus status;
  final String? assignedToNgo;
  final String? assignedToNgoName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ResourceRequestUpdate> updates;
  
  ResourceRequestModel({
    required this.id,
    required this.schoolId,
    required this.schoolName,
    required this.requestTitle,
    required this.description,
    required this.type,
    required this.status,
    this.assignedToNgo,
    this.assignedToNgoName,
    required this.createdAt,
    required this.updatedAt,
    required this.updates,
  });
  
  factory ResourceRequestModel.fromJson(Map<String, dynamic> json) {
    return ResourceRequestModel(
      id: json['id'],
      schoolId: json['school_id'],
      schoolName: json['school_name'],
      requestTitle: json['request_title'],
      description: json['description'],
      type: _parseRequestType(json['type']),
      status: _parseRequestStatus(json['status']),
      assignedToNgo: json['assigned_to_ngo'],
      assignedToNgoName: json['assigned_to_ngo_name'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      updates: List<ResourceRequestUpdate>.from(
        json['updates'].map((x) => ResourceRequestUpdate.fromJson(x)),
      ),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'school_id': schoolId,
      'school_name': schoolName,
      'request_title': requestTitle,
      'description': description,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'assigned_to_ngo': assignedToNgo,
      'assigned_to_ngo_name': assignedToNgoName,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'updates': updates.map((x) => x.toJson()).toList(),
    };
  }
  
  // Helper to parse request type
  static ResourceRequestType _parseRequestType(String type) {
    switch (type) {
      case 'projector':
        return ResourceRequestType.projector;
      case 'board':
        return ResourceRequestType.board;
      case 'computer':
        return ResourceRequestType.computer;
      case 'books':
        return ResourceRequestType.books;
      case 'furniture':
        return ResourceRequestType.furniture;
      case 'stationery':
        return ResourceRequestType.stationery;
      case 'other':
        return ResourceRequestType.other;
      default:
        return ResourceRequestType.other;
    }
  }
  
  // Helper to parse request status
  static ResourceRequestStatus _parseRequestStatus(String status) {
    switch (status) {
      case 'pending':
        return ResourceRequestStatus.pending;
      case 'assigned':
        return ResourceRequestStatus.assigned;
      case 'in_progress':
        return ResourceRequestStatus.inProgress;
      case 'completed':
        return ResourceRequestStatus.completed;
      case 'cancelled':
        return ResourceRequestStatus.cancelled;
      default:
        return ResourceRequestStatus.pending;
    }
  }
  
  // Get status color
  Color getStatusColor() {
    switch (status) {
      case ResourceRequestStatus.pending:
        return Colors.orange;
      case ResourceRequestStatus.assigned:
        return Colors.blue;
      case ResourceRequestStatus.inProgress:
        return Colors.purple;
      case ResourceRequestStatus.completed:
        return Colors.green;
      case ResourceRequestStatus.cancelled:
        return Colors.red;
    }
  }
  
  // Get status text
  String getStatusText() {
    switch (status) {
      case ResourceRequestStatus.pending:
        return 'Pending';
      case ResourceRequestStatus.assigned:
        return 'Assigned';
      case ResourceRequestStatus.inProgress:
        return 'In Progress';
      case ResourceRequestStatus.completed:
        return 'Completed';
      case ResourceRequestStatus.cancelled:
        return 'Cancelled';
    }
  }
  
  // Get formatted date
  String get formattedDate => '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  
  // Create a copy with updated fields
  ResourceRequestModel copyWith({
    String? requestTitle,
    String? description,
    ResourceRequestType? type,
    ResourceRequestStatus? status,
    String? assignedToNgo,
    String? assignedToNgoName,
    List<ResourceRequestUpdate>? updates,
  }) {
    return ResourceRequestModel(
      id: this.id,
      schoolId: this.schoolId,
      schoolName: this.schoolName,
      requestTitle: requestTitle ?? this.requestTitle,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      assignedToNgo: assignedToNgo ?? this.assignedToNgo,
      assignedToNgoName: assignedToNgoName ?? this.assignedToNgoName,
      createdAt: this.createdAt,
      updatedAt: DateTime.now(),
      updates: updates ?? this.updates,
    );
  }
  
  // Add an update
  ResourceRequestModel addUpdate(ResourceRequestUpdate update) {
    List<ResourceRequestUpdate> updatedUpdates = [...updates, update];
    return copyWith(
      updates: updatedUpdates,
    );
  }
}

class ResourceRequestUpdate {
  final String id;
  final String userId;
  final String userName;
  final String text;
  final DateTime createdAt;
  
  ResourceRequestUpdate({
    required this.id,
    required this.userId,
    required this.userName,
    required this.text,
    required this.createdAt,
  });
  
  factory ResourceRequestUpdate.fromJson(Map<String, dynamic> json) {
    return ResourceRequestUpdate(
      id: json['id'],
      userId: json['user_id'],
      userName: json['user_name'],
      text: json['text'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'text': text,
      'created_at': createdAt.toIso8601String(),
    };
  }
  
  // Format creation date
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} years ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
}

enum ResourceType {
  document,
  presentation,
  worksheet,
  video,
  link,
  other,
}

enum ResourceRequestType {
  projector,
  board,
  computer,
  books,
  furniture,
  stationery,
  other,
}

enum ResourceRequestStatus {
  pending,
  assigned,
  inProgress,
  completed,
  cancelled,
}

// Import for Color
import 'package:flutter/material.dart';
