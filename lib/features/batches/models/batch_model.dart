import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'batch_model.g.dart';

@HiveType(typeId: 1)
class Batch extends Equatable {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String description;
  @HiveField(3)
  final int chickenCount;
  @HiveField(4)
  final DateTime startDate;
  @HiveField(5)
  final DateTime? endDate;
  @HiveField(6)
  final String userId;
  @HiveField(7)
  final bool isActive;
  @HiveField(8)
  final DateTime createdAt;
  @HiveField(9)
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
