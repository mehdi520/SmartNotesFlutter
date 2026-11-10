import 'package:equatable/equatable.dart';

/// Paging info returned by every list API (currentPage, pageSize, totalPage, totalCount).
class PageInfo extends Equatable {
  final int currentPage;
  final int pageSize;
  final int totalPage;
  final int totalCount;

  const PageInfo({
    this.currentPage = 1,
    this.pageSize = 10,
    this.totalPage = 1,
    this.totalCount = 0,
  });

  bool get hasPrevious => currentPage > 1;
  bool get hasNext => currentPage < totalPage;

  @override
  List<Object?> get props => [currentPage, pageSize, totalPage, totalCount];
}
