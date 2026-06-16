// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TransactionModelAdapter extends TypeAdapter<TransactionModel> {
  @override
  final int typeId = 3;

  @override
  TransactionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TransactionModel(
      id: fields[0] as String,
      batchId: fields[1] as String,
      type: fields[2] as String,
      amountCents: fields[3] as int,
      quantity: fields[4] as int?,
      isCredit: fields[5] as bool,
      note: fields[6] as String?,
      date: fields[7] as DateTime,
      userId: fields[8] as String?,
      createdAt: fields[9] as DateTime,
      updatedAt: fields[10] as DateTime,
      creditorName: fields[11] as String?,
      creditDate: fields[12] as DateTime?,
      expectedPaymentDate: fields[13] as DateTime?,
      linkedCreditSaleId: fields[14] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, TransactionModel obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.batchId)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.amountCents)
      ..writeByte(4)
      ..write(obj.quantity)
      ..writeByte(5)
      ..write(obj.isCredit)
      ..writeByte(6)
      ..write(obj.note)
      ..writeByte(7)
      ..write(obj.date)
      ..writeByte(8)
      ..write(obj.userId)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.updatedAt)
      ..writeByte(11)
      ..write(obj.creditorName)
      ..writeByte(12)
      ..write(obj.creditDate)
      ..writeByte(13)
      ..write(obj.expectedPaymentDate)
      ..writeByte(14)
      ..write(obj.linkedCreditSaleId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
