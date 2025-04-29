import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_book/data/data_sources/local/HiveManager.dart';
import 'package:note_book/domain/models/category/data_models/cat_model/cat_model.dart';
import 'package:note_book/infra/common/common_widgets/app_bars/basic_app_bar.dart';
import 'package:note_book/infra/common/common_widgets/input_fields/TextInputFormField.dart';
import 'package:note_book/infra/extensions/media_query_extension.dart';
import 'package:note_book/infra/loader/overlay_service.dart';
import 'package:note_book/infra/utils/color_utils.dart';
import 'package:note_book/infra/utils/toast_utils.dart';
import 'package:note_book/presentation/blocs/cat_bloc/cat_bloc.dart';

import '../../infra/common/common_widgets/buttons/PrimaryButton.dart';
import '../../infra/common/common_widgets/text_fields/CommonTextField.dart';
import '../../infra/utils/enums.dart';

class UpdateNoteBookScreen extends StatelessWidget {
  final OverlayService _loadingService = OverlayService();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  CatModel cat;
  UpdateNoteBookScreen({super.key,required this.cat}) {
    _titleController.text = cat.title ?? '';
  }

  void _submitUpdate(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      var user = HiveManager.getUserJson();
      var state = context.read<CatBloc>().state;
      var req = CatModel(
        totalNotes: 0,
        noteBookId: cat.noteBookId,
        userId: user!.id!,
        title: _titleController.text,
        iconColor: state.selectedIconColor,
      );
      context.read<CatBloc>().add(AddupdateCatEvent(req: req));
    }
  }

  void _showDeleteConfirmation(BuildContext context, CatBloc bloc) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Note Book'),
          content: const Text('Are you sure you want to delete this note book? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                bloc.add(DeleteCatEvent(noteBookId: cat.noteBookId));
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Set initial color when screen is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CatBloc>().add(UpdateIconColorEvent(iconColor: cat.iconColor ?? ColorUtils.colorArray[0]));
    });

    return Scaffold(
      appBar: BasicAppBar(title: "Update Note Book"),
      body: BlocListener<CatBloc, CatState>(
        listenWhen:
            (previous, current) => current.apiIdentifier == "add_update" || current.apiIdentifier == "delete",
        listener: (context, state) {
          if (state.apiStatus == ApiStatus.loading) {
            _loadingService.showLoadingOverlay(context);
          }
          print("state " + state.apiStatus.toString());
          if (state.apiStatus == ApiStatus.success) {
            _loadingService.hideLoadingOverlay();
            context.read<CatBloc>().add(GetCatEvent());
            Navigator.pop(context);
          }
          if (state.apiStatus == ApiStatus.error) {
            _loadingService.hideLoadingOverlay();
            ToastUtils.showError(state.resp?.message ?? ' failed');
          }
        },
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.mediaQueryWidth * 0.09,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: context.mediaQueryHeight * 0.05),
                      CommontextField(
                        contentText:
                        'To update a  Note Book/category please make changes in below form.',
                        fontWeight: FontWeight.w300,
                        fontSize: 16,
                      ),
                      SizedBox(height: context.mediaQueryHeight * 0.03),
                      Text(
                        "Select Color",
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children:
                                ColorUtils.colorArray.map((color) {
                                  return GestureDetector(
                                    onTap: () {
                                      context.read<CatBloc>().add(
                                        UpdateIconColorEvent(
                                          iconColor: color,
                                        ),
                                      );
                                      // _selectedColor = ColorUtils.colorFromHex(color);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0,
                                      ),
                                      child: BlocBuilder<CatBloc, CatState>(
                                        builder: (context, state) {
                                          return CircleAvatar(
                                            radius: 30,
                                            backgroundColor:
                                            ColorUtils.colorFromHex(
                                              color,
                                            ),
                                            child:
                                            state.selectedIconColor == color
                                                ? const Icon(
                                              Icons.check,
                                              color: Colors.white,
                                              size: 20,
                                            )
                                                : null,
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Textinputformfield(
                        hintText: 'Enter your book name here',
                        ctrl: _titleController,
                        formLabel: 'Book Name',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Book name is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      const SizedBox(height: 30),
                      PrimaryButton(
                        text: 'Update',
                        onTap: () => _submitUpdate(context),
                      ),
                      const SizedBox(height: 10),
                      PrimaryButton(
                        text: 'Delete',
                          bgColor : Colors.red,
                        onTap: () => _showDeleteConfirmation(context, context.read<CatBloc>()),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
