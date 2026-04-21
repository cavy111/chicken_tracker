import 'package:equatable/equatable.dart';

class FeedEntry extends Equatable {
  final String id;
  final String batchId;
  final String note;
  final String? imageUrl;
  final int feedAmount;
  final DateTime feedTime;
  final String userId;
  final DateTime createdAt;
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
