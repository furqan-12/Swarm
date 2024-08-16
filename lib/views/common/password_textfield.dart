import "package:regexed_validator/regexed_validator.dart";
import "package:swarm/consts/consts.dart";
import "package:swarm/utils/toast_utils.dart";

class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final bool isPatternValidate;
  final FocusNode? focusNode;

  const PasswordField({
    Key? key,
    required this.hint,
    required this.controller,
    this.isPatternValidate = true,
    this.focusNode,
  }) : super(key: key);

  @override
  _PasswordFieldState createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _showPassword = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        5.heightBox,
        TextFormField(
          obscureText: !_showPassword,
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
              suffixIcon: IconButton(
                icon: _showPassword
                    ? const Icon(Icons.visibility)
                    : const Icon(Icons.visibility_off),
                onPressed: () {
                  setState(() {
                    _showPassword = !_showPassword;
                  });
                },
              ),
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
              ToastHelper.showErrorToast(
                  context,
                  'Password should be at least 6 characters long, '
                  'contain at least one number, one capital letter, '
                  'one small letter.');
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
