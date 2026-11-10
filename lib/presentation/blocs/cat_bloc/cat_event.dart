part of 'cat_bloc.dart';

abstract class CatEvent {

}

/// Load notebooks. Leave [pageNo] / [search] null to keep the current page / search
/// (e.g. refresh after add / update / delete). A new search should pass pageNo: 1.
class GetCatEvent extends CatEvent{
  final int? pageNo;
  final String? search;

  GetCatEvent({this.pageNo, this.search});
}

class AddupdateCatEvent extends CatEvent{
  final CatModel req;

  AddupdateCatEvent({
    required this.req
});
}

class UpdateIconColorEvent extends CatEvent{
  final String iconColor;

  UpdateIconColorEvent({
    required this.iconColor
  });
}
class DeleteCatEvent extends CatEvent {
  final int noteBookId;
  DeleteCatEvent({
    required this.noteBookId
});
}
