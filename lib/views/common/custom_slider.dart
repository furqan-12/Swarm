import 'package:swarm/consts/consts.dart';

class CustomSlider extends StatefulWidget {
  final bool initialValue;
  final ValueChanged<bool> onChanged;

  const CustomSlider({
    Key? key,
    required this.initialValue,
    required this.onChanged,
  }) : super(key: key);

  @override
  _CustomSliderState createState() => _CustomSliderState();
}

class _CustomSliderState extends State<CustomSlider>
    with TickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _thumbAnimation;
  bool _value;

  _CustomSliderState() : _value = false;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    )..addListener(() {
        setState(() {});
      });

    _thumbAnimation =
        Tween<double>(begin: 0.0, end: 110.0).animate(_controller!)
          ..addListener(() {
            setState(() {});
          });

    if (_value) {
      _controller!.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_controller != null) {
      setState(() {
        double delta = details.primaryDelta! /
            170; // Use the slider's width for conversion
        _controller!.value += delta;
      });
    }
  }

  void _onDragEnd(DragEndDetails details) {
    if (_controller != null) {
      if (_controller!.value >= 0.5) {
        _controller!.animateTo(1.0);
        if (!_value) {
          _value = true;
          widget.onChanged(_value);
        }
      } else {
        _controller!.animateTo(0.0);
        if (_value) {
          _value = false;
          widget.onChanged(_value);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      child: Container(
        width: 170,
        height: 60,
        decoration: BoxDecoration(
          color: _value ? universalColorPrimaryDefault : universalWhitePrimary,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (_controller !=
                null) // Ensures _controller is initialized before using it.
              AnimatedBuilder(
                animation: _controller!,
                builder: (_, __) {
                  return Positioned(
                    left: _thumbAnimation!.value,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _value
                            ? universalColorPrimaryLight
                            : universalColorPrimaryDefault,
                      ),
                      child: Center(
                        child: _value
                            ? Image.asset(
                                'assets/icons/unlock_p.png',
                                fit: BoxFit.fill,
                                width: 40,
                                height: 40,
                              )
                            : Image.asset(
                                'assets/icons/lock_p.png',
                                fit: BoxFit.fill,
                                width: 40,
                                height: 40,
                              ),
                      ),
                    ),
                  );
                },
              ),
            Positioned(
              left: 65,
              child: _value
                  ? Container()
                  : Text(
                      '',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontFamily: milligramSemiBold),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
