import 'package:equatable/equatable.dart';

class Batch extends Equatable {
  final String id;
  final String name;
  final String description;
  final int chickenCount;
  final DateTime startDate;
  final DateTime? endDate;
  final String userId;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Batch({
    required this.id,
    required this.name,
    required this.description,
    required this.chickenCount,
    required this.startDate,
    this.endDate,
    required this.userId,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        chickenCount,
        startDate,
        endDate,
        userId,
        isActive,
        createdAt,
        updatedAt,
      ];

  Batch copyWith({
    String? id,
    String? name,
    String? description,
    int? chickenCount,
    DateTime? startDate,
    DateTime? endDate,
    String? userId,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Batch(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      chickenCount: chickenCount ?? this.chickenCount,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      userId: userId ?? this.userId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
