import 'package:flutter/material.dart';
import 'package:note_book/infra/common/common_widgets/app_bars/basic_app_bar.dart';
import 'package:note_book/infra/common/common_widgets/input_fields/TextInputFormField.dart';
import 'package:note_book/infra/extensions/media_query_extension.dart';
import 'package:note_book/infra/utils/color_utils.dart';

import '../../infra/common/common_widgets/buttons/PrimaryButton.dart';
import '../../infra/common/common_widgets/text_fields/CommonTextField.dart';
import '../../infra/core/core_exports.dart';

class AddUpdateCat extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passController = TextEditingController();

  Color _selectedColor = ColorUtils.getDefaultColor();
  

   AddUpdateCat({super.key});

  void _submitLogin(){
    print("func called");
    if(_formKey.currentState!.validate())
    {

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BasicAppBar(title: "Note Book",),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 1000
              ),
              child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.mediaQueryWidth * 0.09, // Make horizontal padding dynamic
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: context.mediaQueryHeight * 0.05),
                      CommontextField(
                        contentText: 'To create a new Note Book/category please fill below form.',
                        fontWeight: FontWeight.w300,
                        fontSize: 16,
                      ),
                      SizedBox(height: context.mediaQueryHeight * 0.03),

                      // Color Picker with Book Icon above
                      Text("Select Color", style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      )),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // Wrapping the color picker in an Expanded widget for better responsive layout
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: ColorUtils.colorArray.map((color) {
                                  return GestureDetector(
                                    onTap: () {
                                      // Handle color selection
                                      // setState(() {
                                      //   _selectedColor = color; // Update selected color
                                      // });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                      child: CircleAvatar(
                                        radius: 30,
                                        backgroundColor: ColorUtils.colorFromHex(color),
                                        child: _selectedColor == color
                                            ? Icon(Icons.check, color: Colors.white, size: 20)
                                            : null,
                                        foregroundColor: _selectedColor == color
                                            ? Colors.black
                                            : null,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      Textinputformfield(
                        hintText: 'Enter your book name here',
                        ctrl: _emailController,
                        formLabel: 'Book Name',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Book name is required';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                      SizedBox(height: 30),

                      // "Save" button should stick at the bottom of the screen
                      PrimaryButton(
                        text: 'Save',
                        onTap: _submitLogin,
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
          ),
          ),
        ),

    );
  }

}
