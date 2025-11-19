import 'dart:convert';
import 'package:equatable/equatable.dart';
import '../../core/constants/app_roles.dart';

class User extends Equatable {
  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.department,
    this.mobileNumber,
    this.enrolmentNumber,
    this.profilePictureUrl,
    this.collegeIdUrl,
    this.profileCompleted = false,
    this.isApproved = false, // For Staff approval status
  });

  final String id;
  final String name;
  final String email;
  final AppRole role;

  // New Common Fields
  final String? department;
  final String? mobileNumber;
  final String? profilePictureUrl;

  // New Role-Specific Fields
  final String? enrolmentNumber;
  final String? collegeIdUrl;

  final bool profileCompleted;
  final bool isApproved;

  User copyWith({
    String? name,
    String? email,
    AppRole? role,
    String? department,
    String? mobileNumber,
    String? enrolmentNumber,
    String? profilePictureUrl,
    String? collegeIdUrl,
    bool? profileCompleted,
    bool? isApproved,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      department: department ?? this.department,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      enrolmentNumber: enrolmentNumber ?? this.enrolmentNumber,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      collegeIdUrl: collegeIdUrl ?? this.collegeIdUrl,
      profileCompleted: profileCompleted ?? this.profileCompleted,
      isApproved: isApproved ?? this.isApproved,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.name,
      'department': department,
      'mobileNumber': mobileNumber,
      'enrolmentNumber': enrolmentNumber,
      'profilePictureUrl': profilePictureUrl,
      'collegeIdUrl': collegeIdUrl,
      'profileCompleted': profileCompleted,
      'isApproved': isApproved,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      role: AppRole.values.firstWhere(
              (e) => e.name == map['role'],
          orElse: () => AppRole.visitor
      ),
      department: map['department'] as String?,
      mobileNumber: map['mobileNumber'] as String?,
      enrolmentNumber: map['enrolmentNumber'] as String?,
      profilePictureUrl: map['profilePictureUrl'] as String?,
      collegeIdUrl: map['collegeIdUrl'] as String?,
      profileCompleted: map['profileCompleted'] as bool? ?? false,
      isApproved: map['isApproved'] as bool? ?? false,
    );
  }

  String toJson() => json.encode(toMap());
  factory User.fromJson(String source) => User.fromMap(json.decode(source));

  @override
  List<Object?> get props => [id, email, role, profileCompleted, isApproved];
}