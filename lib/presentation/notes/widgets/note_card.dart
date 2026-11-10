import 'package:flutter/material.dart';
import 'package:note_book/infra/utils/date_utils.dart';

import '../../../infra/core/core_exports.dart';

class NoteCard extends StatelessWidget {
  final String title;
  final String category;
  final String date;
  final String content;
  final int attachmentCount;
  final VoidCallback onTap;
  final VoidCallback? onDownload;

  const NoteCard({
    super.key,
    required this.title,
    required this.category,
    required this.date,
    required this.content,
    required this.onTap,
    this.attachmentCount = 0,
    this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 4, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  if (onDownload != null)
                    IconButton(
                      tooltip: 'Download PDF',
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.picture_as_pdf_outlined, color: AppColors.primary),
                      onPressed: onDownload,
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(category,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey.shade600)),
                    ),
                    if (attachmentCount > 0) ...[
                      Icon(Icons.attach_file, size: 16, color: Colors.grey.shade600),
                      Text('$attachmentCount', style: TextStyle(color: Colors.grey.shade600)),
                      const SizedBox(width: 10),
                    ],
                    Text(
                      DateUtil.getDateFromServerDate(date),
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Text(
                  content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
