import 'package:flutter/cupertino.dart';

class IconSpinner extends StatefulWidget {
  final IconData icon;

  final Duration duration;
  final bool isSpinning;

  const IconSpinner({
    Key key,
    @required this.icon,
    this.duration = const Duration(milliseconds: 1800),
    this.isSpinning = false,
  }) : super(key: key);

  @override
  _IconSpinnerState createState() => _IconSpinnerState();
}

class _IconSpinnerState extends State<IconSpinner> with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Widget _child;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2000),
    );
    _child = Icon(widget.icon);

    super.initState();
  }

  stopRotation() {
    _controller.stop();
  }

  startRotation() {
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    widget.isSpinning ? startRotation() : stopRotation();

    return RotationTransition(
      turns: _controller,
      child: _child,
    );
  }
}
