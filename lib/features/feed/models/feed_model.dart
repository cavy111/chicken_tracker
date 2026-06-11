import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'feed_model.g.dart';

@HiveType(typeId: 2)
class FeedEntry extends Equatable {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String batchId;
  @HiveField(2)
  final String note;
  @HiveField(3)
  final String? imageUrl;
  @HiveField(4)
  final int feedAmount;
  @HiveField(5)
  final DateTime feedTime;
  @HiveField(6)
  final String userId;
  @HiveField(7)
  final DateTime createdAt;
  @HiveField(8)
  final DateTime updatedAt;

  const FeedEntry({
    required this.id,
    required this.batchId,
    required this.note,
    this.imageUrl,
    required this.feedAmount,
    required this.feedTime,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        batchId,
        note,
        imageUrl,
        feedAmount,
        feedTime,
        userId,
        createdAt,
        updatedAt,
      ];

  FeedEntry copyWith({
    String? id,
    String? batchId,
    String? note,
    String? imageUrl,
    int? feedAmount,
    DateTime? feedTime,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FeedEntry(
      id: id ?? this.id,
      batchId: batchId ?? this.batchId,
      note: note ?? this.note,
      imageUrl: imageUrl ?? this.imageUrl,
      feedAmount: feedAmount ?? this.feedAmount,
      feedTime: feedTime ?? this.feedTime,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
