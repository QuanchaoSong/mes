// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ProductLineExceptionTypeItemModel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductLineExceptionTypeItemModel _$ProductLineExceptionTypeItemModelFromJson(
    Map<String, dynamic> json) {
  return ProductLineExceptionTypeItemModel(
    json['ID'] as int,
    json['ParentCode'] as String,
    json['Code'] as String,
    json['Value'] as String,
    json['Type'] as int,
    json['TypeDesc'] as bool,
    json['Desc'] as String,
    json['Remark'] as String,
    json['Delflag'] as bool,
    json['CreateTime'] as String,
    json['Creator'] as String,
    json['RowVersion'] as String,
  );
}

Map<String, dynamic> _$ProductLineExceptionTypeItemModelToJson(
        ProductLineExceptionTypeItemModel instance) =>
    <String, dynamic>{
      'ID': instance.ID,
      'ParentCode': instance.ParentCode,
      'Code': instance.Code,
      'Value': instance.Value,
      'Type': instance.Type,
      'TypeDesc': instance.TypeDesc,
      'Desc': instance.Desc,
      'Remark': instance.Remark,
      'Delflag': instance.Delflag,
      'CreateTime': instance.CreateTime,
      'Creator': instance.Creator,
      'RowVersion': instance.RowVersion,
    };
