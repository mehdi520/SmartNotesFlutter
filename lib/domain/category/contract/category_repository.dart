

import 'package:dartz/dartz.dart';

import '../../models/category/data_models/cat_model/cat_model.dart';

abstract class CategoryRepository{
  Future<Either> getCategories();
  Future<Either> addOrUpdateCat(CatModel req);
  Future<Either> deleteCat(int id);
}