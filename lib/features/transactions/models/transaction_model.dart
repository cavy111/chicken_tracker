import 'package:hive/hive.dart';

part 'transaction_model.g.dart';

@HiveType(typeId: 3)
class TransactionModel {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String batchId;
  @HiveField(2)
  final String type; // sale, withdrawal, expense, credit_sale, credit_payment
  @HiveField(3)
  final int amountCents;
  @HiveField(4)
  final int? quantity;
  @HiveField(5)
  final bool isCredit;
  @HiveField(6)
  final String? note;
  @HiveField(7)
  final DateTime date;
  @HiveField(8)
  final String? userId;
  @HiveField(9)
  final DateTime createdAt;
  @HiveField(10)
  final DateTime updatedAt;

  TransactionModel({
    required this.id,
    required this.batchId,
    required this.type,
    required this.amountCents,
    this.quantity,
    this.isCredit = false,
    this.note,
    required this.date,
    this.userId,
    required this.createdAt,
    required this.updatedAt,
  });
}