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

  // New fields (append indices)
  @HiveField(10)
  final int initialStock;
  @HiveField(11)
  final int currentStock;
  @HiveField(12)
  final int cashInHandCents;
  @HiveField(13)
  final int outstandingCreditCents;

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
    this.initialStock = 0,
    this.currentStock = 0,
    this.cashInHandCents = 0,
    this.outstandingCreditCents = 0,
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
        initialStock,
        currentStock,
        cashInHandCents,
        outstandingCreditCents,
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
    int? initialStock,
    int? currentStock,
    int? cashInHandCents,
    int? outstandingCreditCents,
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
      initialStock: initialStock ?? this.initialStock,
      currentStock: currentStock ?? this.currentStock,
      cashInHandCents: cashInHandCents ?? this.cashInHandCents,
      outstandingCreditCents: outstandingCreditCents ?? this.outstandingCreditCents,
    );
  }
}