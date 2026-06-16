// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'batch_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BatchAdapter extends TypeAdapter<Batch> {
  @override
  final int typeId = 1;

  @override
  Batch read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Batch(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      chickenCount: fields[3] as int,
      startDate: fields[4] as DateTime,
      endDate: fields[5] as DateTime?,
      userId: fields[6] as String,
      isActive: fields[7] as bool,
      createdAt: fields[8] as DateTime,
      updatedAt: fields[9] as DateTime,
      initialStock: (fields[10] as int?) ?? 0,
      currentStock: (fields[11] as int?) ?? 0,
      cashInHandCents: (fields[12] as int?) ?? 0,
      outstandingCreditCents: (fields[13] as int?) ?? 0,
      salePriceCents: (fields[14] as int?) ?? 0,
      stockCostCents: (fields[15] as int?) ?? 0,
    );
  }

  @override
  void write(BinaryWriter writer, Batch obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.chickenCount)
      ..writeByte(4)
      ..write(obj.startDate)
      ..writeByte(5)
      ..write(obj.endDate)
      ..writeByte(6)
      ..write(obj.userId)
      ..writeByte(7)
      ..write(obj.isActive)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.updatedAt)
      ..writeByte(10)
      ..write(obj.initialStock)
      ..writeByte(11)
      ..write(obj.currentStock)
      ..writeByte(12)
      ..write(obj.cashInHandCents)
      ..writeByte(13)
      ..write(obj.outstandingCreditCents)
      ..writeByte(14)
      ..write(obj.salePriceCents)
      ..writeByte(15)
      ..write(obj.stockCostCents);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BatchAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
