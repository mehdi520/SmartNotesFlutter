import 'package:flutter/material.dart';
import 'package:note_book/infra/extensions/media_query_extension.dart';

import '../../infra/common/common_widgets/app_bars/basic_app_bar.dart';
import '../../infra/common/common_widgets/buttons/PrimaryButton.dart';
import '../../infra/common/common_widgets/input_fields/TextInputFormField.dart';
import '../../infra/common/common_widgets/text_fields/CommonTextField.dart';

class AddUpdateNoteScreen extends StatelessWidget {
  AddUpdateNoteScreen({super.key});
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();



  void _submitLogin(){
    print("func called");
    if(_formKey.currentState!.validate())
    {

    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: BasicAppBar(title: "New Note",),
        body:  Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.mediaQueryWidth * 0.09, // Make horizontal padding dynamic
          ),
          child: Form(
              key: _formKey,
              child: Center(

                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10,),
                      TextField(
                        controller: _titleController,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: const InputDecoration(
                          hintText: "Enter note title here",
                          border: UnderlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            "12-12-2024",
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            "10:20 AM",
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: SingleChildScrollView(
                          child: TextField(
                            controller: _contentController,
                            maxLines: null,
                            expands: false, // This allows the TextField to grow naturally
                            keyboardType: TextInputType.multiline,
                            decoration: const InputDecoration(
                              hintText: "Enter your note details here",
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 30,),
                      PrimaryButton(text: 'Save', onTap: _submitLogin),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),


    );
  }

}
