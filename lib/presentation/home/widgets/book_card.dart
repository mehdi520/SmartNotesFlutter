import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_book/domain/models/category/data_models/cat_model/cat_model.dart';
import 'package:note_book/infra/pdf/pdf_download_helper.dart';
import 'package:note_book/infra/utils/color_utils.dart';
import 'package:note_book/presentation/blocs/cat_bloc/cat_bloc.dart';

import '../../../infra/core/core_exports.dart';

class BookCard extends StatelessWidget {
  const BookCard({
    super.key,
    required this.title,
    required this.fileCount,
    required this.icon,
    required this.iconColor,
    required this.noteBookId,
    required this.cat
  });

  final String title;
  final String fileCount;
  final String iconColor;
  final IconData icon;
  final int noteBookId;
  final CatModel cat;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: () {
        final bloc = context.read<CatBloc>();
        Navigator.pushNamed(context, AppRoutes.updateNoteBook, arguments: {
          'bloc': bloc,
          'cat': cat,
        });
      },
      onTap: () async {
        final bloc = context.read<CatBloc>();
        await Navigator.pushNamed(context, AppRoutes.note,
            arguments: {'noteBookId': noteBookId, 'title': title});
        // note counts may have changed
        bloc.add(GetCatEvent());
      },
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
              maxWidth: 320, // 💡 This makes it not stretch too wide on web
              minWidth: 250,
              maxHeight: 300,
              minHeight: 110
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 16),
            margin: const EdgeInsets.all(8), // optional spacing around the card
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(60),
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 12,
                  offset: Offset(2, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                        backgroundColor: ColorUtils.colorFromHex(iconColor)
                            .withAlpha(50),
                        child: Icon(
                            icon, color: ColorUtils.colorFromHex(iconColor))
                    ),
                    const Spacer(),
                    if (cat.totalNotes > 0)
                      IconButton(
                        tooltip: 'Download all notes as PDF',
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.download_rounded, color: AppColors.primary),
                        onPressed: () => PdfDownloadHelper.noteBook(context, noteBookId),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16,),
                ),
                Text(fileCount, style: const TextStyle(color: Colors.black54)),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
