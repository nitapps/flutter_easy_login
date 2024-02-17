import 'package:flutter/material.dart';

/// Empty SizedBox with height or width for spacing in row or column
const sizedBoxWithHeight10 = SizedBox(height: 10,);
const sizedBoxWithWidth10 = SizedBox(width: 10,);
const sizedBoxWithWidth5 = SizedBox(width: 5,);

/// Valid Email format Regex
const emailRegex = r'^(?=.{1,64}@)([a-zA-Z\d]+([\.\-_]?[a-zA-Z\d]+)*)@(?=.{4,63}$)([a-zA-Z\d]+([\.\-]?[a-zA-Z\d]+)*\.[a-zA-Z\d]{2,})$';

/// TextStyle with [fontSize] 14
///
/// [color] the color of the font, if not provided color based con current theme is used.
///
/// [isBold] whether the font should be bold(true) or not(false), if not
/// provided by default text will be non bold.
class SmallTextStyle extends TextStyle{
  const SmallTextStyle({Color? color, bool? isBold = false}): super(
      color: color,
      fontWeight: isBold != null && isBold ? FontWeight.bold : null,
      fontSize: 14
  );
}

/// TextStyle with [fontSize] 16
///
/// [color] the color of the font, if not provided color based con current theme is used.
///
/// [isBold] whether the font should be bold(true) or not(false), if not
/// provided by default text will be non bold.
class MediumTextStyle extends TextStyle{
  const MediumTextStyle({Color? color, bool? isBold = false}): super(
      color: color,
      fontWeight: isBold != null && isBold ? FontWeight.bold : null,
      fontSize: 16
  );
}

/// TextStyle with [fontSize] 22.
///
/// [color] the color of the font, if not provided color based con current theme is used.
///
/// [isBold] whether the font should be bold(true) or not(false), if not
/// provided by default text will be non bold.
class LargeTextStyle extends TextStyle{
  const LargeTextStyle({Color? color, bool? isBold = false}): super(
      color: color,
      fontWeight: isBold != null && isBold ? FontWeight.bold : null,
      fontSize: 22
  );
}