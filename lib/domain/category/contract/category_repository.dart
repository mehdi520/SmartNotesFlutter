import 'package:dartz/dartz.dart';
import '../../models/category/data_models/cat_model/cat_model.dart';

abstract class CategoryRepository{
  /// pageNo = 0 returns all notebooks.
  Future<Either> getCategories({int pageNo = 0, int pageSize = 10, String? search});
  Future<Either> addOrUpdateCat(CatModel req);
  Future<Either> deleteCat(int id);
}