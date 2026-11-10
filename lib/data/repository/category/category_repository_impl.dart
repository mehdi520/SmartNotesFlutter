import 'package:dartz/dartz.dart';
import 'package:note_book/data/data_sources/remote/api_service.dart';
import 'package:note_book/data/repository/api_call.dart';
import 'package:note_book/domain/category/contract/category_repository.dart';
import 'package:note_book/domain/models/category/data_models/cat_model/cat_model.dart';
import 'package:note_book/domain/models/category/response_models/get_user_cats_res_model/get_user_cats_res_model.dart';

class CategoryRepositoryImpl extends CategoryRepository {
  final ApiService _apiService;

  CategoryRepositoryImpl(this._apiService);

  @override
  Future<Either> addOrUpdateCat(CatModel req) => retrofitCall(() => _apiService.addOrUpdateCat(req: req));

  @override
  Future<Either> deleteCat(int id) => retrofitCall(() => _apiService.deleteCat(id: id));

  /// Notebook pages are cached for offline use (search results are not).
  @override
  Future<Either> getCategories({int pageNo = 0, int pageSize = 10, String? search}) {
    final searching = search != null && search.trim().isNotEmpty;
    return cachedApiCall<GetUserCatsResModel>(
      cacheKey: searching ? null : 'cats:$pageNo:$pageSize',
      call: () async => (await _apiService.getUserCats(pageNo: pageNo, pageSize: pageSize, search: search)).data,
      toJson: (d) => d.toJson(),
      fromCache: GetUserCatsResModel.fromCache,
    );
  }
}
