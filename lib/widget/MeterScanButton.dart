
import 'package:flutter/material.dart';
import 'package:meter_scan/constant/constant.dart';

class MeterScanButton extends StatelessWidget {
  const MeterScanButton({
    super.key,
    required this.onTap,
    required this.width,
    required this.label,
  });

  final void Function()? onTap;
  final double width;
  final String label;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: width * 0.04,horizontal: width * 0.04),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: themeColor1,
            borderRadius: BorderRadius.circular(50)
        ),
        child:Text(label,style: const TextStyle(color: fillColor,fontWeight: FontWeight.w600),),
      ),
    );
  }
}
