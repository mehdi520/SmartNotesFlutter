import 'package:flutter/material.dart';
import 'package:note_book/infra/extensions/media_query_extension.dart';

import '../../infra/common/common_widgets/app_bars/basic_app_bar.dart';
import '../../infra/common/common_widgets/buttons/PrimaryButton.dart';
import '../../infra/common/common_widgets/input_fields/TextInputFormField.dart';
import '../../infra/common/common_widgets/text_fields/CommonTextField.dart';

class ProfileScreen extends StatelessWidget {
   ProfileScreen({super.key});
  final _formKey = GlobalKey<FormState>();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passController = TextEditingController();




  void _submitLogin(){
    print("func called");
    if(_formKey.currentState!.validate())
    {

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: BasicAppBar(title: "Profile",),
        body:  SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Center(
              child:  Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: context.mediaQueryWidth * 0.1, // Make horizontal padding dynamic
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    SizedBox(height: context.mediaQueryHeight * 0.05,),
                    CommontextField(contentText: 'To update your profile please fill below form.', fontWeight: FontWeight.w300,fontSize: 16,),
                    SizedBox(height: context.mediaQueryHeight * 0.03,),

                    SizedBox(height: 15),
                    Textinputformfield(hintText: 'Enter your name here',ctrl: _emailController, formLabel: 'Name',
                      validator: (value){
                        if(value == null || value.isEmpty)
                        {
                          return 'Name is required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10,),
                    Textinputformfield(hintText: 'Enter your name here',ctrl: _emailController, formLabel: 'Name',
                      validator: (value){
                        if(value == null || value.isEmpty)
                        {
                          return 'Name is required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10,),
                    Textinputformfield(hintText: 'Enter your name here',ctrl: _emailController, formLabel: 'Name',
                      validator: (value){
                        if(value == null || value.isEmpty)
                        {
                          return 'Name is required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10,),
                    SizedBox(height: 30,),
                    PrimaryButton(text: 'Save',onTap: _submitLogin,),
                    SizedBox(height: 20,),
                    //  _dont_have_Acc(context)

                  ],
                ),
              ),
            ),
          ),
        )
    );
  }
}
