import 'package:dartz/dartz.dart';
import 'package:note_book/domain/category/contract/category_repository.dart';
import 'package:note_book/domain/models/category/data_models/cat_model/cat_model.dart';

class CategoryUseCases {
  final CategoryRepository _repository;

  CategoryUseCases(this._repository);

  Future<Either> getCats() async {
    return await _repository.getCategories();
  }

  Future<Either> addOrUpdateCat(CatModel req) async {
    return await _repository.addOrUpdateCat(req);
  }

  Future<Either> deleteCat(int id) async {
    return await _repository.deleteCat(id);
  }
}
