part of 'cat_bloc.dart';

abstract class CatEvent {

}

class GetCatEvent extends CatEvent{

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