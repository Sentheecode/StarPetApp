import 'package:flutter/material.dart';

// ==================== 黑白博美宠物动画 ====================
class PomeranianBWPet extends StatefulWidget {
  final double size;
  final bool isWalking;
  
  const PomeranianBWPet({
    super.key,
    this.size = 80,
    this.isWalking = false,
  });

  @override
  State<PomeranianBWPet> createState() => _PomeranianBWPetState();
}

class _PomeranianBWPetState extends State<PomeranianBWPet> with TickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.isWalking ? 600 : 1200),
    )..repeat();
  }
  
  @override
  void didUpdateWidget(PomeranianBWPet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isWalking != widget.isWalking) {
      _controller.duration = Duration(milliseconds: widget.isWalking ? 600 : 1200);
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
        final folder = widget.isWalking ? 'pomeranian_bw_walk' : 'pomeranian_bw_idle';
        return Transform.scale(
          scaleX: -1, // 镜像翻转，与柯基方向一致
          child: Image.asset(
            'assets/images/$folder/frame$frameIndex.png',
            width: widget.size,
            height: widget.size,
            gaplessPlayback: true,
            errorBuilder: (context, error, stack) => Text('🐕', style: TextStyle(fontSize: widget.size)),
          ),
        );
      },
    );
  }
}
