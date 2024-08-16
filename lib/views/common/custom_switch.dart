

import '../../consts/consts.dart';

class CustomSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  CustomSwitch({Key? key, required this.value, required this.onChanged})
      : super(key: key);

  @override
  _CustomSwitchState createState() => _CustomSwitchState();
}

class _CustomSwitchState extends State<CustomSwitch>
    with SingleTickerProviderStateMixin {
  Animation? _circleAnimation;
  AnimationController? _animationController;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    _circleAnimation = AlignmentTween(
            begin: widget.value ? Alignment.centerRight : Alignment.centerLeft,
            end: widget.value ? Alignment.centerLeft : Alignment.centerRight)
        .animate(CurvedAnimation(
            parent: _animationController!, curve: Curves.linear));
  }
  

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController!,
      builder: (context, child) {
        return GestureDetector(
          onTap: () {
        setState(() {
          widget.onChanged(!widget.value);
        });

        if (_animationController!.isCompleted) {
          _animationController!.reverse();
        } else {
          _animationController!.forward();
        }
      },
          child: Container(
            width: 200.0,
            height: 60.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40.0),
              color: _circleAnimation!.value == Alignment.centerLeft
                  ? universalWhitePrimary
                  : universalColorPrimaryDefault,
            ),
            child: Row(
              children: [
                Container(
                  width: 60.0,
                  height: 60.0,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: universalColorPrimaryLight),
                      child: SizedBox(
                        height: 20,
                        width: 20,
                        child: Image.asset('assets/icons/lock.png',width: 20,height: 20,)),
                ),
                5.widthBox,
                Text("Slide to unlock")
              ],
            ),
          ),
        );
      },
    );
  }
   @override
  void dispose() {
    _animationController!.dispose();
    super.dispose();
  }
}
