import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_book/domain/models/category/data_models/cat_model/cat_model.dart';
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
    return BlocBuilder<CatBloc, CatState>(
      builder: (context, state) {
        return InkWell(
          onLongPress: () {
            final bloc = context.read<CatBloc>();
            Navigator.pushNamed(context, AppRoutes.updateNoteBook, arguments: {
              'bloc': bloc,
              'cat': cat,
            });
          },
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.note, arguments: noteBookId);
          },
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  maxWidth: 320, // 💡 This makes it not stretch too wide on web
                  minWidth: 250,
                  maxHeight: 300,
                  minHeight: 110
              ),
              child: Container(
                padding: EdgeInsets.all(16),
                margin: EdgeInsets.all(8), // optional spacing around the card
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
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
                    CircleAvatar(
                        backgroundColor: ColorUtils.colorFromHex(iconColor)
                            .withAlpha(50),
                        child: Icon(
                            icon, color: ColorUtils.colorFromHex(iconColor))
                    ),
                    const SizedBox(height: 16),
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16,),
                    ),
                    Text(fileCount, style: TextStyle(color: Colors.black54)),

                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
