// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weekly_snapshot.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WeeklySnapshotAdapter extends TypeAdapter<WeeklySnapshot> {
  @override
  final int typeId = 4;

  @override
  WeeklySnapshot read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WeeklySnapshot(
      id: fields[0] as String,
      batchId: fields[1] as String,
      weekStart: fields[2] as DateTime,
      weekEnd: fields[3] as DateTime,
      startingStock: fields[4] as int,
      endingStock: fields[5] as int,
      soldQuantity: fields[6] as int,
      feedCostCents: fields[7] as int,
      expensesCents: fields[8] as int,
      revenueCents: fields[9] as int,
      profitCents: fields[10] as int,
      createdAt: fields[11] as DateTime,
      updatedAt: fields[12] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, WeeklySnapshot obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.batchId)
      ..writeByte(2)
      ..write(obj.weekStart)
      ..writeByte(3)
      ..write(obj.weekEnd)
      ..writeByte(4)
      ..write(obj.startingStock)
      ..writeByte(5)
      ..write(obj.endingStock)
      ..writeByte(6)
      ..write(obj.soldQuantity)
      ..writeByte(7)
      ..write(obj.feedCostCents)
      ..writeByte(8)
      ..write(obj.expensesCents)
      ..writeByte(9)
      ..write(obj.revenueCents)
      ..writeByte(10)
      ..write(obj.profitCents)
      ..writeByte(11)
      ..write(obj.createdAt)
      ..writeByte(12)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeeklySnapshotAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
