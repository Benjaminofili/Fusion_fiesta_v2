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
    this.enrolmentNumber,
    this.profileCompleted = false,
  });

  final String id;
  final String name;
  final String email;
  final AppRole role;
  final String? department;
  final String? enrolmentNumber;
  final bool profileCompleted;

  User copyWith({
    String? name,
    String? email,
    AppRole? role,
    String? department,
    String? enrolmentNumber,
    bool? profileCompleted,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      department: department ?? this.department,
      enrolmentNumber: enrolmentNumber ?? this.enrolmentNumber,
      profileCompleted: profileCompleted ?? this.profileCompleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.name, // Store enum as string
      'department': department,
      'enrolmentNumber': enrolmentNumber,
      'profileCompleted': profileCompleted,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      role: AppRole.values.firstWhere((role) => role.name == map['role'] as String),
      department: map['department'] as String?,
      enrolmentNumber: map['enrolmentNumber'] as String?,
      profileCompleted: map['profileCompleted'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) => User.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  List<Object?> get props =>
      [id, name, email, role, department, enrolmentNumber, profileCompleted];
}

