import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:chronos/core/constants/app_colors.dart';
import 'package:chronos/data/models/task_model.dart';

// ==========================================
// 1. DATA MODEL
// ==========================================

class MindMapNode {
  final String id;
  final String title;
  final bool completed;
  final int level;
  bool isExpanded;
  final List<MindMapNode> children;

  MindMapNode({
    required this.id,
    required this.title,
    required this.completed,
    required this.level,
    this.isExpanded = true,
    List<MindMapNode>? children,
  }) : children = children ?? [];
}

// ==========================================
// 2. STICKY TREE WIDGET (RENDER OBJECT FIXED)
// ==========================================

class TreeBranchLayout extends MultiChildRenderObjectWidget {
  final Color connectionColor;
  final double indent;

  const TreeBranchLayout({
    super.key,
    required this.connectionColor,
    this.indent = 50.0, // Độ dài đường nối ngang
    required super.children,
  });

  @override
  RenderTreeBranch createRenderObject(BuildContext context) {
    return RenderTreeBranch(
      connectionColor: connectionColor,
      indent: indent,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderTreeBranch renderObject) {
    renderObject
      ..connectionColor = connectionColor
      ..indent = indent;
  }
}

class RenderTreeBranch extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, MultiChildLayoutParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, MultiChildLayoutParentData> {
  Color _connectionColor;
  double _indent;

  RenderTreeBranch({
    required Color connectionColor,
    required double indent,
  })  : _connectionColor = connectionColor,
        _indent = indent;

  set connectionColor(Color value) {
    if (_connectionColor != value) {
      _connectionColor = value;
      markNeedsPaint();
    }
  }

  set indent(double value) {
    if (_indent != value) {
      _indent = value;
      markNeedsLayout();
    }
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! MultiChildLayoutParentData) {
      child.parentData = MultiChildLayoutParentData();
    }
  }

  @override
  void performLayout() {
    if (firstChild == null) {
      size = Size.zero;
      return;
    }

    double maxWidth = 0.0;
    double currentY = 0.0;

    // Tạo constraint cho con: Chiều rộng phải nhỏ hơn (Tổng rộng - indent)
    // Để tránh text tràn màn hình hoặc không xuống dòng
    final BoxConstraints childConstraints = constraints.copyWith(
      minWidth: 0,
      maxWidth: constraints.maxWidth == double.infinity
          ? double.infinity
          : (constraints.maxWidth - _indent).clamp(0, double.infinity),
    );

    RenderBox? child = firstChild;
    while (child != null) {
      final MultiChildLayoutParentData childParentData =
      child.parentData as MultiChildLayoutParentData;

      // Layout con với kích thước tự nhiên
      child.layout(childConstraints, parentUsesSize: true);

      // Đặt vị trí con: X luôn cách lề trái một đoạn `indent`
      // Y xếp chồng lên nhau
      childParentData.offset = Offset(_indent, currentY);

      // Tính toán kích thước tổng
      if (child.size.width > maxWidth) maxWidth = child.size.width;
      currentY += child.size.height;

      // Khoảng cách dọc giữa các node con (Spacing)
      if (childParentData.nextSibling != null) {
        currentY += 24.0; // Tăng khoảng cách để thoáng hơn
      }

      child = childParentData.nextSibling;
    }

    // Kích thước của widget này = (Indent + Con rộng nhất, Tổng chiều cao các con)
    size = Size(maxWidth + _indent, currentY);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final Canvas canvas = context.canvas;
    final Paint paint = Paint()
      ..color = _connectionColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    // Điểm neo của Cha: Chính giữa chiều cao của Widget này, nằm sát lề trái
    final Offset parentAnchor = offset + Offset(0, size.height / 2);

    RenderBox? child = firstChild;
    while (child != null) {
      final MultiChildLayoutParentData childParentData =
      child.parentData as MultiChildLayoutParentData;

      // Tìm tâm Y thực tế của con đang xét
      final double childCenterY = childParentData.offset.dy + (child.size.height / 2);

      // Điểm neo của Con: Sát lề trái của con (tức là offset + indent)
      final Offset childAnchor = offset + Offset(_indent, childCenterY);

      // Vẽ đường cong Bezier
      final Path path = Path();
      path.moveTo(parentAnchor.dx, parentAnchor.dy);

      final double midX = (parentAnchor.dx + childAnchor.dx) / 2;
      path.cubicTo(
          midX, parentAnchor.dy, // Control point 1: Kéo ngang từ Cha
          midX, childAnchor.dy,  // Control point 2: Kéo ngang vào Con
          childAnchor.dx, childAnchor.dy
      );

      canvas.drawPath(path, paint);

      child = childParentData.nextSibling;
    }

    // Vẽ nội dung các con đè lên đường kẻ
    defaultPaint(context, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}

// ==========================================
// 3. NODE WIDGET (ĐÃ SỬA GIAO DIỆN)
// ==========================================

class MindMapNodeWidget extends StatelessWidget {
  final MindMapNode node;
  final bool isRoot;
  final Color themeColor;
  final VoidCallback onUpdate;

  const MindMapNodeWidget({
    super.key,
    required this.node,
    this.isRoot = false,
    required this.themeColor,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    // SỬA ĐỔI QUAN TRỌNG: Dùng Row với CrossAxisAlignment.center
    // Bỏ IntrinsicHeight để tránh lỗi layout overlap
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // A. NỘI DUNG NODE
        GestureDetector(
          onTap: () {
            if (node.children.isNotEmpty) {
              node.isExpanded = !node.isExpanded;
              onUpdate();
            }
          },
          child: _buildNodeBox(context),
        ),

        // B. NHÁNH CON (Sử dụng TreeBranchLayout đã fix lỗi)
        if (node.children.isNotEmpty && node.isExpanded)
          TreeBranchLayout(
            connectionColor: themeColor.withOpacity(0.5),
            indent: 50.0,
            children: node.children.map((child) => MindMapNodeWidget(
              node: child,
              themeColor: themeColor,
              onUpdate: onUpdate,
            )).toList(),
          ),

        // C. BADGE KHI ĐÓNG (Thu gọn)
        if (node.children.isNotEmpty && !node.isExpanded)
          Container(
            margin: const EdgeInsets.only(left: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: themeColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: themeColor.withOpacity(0.5)),
            ),
            child: Text(
              "${node.children.length}",
              style: TextStyle(fontSize: 10, color: themeColor, fontWeight: FontWeight.bold),
            ),
          ),
      ],
    );
  }

  Widget _buildNodeBox(BuildContext context) {
    final bool hasChildren = node.children.isNotEmpty;

    // Giới hạn chiều rộng để text xuống dòng đẹp hơn
    double maxWidth = isRoot ? 250 : 200;

    return Container(
      constraints: BoxConstraints(
        maxWidth: maxWidth,
        minWidth: 80,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isRoot ? 20 : 16,
        vertical: isRoot ? 16 : 12,
      ),
      decoration: BoxDecoration(
        color: isRoot ? themeColor.withOpacity(0.1) : AppColors.cardDark,
        borderRadius: BorderRadius.circular(isRoot ? 16 : 12),
        border: Border.all(
          color: node.completed
              ? Colors.white10
              : themeColor.withOpacity(isRoot ? 0.8 : 0.4),
          width: isRoot ? 2 : 1,
        ),
        boxShadow: isRoot && !node.completed
            ? [BoxShadow(color: themeColor.withOpacity(0.2), blurRadius: 20, spreadRadius: 1)]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row chứa Icon + Title
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (node.completed)
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(Icons.check_circle, size: 14, color: Colors.grey),
                )
              else if (hasChildren)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(
                      node.isExpanded ? Icons.remove_circle_outline : Icons.add_circle_outline,
                      size: 14,
                      color: themeColor
                  ),
                ),

              if (hasChildren || node.completed) const SizedBox(width: 8),

              // TEXT NỘI DUNG (Quan trọng: Không dùng Flexible ở đây để tránh lỗi size)
              Flexible(
                child: Text(
                  node.title,
                  style: TextStyle(
                    fontSize: isRoot ? 14 : 12,
                    fontWeight: isRoot ? FontWeight.w900 : FontWeight.w500,
                    color: node.completed ? Colors.grey : Colors.white,
                    decoration: node.completed ? TextDecoration.lineThrough : null,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 4. MAIN SCREEN & UTILS
// ==========================================

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    const double step = 40;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class MindMapView extends StatefulWidget {
  final TaskModel task;
  const MindMapView({super.key, required this.task});

  @override
  State<MindMapView> createState() => _MindMapViewState();
}

class _MindMapViewState extends State<MindMapView> {
  late MindMapNode _rootNode;
  final TransformationController _transformController = TransformationController();

  @override
  void initState() {
    super.initState();
    _rootNode = _buildTreeData(widget.task);
    // Zoom out vừa phải
    _transformController.value = Matrix4.identity()..translate(50.0, 300.0)..scale(0.8);
  }

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  MindMapNode _buildTreeData(TaskModel task) {
    MindMapNode root = MindMapNode(
      id: "root",
      title: task.title,
      completed: task.completed,
      level: -1,
      isExpanded: true,
      children: [],
    );
    if (task.subtasks == null || task.subtasks!.isEmpty) return root;

    List<MindMapNode> flatNodes = task.subtasks!.map((st) =>
        MindMapNode(
          id: st.id ?? DateTime.now().toString(),
          title: st.title ?? 'No title',
          completed: st.completed,
          level: st.level,
          isExpanded: true,
          children: [],
        )
    ).toList();
    return _assembleTree(root, flatNodes);
  }

  MindMapNode _assembleTree(MindMapNode parent, List<MindMapNode> remaining) {
    int i = 0;
    while (i < remaining.length) {
      if (remaining[i].level == parent.level + 1) {
        MindMapNode child = remaining[i];
        List<MindMapNode> descendants = [];
        int j = i + 1;
        while (j < remaining.length && remaining[j].level > child.level) {
          descendants.add(remaining[j]);
          j++;
        }
        parent.children.add(_assembleTree(child, descendants));
        i = j;
      } else {
        i++;
      }
    }
    return parent;
  }

  @override
  Widget build(BuildContext context) {
    final Color themeColor = widget.task.priority == 'Cao'
        ? Colors.redAccent
        : (widget.task.priority == 'Trung bình' ? Colors.amber : AppColors.primary);

    return Scaffold(
      backgroundColor: const Color(0xFF090E11),
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _GridPainter())),
          InteractiveViewer(
            transformationController: _transformController,
            boundaryMargin: const EdgeInsets.all(3000),
            minScale: 0.1, maxScale: 5.0, constrained: false,
            child: Padding(
              padding: const EdgeInsets.all(200.0),
              // Bỏ IntrinsicHeight ở đây, chỉ cần Center
              child: MindMapNodeWidget(
                node: _rootNode,
                isRoot: true,
                themeColor: themeColor,
                onUpdate: () => setState(() {}),
              ),
            ),
          ),
          Positioned(
            top: 50, left: 20,
            child: Row(
              children: [
                IconButton.filled(
                  onPressed: () => Navigator.pop(context),
                  style: IconButton.styleFrom(backgroundColor: Colors.white10),
                  icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("VISION MAP", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: themeColor, letterSpacing: 2)),
                    const SizedBox(height: 4),
                    Text(widget.task.title.length > 25 ? "${widget.task.title.substring(0, 25)}..." : widget.task.title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                  ],
                )
              ],
            ),
          ),
          Positioned(
            right: 24, bottom: 40,
            child: Column(
              children: [
                _zoomBtn(Icons.add, () => _transformController.value = _transformController.value.clone()..scale(1.2)),
                const SizedBox(height: 12),
                _zoomBtn(Icons.remove, () => _transformController.value = _transformController.value.clone()..scale(0.8)),
                const SizedBox(height: 12),
                _zoomBtn(Icons.center_focus_strong, () => setState(() => _transformController.value = Matrix4.identity()..scale(0.85))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _zoomBtn(IconData icon, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(color: AppColors.surfaceDark.withOpacity(0.9), shape: BoxShape.circle, border: Border.all(color: Colors.white12)),
      child: IconButton(icon: Icon(icon, color: Colors.white), onPressed: onTap),
    );
  }
}