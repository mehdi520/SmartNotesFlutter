import 'package:dartz/dartz.dart';
import 'package:note_book/domain/models/note/data_model/note_data_model.dart';
import 'package:note_book/domain/models/note/req_models/pagination_req_model.dart';


abstract class NoteRepository {
  Future<Either> getNotes(PaginationReqModel req);
  Future<Either> addUpdateNote(NoteDataModel req);
  Future<Either> delNote(int note_id);
}