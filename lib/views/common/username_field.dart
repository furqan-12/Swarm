import "package:swarm/consts/consts.dart";
import 'package:regexed_validator/regexed_validator.dart';

Widget usernameFiled(
    {String? hint,
    TextEditingController? controller,
    FocusNode? focusNode,
    bool? isRequired,
    bool? isEmail,
    bool? fromLogin}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      5.heightBox,
      TextFormField(
        autofillHints: fromLogin == true
            ? [AutofillHints.username]
            : [AutofillHints.newUsername],
        obscureText: false,
        controller: controller,
        focusNode: focusNode,
        textInputAction: TextInputAction.next,
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
