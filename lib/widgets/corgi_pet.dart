import 'package:flutter/material.dart';

// ==================== 柯基宠物动画 ====================
class CorgiPet extends StatefulWidget {
  final double size;
  final bool isWalking;
  
  const CorgiPet({
    super.key,
    this.size = 120,
    this.isWalking = false,
  });

  @override
  State<CorgiPet> createState() => _CorgiPetState();
}

class _CorgiPetState extends State<CorgiPet> with TickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.isWalking ? 600 : 1200), // 放慢动画速度
    )..repeat();
  }
  
  @override
  void didUpdateWidget(CorgiPet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isWalking != widget.isWalking) {
      _controller.duration = Duration(milliseconds: widget.isWalking ? 400 : 800);
      _controller.repeat();
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final frameIndex = (_controller.value * 4).floor() % 4;
        final folder = widget.isWalking ? 'corgi_walk' : 'corgi_idle';
        return Image.asset(
          'assets/images/$folder/frame$frameIndex.png',
          width: widget.size,
          height: widget.size,
          gaplessPlayback: true,
          errorBuilder: (context, error, stack) => Text('🐕', style: TextStyle(fontSize: widget.size)),
        );
      },
    );
  }
}
