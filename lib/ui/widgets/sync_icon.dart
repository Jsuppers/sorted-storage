import 'package:flutter/material.dart';

/// A widget which shows a spinning icon for a duration
class IconSpinner extends StatefulWidget {
  const IconSpinner({
    Key key,
    @required this.icon,
    this.duration = const Duration(milliseconds: 3600),
    this.isSpinning = false,
    this.color = Colors.black,
  }) : super(key: key);

  final IconData icon;
  final Duration duration;
  final bool isSpinning;
  final Color color;

  @override
  _IconSpinnerState createState() => _IconSpinnerState();
}

class _IconSpinnerState extends State<IconSpinner>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Widget _child;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _child = Icon(widget.icon, color: widget.color);

    super.initState();
  }

  void _stopRotation() => _controller.stop();
  void _startRotation() => _controller.repeat();


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    widget.isSpinning ? _startRotation() : _stopRotation();

    return RotationTransition(
      turns: _controller,
      child: _child,
    );
  }
}
