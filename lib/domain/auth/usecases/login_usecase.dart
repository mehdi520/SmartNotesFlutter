//
//
// import 'package:dartz/dartz.dart';
// import 'package:note_book/domain/auth/contract/auth_repository.dart';
// import 'package:note_book/domain/models/auth_models/sign_up_req_model.dart';
//
// import '../../../infra/core/core_exports.dart';
// import '../../../infra/di/service_locator.dart';
//
//
// class LoginUsecase extends Usecase<Either,SignUpReqModel>
// {
//   @override
//   Future<Either> call({SignUpReqModel? params}) async {
//    return await sl<AuthRepository>().signin(params!);
//   }
//
// }