import "package:regexed_validator/regexed_validator.dart";
import "package:swarm/consts/consts.dart";

class UpdatePasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final bool isPatternValidate;
  final FocusNode? focusNode;
  final bool isPasswordVisible;
  final Function(bool) onToggleVisibility;

  const UpdatePasswordField({
    Key? key,
    required this.hint,
    required this.controller,
    this.isPatternValidate = true,
    this.focusNode,
    required this.isPasswordVisible,
    required this.onToggleVisibility,
  }) : super(key: key);

  @override
  _UpdatePasswordFieldState createState() => _UpdatePasswordFieldState();
}

class _UpdatePasswordFieldState extends State<UpdatePasswordField> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        5.heightBox,
        TextFormField(
          obscureText: !widget.isPasswordVisible,
          controller: widget.controller,
          autofillHints: widget.isPatternValidate == false
              ? [AutofillHints.password]
              : [AutofillHints.newPassword],
          focusNode: widget.focusNode,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
              hintStyle: const TextStyle(
                fontFamily: milligramRegular,
                color: universalBlackPrimary,
              ),
              hintText: widget.hint,
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
            if (value == null || value.isEmpty) {
              return '${widget.hint} is required';
            }
            if (widget.isPatternValidate == true &&
                !validator.mediumPassword(value)) {
              return 'Min 6 letters, 1 digit and 1 capital letter';
            }
            return null;
          },
        ),
        5.heightBox,
      ],
    );
  }
}
