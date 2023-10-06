
import 'package:flutter/material.dart';

class CustomCheckboxWithForgetPassword extends StatelessWidget {
  final Function()? onCheckboxTap;
  final Function()? onForgetPasswordTap;
  final bool isChecked;
  final bool isForgetPassword;

  const CustomCheckboxWithForgetPassword({
    required this.onCheckboxTap,
    required this.onForgetPasswordTap,
    required this.isChecked,
    required this.isForgetPassword,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Row(
          children: [
            InkWell(
              onTap: onCheckboxTap,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: Colors.grey.shade200,
                ),
                child: Center(
                  child: isChecked
                      ? Icon(
                          Icons.check,
                          size: 14,
                          color: Theme.of(context).primaryColor,
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(width: 8.0),
            Text(
              'Remember Me',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
        isForgetPassword
            ? InkWell(
                onTap: onForgetPasswordTap,
                child: Text(
                  'Forget Password?',
                  style: TextStyle(
                    color:
                        Theme.of(context).primaryColor, // Customize the color
                    decoration: TextDecoration.underline,
                  ),
                ),
              )
            : const SizedBox(),
      ],
    );
  }
}
