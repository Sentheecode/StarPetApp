import 'package:flutter/material.dart';

// ==================== 可移动家具组件 ====================
class FurnitureItem extends StatefulWidget {
  final String emoji;
  final double size;
  final double initialX;
  final double initialY;
  final String name;
  final Function(double x, double y)? onPositionChanged;
  
  const FurnitureItem({
    super.key,
    required this.emoji,
    this.size = 60,
    this.initialX = 0,
    this.initialY = 0,
    this.name = '',
    this.onPositionChanged,
  });

  @override
  State<FurnitureItem> createState() => _FurnitureItemState();
}

class _FurnitureItemState extends State<FurnitureItem> {
  late double _x;
  late double _y;
  bool _isDragging = false;
  
  @override
  void initState() {
    super.initState();
    _x = widget.initialX;
    _y = widget.initialY;
  }
  
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _x,
      top: _y,
      child: GestureDetector(
        onLongPressStart: (_) => setState(() => _isDragging = true),
        onLongPressEnd: (_) => setState(() => _isDragging = false),
        onPanUpdate: (details) {
          setState(() {
            _x += details.delta.dx;
            _y += details.delta.dy;
          });
          widget.onPositionChanged?.call(_x, _y);
        },
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            border: _isDragging 
              ? Border.all(color: Colors.orange, width: 2) 
              : null,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Text(
                widget.emoji,
                style: TextStyle(fontSize: widget.size),
              ),
              if (_isDragging)
                Text(
                  widget.name,
                  style: const TextStyle(fontSize: 10, color: Colors.orange),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
