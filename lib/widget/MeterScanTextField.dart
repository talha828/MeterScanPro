import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meter_scan/constant/constant.dart';
import 'package:meter_scan/generated/assets.dart';

class MeterScanTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final String label;
  String? value;
  final bool obscureText;
  final IconData? prefixIcon;
  final Widget? prefixIconWidget;
  final dynamic suffixIcon;
  final IconData? suffixIconData;
  final bool isDropdown;
  final List<String>? countryCodeList;

  MeterScanTextField(
      {required this.controller,
        required this.hintText,
        this.value,
        this.prefixIcon,
        this.suffixIconData,
        required this.label,
        this.prefixIconWidget,
        this.obscureText = false,
        this.suffixIcon,
        this.isDropdown = false,
        this.countryCodeList,
        super.key});

  @override
  State<MeterScanTextField> createState() => _MeterScanTextFieldState();
}

class _MeterScanTextFieldState extends State<MeterScanTextField> {
  String selectedItem = "+92";
  bool obscureText = false;
  void _togglePasswordVisibility() {
    setState(() {
      obscureText = !obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: width * 0.04,
              ),
        ),
        SizedBox(height: width * 0.04),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: fillColor,
          ),
          child: Row(
            children: [
              // Prefix Icon or Dropdown
              Container(
                padding: const EdgeInsets.only(left: 8),
                child: widget.isDropdown
                    ? Row(
                  children: [
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isDense: true,
                        value: selectedItem,
                        onChanged: (newValue) {
                          widget.value = newValue;
                          setState(() => selectedItem = newValue!);
                        },
                        items: widget.countryCodeList!
                            .map((String countryCode) {
                          return DropdownMenuItem<String>(
                            value: countryCode,
                            child: Text(countryCode),
                          );
                        }).toList(),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                      child: VerticalDivider(
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                )
                    : Icon(
                  widget.prefixIcon,
                  color: themeColor1.withOpacity(0.2),
                ),
              ),
              // Text Input Field
              Expanded(
                child: TextField(
                  obscureText: obscureText,
                  controller: widget.controller,
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    hintStyle: GoogleFonts.montserrat(
                      textStyle: TextStyle(
                        fontSize: width * 0.04,
                      ),
                    ),
                    border: InputBorder.none,
                    contentPadding:
                    const EdgeInsets.symmetric(horizontal: 10.0),
                  ),
                ),
              ),
              // Suffix Icon
              if (widget.suffixIcon != null)
                Container(
                  padding: const EdgeInsets.all(8.0),
                  child: widget.suffixIcon is IconData
                      ? GestureDetector(
                    onTap: widget.obscureText
                        ? _togglePasswordVisibility
                        : () {},
                    child: obscureText
                        ? Icon(
                      widget.suffixIcon,
                      size: 24.0, // Adjust the size as needed
                    )
                        : Image.asset(
                      Assets.assetsHideEye,
                      width: 24.0, // Adjust the size as needed
                      height: 24.0, // Adjust the size as needed
                    ),
                  )
                      : Image.asset(
                    widget.suffixIcon,
                    width: 24.0, // Adjust the size as needed
                    height: 24.0, // Adjust the size as needed
                  ),
                ),
              // If suffixIcon is null, use an empty SizedBox
            ],
          ),
        ),
      ],
    );
  }
}
