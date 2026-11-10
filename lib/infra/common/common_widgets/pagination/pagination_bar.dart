import 'package:flutter/material.dart';
import 'package:note_book/domain/models/common_models/page_info.dart';

import '../../../core/core_exports.dart';

/// "Page 2 of 5 · 43 notes" with first / previous / next / last buttons.
class PaginationBar extends StatelessWidget {
  final PageInfo pageInfo;
  /// Singular / plural name of the items, e.g. ('note', 'notes').
  final String itemName;
  final String itemNamePlural;
  final ValueChanged<int> onPageChanged;
  final bool enabled;

  const PaginationBar({
    super.key,
    required this.pageInfo,
    required this.onPageChanged,
    this.itemName = 'note',
    this.itemNamePlural = 'notes',
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final p = pageInfo;
    final total = '${p.totalCount} ${p.totalCount == 1 ? itemName : itemNamePlural}';
    final canBack = enabled && p.hasPrevious;
    final canNext = enabled && p.hasNext;

    Widget btn(IconData icon, String tooltip, bool on, int page) => IconButton(
          visualDensity: VisualDensity.compact,
          tooltip: tooltip,
          icon: Icon(icon),
          color: AppColors.primary,
          disabledColor: Colors.grey.shade400,
          onPressed: on ? () => onPageChanged(page) : null,
        );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Row(
        children: [
          btn(Icons.first_page, 'First page', canBack, 1),
          btn(Icons.chevron_left, 'Previous page', canBack, p.currentPage - 1),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Page ${p.currentPage} of ${p.totalPage}',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                Text(total, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              ],
            ),
          ),
          btn(Icons.chevron_right, 'Next page', canNext, p.currentPage + 1),
          btn(Icons.last_page, 'Last page', canNext, p.totalPage),
        ],
      ),
    );
  }
}
