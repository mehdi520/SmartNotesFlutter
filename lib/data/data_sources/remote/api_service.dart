import 'package:note_book/domain/models/auth_models/response_model/login/login_res_model.dart';
import 'package:note_book/domain/models/auth_models/sign_up_req_model.dart';
import 'package:note_book/domain/models/category/data_models/cat_model/cat_model.dart';
import 'package:note_book/domain/models/category/response_models/get_user_cats_res_model/get_user_cats_res_model.dart';
import 'package:note_book/domain/models/common_models/base_response_model.dart';
import 'package:note_book/domain/models/note/data_model/note_data_model.dart';
import 'package:note_book/domain/models/note/req_models/pagination_req_model.dart';
import 'package:note_book/domain/models/note/resp_models/get_notes_res_model.dart';
import 'package:note_book/domain/models/user/req_model/pass_change_req_model.dart';
import 'package:note_book/domain/models/user/response_model/get_profile_res_model.dart';
import 'package:retrofit/http.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../domain/models/user/req_model/update_profile_req_model.dart';
import '../../../infra/core/configs/constants/constants.dart';

part 'api_service.g.dart';

@RestApi(baseUrl: APIBaseURL)
abstract class ApiService {
  factory ApiService(Dio dio) = _ApiService;

  @POST('api/pub/Register')
  Future<HttpResponse<BaseResponseModel>> signup({
    @Body() required SignUpReqModel req,
  });

  @POST('api/pub/login')
  Future<HttpResponse<LoginResModel>> signin({
    @Body() required SignUpReqModel req,
  });

  @GET('api/User/GetProfile')
  Future<HttpResponse<GetProfileResModel>> getProfile();

  @POST('api/user/updateProfile')
  Future<HttpResponse<BaseResponseModel>> updateProfile({
    @Body() required UpdateProfileReqModel req,
  });

  @POST('api/user/changepass')
  Future<HttpResponse<BaseResponseModel>> changePass({
    @Body() required PassChangeReqModel req,
  });

  @GET('api/category/GetUserNotesCats')
  Future<HttpResponse<GetUserCatsResModel>> getUserCats();

  @POST('api/Category/addOrUpdateNoteCat')
  Future<HttpResponse<BaseResponseModel>> addOrUpdateCat({
    @Body() required CatModel req,
  });

  @GET('api/category/delNoteCat')
  Future<HttpResponse<BaseResponseModel>> deleteCat({
    @Query('catId') required int id,
  });

  @POST('api/note/GetUserNotes')
  Future<HttpResponse<GetNotesResModel>> getUserNotes({
    @Body() required PaginationReqModel req,
  });

  @POST('api/note/addOrUpdateNote')
  Future<HttpResponse<BaseResponseModel>> addOrUpdateNote({
    @Body() required NoteDataModel req,
  });

  @GET('api/Note/delNote')
  Future<HttpResponse<BaseResponseModel>> deleteNote({
    @Query('noteId') required int noteId,
  });
}
