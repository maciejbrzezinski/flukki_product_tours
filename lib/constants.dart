import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class FlukkiContants {
  static const productToursPreferencesKey = '_flukkiProductTours';

  static const double borderRadius = 4.0;

  static const backgroundColor = Color(0xffEDEDF6);
  static final cardColor = const Color(0xff7E7D95).withOpacity(.2);
  static final cardPlaceholderColor = const Color(0xff7E7D95).withOpacity(.3);

  static final errorTextColor = Colors.red.withOpacity(.3);
  static final errorBackgroundColor = Colors.red.withOpacity(.1);

  static final regularButtonBackgroundColor =
      regularButtonTextColor.withOpacity(.1);
  static final regularButtonBackgroundColorHover =
      regularButtonTextColor.withOpacity(.3);
  static const regularButtonTextColor = Color(0xff08ABB9);

  static final greyButtonBackgroundColor =
      const Color(0xff040446).withOpacity(.1);
  static final greyButtonBackgroundColorHover =
      greyButtonBackgroundColor.withOpacity(.2);
  static const greyButtonTextColor = Color(0xff20202B);

  static const accentButtonBackgroundColor = regularButtonTextColor;
  static const accentButtonBackgroundColorHover = Color(0xff007781);
  static const accentButtonTextColor = Color(0xffF2F3FD);

  static final ButtonStyle accentButtonStyle = ButtonStyle(
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius))),
      shadowColor: const MaterialStatePropertyAll(Colors.transparent),
      padding: kIsWeb ? const MaterialStatePropertyAll(EdgeInsets.all(20)) : const MaterialStatePropertyAll(EdgeInsets.all(8)),
      backgroundColor: MaterialStateProperty.resolveWith((state) =>
          state.contains(MaterialState.hovered)
              ? accentButtonBackgroundColorHover
              : accentButtonBackgroundColor),
      foregroundColor: const MaterialStatePropertyAll(accentButtonTextColor));

  static ButtonStyle get regularButtonStyle => ButtonStyle(
        shadowColor: const MaterialStatePropertyAll(Colors.transparent),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius))),
        padding: kIsWeb ? const MaterialStatePropertyAll(EdgeInsets.all(20)) : const MaterialStatePropertyAll(EdgeInsets.all(8)),
        backgroundColor: MaterialStateProperty.resolveWith((state) =>
            state.contains(MaterialState.hovered)
                ? regularButtonBackgroundColorHover
                : regularButtonBackgroundColor),
        foregroundColor: const MaterialStatePropertyAll(regularButtonTextColor),
      );

  static final ButtonStyle greyButtonStyle = ButtonStyle(
    shadowColor: const MaterialStatePropertyAll(Colors.transparent),
    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius))),
    padding: const MaterialStatePropertyAll(EdgeInsets.all(20)),
    alignment: Alignment.center,
    backgroundColor: MaterialStateProperty.resolveWith((state) =>
        state.contains(MaterialState.hovered)
            ? greyButtonBackgroundColorHover
            : greyButtonBackgroundColor),
    foregroundColor: const MaterialStatePropertyAll(greyButtonTextColor),
  );

  static InputDecoration textInputDecoration({String? name}) => InputDecoration(
      labelText: name,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius)));
}
