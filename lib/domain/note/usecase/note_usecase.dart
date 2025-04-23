
import 'package:dartz/dartz.dart';
import 'package:note_book/domain/models/note/data_model/note_data_model.dart';
import 'package:note_book/domain/models/note/req_models/pagination_req_model.dart';
import 'package:note_book/domain/note/contract/note_repository.dart';

class NoteUsecase {
  final NoteRepository _repository;

  NoteUsecase(this._repository);

  Future<Either> getNotes(PaginationReqModel req) async {
    return await _repository.getNotes(req);
  }

  Future<Either> addOrUpdateNote(NoteDataModel req) async {
    return await _repository.addUpdateNote(req);
  }

  Future<Either> deleteNote(int id) async {
    return await _repository.delNote(id);
  }
}
