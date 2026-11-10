
import 'package:equatable/equatable.dart';

class BaseResponseModel extends Equatable{
  final bool status;
  final String? message;
  final int? code;
  /// Id of the saved record (returned by create/update APIs).
  final int? id;

  const BaseResponseModel({
    required this.status,
    this.message,
    this.code,
    this.id,
});

  @override
  List<Object?> get props => [status,message,id];

  factory BaseResponseModel.fromJson(Map < String, dynamic > map) {
    return BaseResponseModel(
      status: map['status'] ?? false,
      message: map['message'] ?? "",
      code: map['code'] ?? 0,
      id: (map['id'] as num?)?.toInt(),
    );
  }
}
