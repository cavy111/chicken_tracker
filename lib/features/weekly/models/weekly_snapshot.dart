import 'package:hive/hive.dart';

part 'weekly_snapshot.g.dart';

@HiveType(typeId: 4)
class WeeklySnapshot {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String batchId;
  @HiveField(2)
  final DateTime weekStart;
  @HiveField(3)
  final DateTime weekEnd;
  @HiveField(4)
  final int startingStock;
  @HiveField(5)
  final int endingStock;
  @HiveField(6)
  final int soldQuantity;
  @HiveField(7)
  final int feedCostCents;
  @HiveField(8)
  final int expensesCents;
  @HiveField(9)
  final int revenueCents;
  @HiveField(10)
  final int profitCents;
  @HiveField(11)
  final DateTime createdAt;
  @HiveField(12)
  final DateTime updatedAt;

  WeeklySnapshot({
    required this.id,
    required this.batchId,
    required this.weekStart,
    required this.weekEnd,
    required this.startingStock,
    required this.endingStock,
    required this.soldQuantity,
    required this.feedCostCents,
    required this.expensesCents,
    required this.revenueCents,
    required this.profitCents,
    required this.createdAt,
    required this.updatedAt,
  });
}