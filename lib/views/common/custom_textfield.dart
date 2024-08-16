import "package:swarm/consts/consts.dart";
import 'package:regexed_validator/regexed_validator.dart';

Widget customTextFiled(
    {String? hint,
    TextEditingController? controller,
    bool? isRequired,
    bool? isEmail}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      5.heightBox,
      TextFormField(
        obscureText: false,
        controller: controller,
        decoration: InputDecoration(
            hintStyle: const TextStyle(
              fontFamily: milligramRegular,
              color: universalBlackPrimary,
            ),
            hintText: hint,
            isDense: true,
            fillColor: Vx.white,
            filled: true,
            border: const OutlineInputBorder(
              borderSide: BorderSide(
                color: universalBlackTertiary,
                width: 2.0,
              ),
              borderRadius: BorderRadius.all(Radius.circular(2.0)),
            ),
            focusedBorder: const OutlineInputBorder(
                borderSide:
                    BorderSide(color: universalBlackTertiary, width: 2.0))),
        validator: (value) {
          if (isRequired == true && (value == null || value.isEmpty)) {
            return '$hint is required';
          }
          if (isEmail == true &&
              value != null &&
              value.isNotEmpty &&
              !validator.email(value)) {
            return 'Invalid email format';
          }
          return null;
        },
      ),
      5.heightBox,
    ],
  );
}
