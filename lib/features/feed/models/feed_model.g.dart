// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FeedEntryAdapter extends TypeAdapter<FeedEntry> {
  @override
  final int typeId = 2;

  @override
  FeedEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FeedEntry(
      id: fields[0] as String,
      batchId: fields[1] as String,
      note: fields[2] as String,
      imageUrl: fields[3] as String?,
      feedAmount: fields[4] as int,
      feedTime: fields[5] as DateTime,
      userId: fields[6] as String,
      createdAt: fields[7] as DateTime,
      updatedAt: fields[8] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, FeedEntry obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.batchId)
      ..writeByte(2)
      ..write(obj.note)
      ..writeByte(3)
      ..write(obj.imageUrl)
      ..writeByte(4)
      ..write(obj.feedAmount)
      ..writeByte(5)
      ..write(obj.feedTime)
      ..writeByte(6)
      ..write(obj.userId)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FeedEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
