import 'package:flutter/material.dart';
import 'package:sekum/models/decision_tree.dart';

class DecisionTreeDiagramGuru extends StatelessWidget {
  final DecisionTreeNode root;

  DecisionTreeDiagramGuru({required this.root});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(MediaQuery.of(context).size.width * 2,
          MediaQuery.of(context).size.height * 2),
      painter: DecisionTreePainter(root),
    );
  }
}

class DecisionTreePainter extends CustomPainter {
  final DecisionTreeNode root;
  double _verticalSpacing = 150;

  DecisionTreePainter(this.root);

  @override
  void paint(Canvas canvas, Size size) {
    Paint linePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1;

    Paint labelPaint = Paint()..color = Colors.black;

    _drawNode(canvas, root, Offset(size.width / 2, 50), size.width / 1,
        linePaint, labelPaint);
  }

  void _drawNode(Canvas canvas, DecisionTreeNode node, Offset position,
      double xOffset, Paint linePaint, Paint labelPaint) {
    TextSpan span;
    TextPainter tp;
    Offset tpPosition;

    if (node.label != null) {
      Color nodeColor = node.label == 'Biasa' ? Colors.red : Colors.blue;
      Paint nodePaint = Paint()..color = nodeColor;

      // Draw node
      Rect rect = Rect.fromCenter(center: position, width: 100, height: 40);
      canvas.drawRect(rect, nodePaint);

      // Draw label
      span = TextSpan(
        style: TextStyle(color: Colors.white, fontSize: 11),
        text: node.label,
      );

      tp = TextPainter(
        text: span,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );

      tp.layout();
      tpPosition = position - Offset(tp.width / 2, tp.height / 2);
      tp.paint(canvas, tpPosition);
    } else {
      // Draw attribute
      span = TextSpan(
        style: TextStyle(color: Colors.black, fontSize: 14),
        text: node.attribute,
      );

      tp = TextPainter(
        text: span,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );

      tp.layout();
      tpPosition = position - Offset(tp.width / 2, tp.height / 1);
      tp.paint(canvas, tpPosition);
    }

    if (node.children != null) {
      double childXOffset = xOffset / (node.children!.length + 1);
      double childYOffset = _verticalSpacing;

      int i = 1;
      node.children!.forEach((value, childNode) {
        Offset childPosition = Offset(
            position.dx - xOffset / 2 + i * childXOffset,
            position.dy + childYOffset);

        // Draw line
        canvas.drawLine(position, childPosition, linePaint);

        // Draw edge label
        span = TextSpan(
          style: TextStyle(color: Colors.black, fontSize: 9),
          text: value,
        );

        tp = TextPainter(
          text: span,
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
        );

        tp.layout();
        tpPosition = Offset((position.dx + childPosition.dx) / 2 - tp.width / 2,
            (position.dy + childPosition.dy) / 2 - tp.height / 2 - 10);
        tp.paint(canvas, tpPosition);

        _drawNode(canvas, childNode, childPosition, childXOffset, linePaint,
            labelPaint);
        i++;
      });
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
