// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bill.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BillAdapter extends TypeAdapter<Bill> {
  @override
  final int typeId = 1;

  @override
  Bill read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Bill(
      id: fields[0] as String,
      customerName: fields[1] as String,
      customerEmail: fields[2] as String,
      date: fields[3] as DateTime,
      items: (fields[4] as List).cast<BillItem>(),
      gstPercent: fields[5] as double,
      sgstPercent: fields[6] as double,
      whatsappNumber: fields[7] as String,
      invoiceNumber: fields[8] as String,
      customerAddress: fields[9] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Bill obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.customerName)
      ..writeByte(2)
      ..write(obj.customerEmail)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.items)
      ..writeByte(5)
      ..write(obj.gstPercent)
      ..writeByte(6)
      ..write(obj.sgstPercent)
      ..writeByte(7)
      ..write(obj.whatsappNumber)
      ..writeByte(8)
      ..write(obj.invoiceNumber)
      ..writeByte(9)
      ..write(obj.customerAddress);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BillAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
