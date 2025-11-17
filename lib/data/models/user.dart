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

  @override
  List<Object?> get props =>
      [id, name, email, role, department, enrolmentNumber, profileCompleted];
}

