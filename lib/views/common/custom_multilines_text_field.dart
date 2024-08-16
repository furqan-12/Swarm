import "package:swarm/consts/consts.dart";

Widget customMultilineTextFiled(
    {String? name,
    String? hint,
    TextEditingController? controller,
    int? maxLength,
    bool? isRequired,
    int maxLines = 6}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      5.heightBox,
      TextFormField(
        obscureText: false,
        controller: controller,
        maxLines: maxLines,
        maxLength: maxLength,
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
                color: universalLightGary,
                width: 2.0,
              ),
              borderRadius: BorderRadius.all(Radius.circular(2.0)),
            ),
            focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: universalLightGary, width: 2.0))),
        validator: (value) {
          if (isRequired == true && (value == null || value.isEmpty)) {
            return '$name is required';
          }
          return null;
        },
      ),
      5.heightBox,
    ],
  );
}
