import 'package:flutter/material.dart';
import 'package:fitmom_guide/core/utils/my_color.dart';
import '../../../../core/utils/style.dart';

class AuthTextInput extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool isPassword;
  final bool isDatePicker;

  const AuthTextInput({
    super.key,
    required this.controller,
    required this.hintText,
    this.isPassword = false,
    this.isDatePicker = false,
  });

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      controller.text = "${pickedDate.day}-${pickedDate.month}-${pickedDate.year}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: regularDefault,
        textAlign: TextAlign.center,
        readOnly: isDatePicker, 
        onTap: isDatePicker ? () => _selectDate(context) : null,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: regularSmall,
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                const BorderSide(color: MyColor.secondaryColor, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                const BorderSide(color: MyColor.secondaryColor, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                const BorderSide(color: MyColor.secondaryColor, width: 1.5),
          ),
        ),
      ),
    );
  }
}
