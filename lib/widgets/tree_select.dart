import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tree_select/models/tree_node.dart';

class TreeSelect extends StatefulWidget {
  const TreeSelect({required this.onChanged, required this.items, required this.value, this.validator, this.hintText, this.flatten = false, super.key});

  final List<TreeNode> value;
  final String? hintText;
  final List<TreeNode> items;
  final String? Function(String?)? validator;
  final void Function(List<TreeNode>?) onChanged;
  final bool flatten;

  @override
  State<TreeSelect> createState() => _TreeSelectState();
}

class _TreeSelectState<T> extends State<TreeSelect> with TickerProviderStateMixin {
  bool _isOpen = false;
  OverlayEntry? _overlayEntry;
  late TextEditingController _controller;
  late Animation<double> _expandAnimation;
  final LayerLink _layerLink = LayerLink();
  final FocusNode _focusNode = FocusNode();
  late final AnimationController _animationController;
  final Map<String, bool> _collapsed = <String, bool>{};

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.join('; '));
    _focusNode.addListener(() => _toggleDropDown(close: !_focusNode.hasFocus));
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _expandAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextFormField(
        maxLines: 1,
        readOnly: true,
        onTap: _closeIfOpen,
        focusNode: _focusNode,
        scrollPhysics: const NeverScrollableScrollPhysics(),
        controller: _controller,
        style: const TextStyle(
          fontSize: 12,
          overflow: TextOverflow.ellipsis,
          color: Color.fromRGBO(204, 204, 204, 1),
        ),
        decoration: InputDecoration(
          isDense: true,
          hintText: widget.hintText,
          contentPadding: const EdgeInsets.fromLTRB(8, 2, 100, 8),
          suffixIconConstraints: const BoxConstraints(maxHeight: 22),
          suffixIcon: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
            Container(
              margin: const EdgeInsets.all(2),
              padding: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color.fromRGBO(204, 204, 204, 1)),
              ),
              child: Text(
                '${widget.value.length}',
                style: const TextStyle(color: Color.fromRGBO(255, 255, 255, 1), fontSize: 10),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down, color: Color.fromRGBO(51, 75, 225, 1)),
            const SizedBox(width: 8),
          ]),
        ),
      ),
    );
  }

  OverlayEntry _createOverlayEntry() {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Size size = renderBox.size;

    return OverlayEntry(builder: (BuildContext context) {
      return Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height + 11),
          child: Material(
            elevation: 0,
            color: const Color.fromRGBO(26, 26, 26, 1),
            shape: const RoundedRectangleBorder(side: BorderSide(width: 1, color: Color.fromRGBO(51, 75, 225, 1))),
            child: SizeTransition(
              axisAlignment: 1,
              sizeFactor: _expandAnimation,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 350),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color.fromRGBO(64, 64, 64, 1)))),
                    child: Row(children: <Widget>[
                      GestureDetector(
                        onTap: _selectAll,
                        child: Row(children: <Widget>[
                          Container(
                            width: 16,
                            height: 16,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(13, 13, 13, 1),
                              border: Border.all(color: const Color.fromRGBO(51, 75, 255, 1)),
                            ),
                            child: _buildSelectAllIcon(),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${_totalItems == widget.value.length ? 'Des' : 'S'}elect All',
                            style: const TextStyle(fontSize: 12, color: Color.fromRGBO(204, 204, 204, 1)),
                          ),
                        ]),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: _expandAll,
                        child: Text(
                          _collapsed.length == _totalNodes ? 'Collapse All' : 'Expand All',
                          style: const TextStyle(fontSize: 12, color: Color.fromRGBO(204, 204, 204, 1)),
                        ),
                      ),
                      const SizedBox(width: 12)
                    ]),
                  ),
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: widget.items.length,
                      itemBuilder: (BuildContext context, int index) => _buildTree(widget.items[index]),
                    ),
                  ),
                  if (widget.value.isNotEmpty) _buildSelected(),
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: const BoxDecoration(
                      color: Color.fromRGBO(38, 38, 38, 1),
                      border: Border(top: BorderSide(color: Color.fromRGBO(64, 64, 64, 1))),
                    ),
                    child: Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
                      MaterialButton(
                        height: 24,
                        minWidth: 60,
                        elevation: 0,
                        color: const Color.fromRGBO(13, 13, 13, 1),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: const RoundedRectangleBorder(side: BorderSide(color: Color(0XFF808080))),
                        child: const Text('Done', style: TextStyle(color: Color.fromRGBO(204, 204, 204, 1), fontSize: 12, fontWeight: FontWeight.w400)),
                        onPressed: () {
                          widget.onChanged(widget.value);
                          _closeIfOpen();
                        },
                      ),
                      const SizedBox(width: 5),
                      MaterialButton(
                        height: 24,
                        elevation: 0,
                        minWidth: 62.45,
                        onPressed: () => _closeIfOpen(),
                        color: const Color.fromRGBO(51, 51, 51, 1),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: const RoundedRectangleBorder(side: BorderSide(color: Color.fromRGBO(13, 13, 13, 1))),
                        child: const Text('Cancel', style: TextStyle(color: Color.fromRGBO(204, 204, 204, 1), fontSize: 12, fontWeight: FontWeight.w400)),
                      ),
                    ]),
                  ),
                ]),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildTree(TreeNode node, {double padding = 0}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
      InkWell(
        onTap: () => _toggleNode(node),
        child: Container(
          padding: EdgeInsets.only(left: 8 + padding, top: 8, bottom: 8),
          decoration: BoxDecoration(
            color: _itemBg(node),
            border: const Border(bottom: BorderSide(color: Color.fromRGBO(64, 64, 64, 1))),
          ),
          child: Row(children: <Widget>[
            if (node.children?.isNotEmpty ?? false)
              GestureDetector(
                onTap: () => _expandSection(node),
                child: Icon(_expandedIcon(node), color: const Color.fromRGBO(204, 204, 204, 1)),
              )
            else
              const SizedBox(width: 24),
            CustomCheck(child: _icon(node)),
            const SizedBox(width: 8),
            Text(
              node.label,
              style: TextStyle(
                fontWeight: widget.value.contains(node) ? FontWeight.w600 : FontWeight.w400,
                color: widget.value.contains(node) ? const Color.fromRGBO(255, 255, 255, 1) : const Color.fromRGBO(204, 204, 204, 1),
              ),
            ),
          ]),
        ),
      ),
      if (_collapsed.containsKey(node.value) && _collapsed[node.value]!)
        Padding(
          padding: const EdgeInsets.only(left: 0),
          child: Column(children: node.children?.map<Widget>((child) => _buildTree(child, padding: 16 + padding)).toList() ?? <Widget>[]),
        ),
    ]);
  }

  Widget? _icon(TreeNode node) {
    // Check if is leaf node
    if (node.children?.isEmpty ?? true) {
      if (widget.value.contains(node)) {
        return SvgPicture.asset('assets/check.svg', width: 15.04, height: 15.04);
      }
    } else {
      final allChildrenSelected = node.children!.every((element) => widget.value.contains(element));
      if (allChildrenSelected) {
        return SvgPicture.asset('assets/check.svg', width: 15.04, height: 15.04);
      } else {
        final someSelected = _children(node).any((element) => widget.value.contains(element));
        if (someSelected) {
          return Container(color: const Color(0xFF6678FF), height: 1, width: 11.2);
        }
      }
    }

    return null;
  }

  Widget _buildSelected() {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: const BoxDecoration(color: Color.fromRGBO(13, 13, 13, 1)),
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.start,
        children: List.generate(
          widget.value.length,
          (int index) => Directionality(
            textDirection: TextDirection.ltr,
            child: RawChip(
              padding: EdgeInsets.zero,
              label: Text('${widget.value[index]}'),
              labelPadding: const EdgeInsets.only(left: 5),
              visualDensity: const VisualDensity(vertical: -4),
              deleteIcon: SvgPicture.asset('assets/close.svg'),
              onDeleted: () => _toggleNode(widget.value[index]),
              backgroundColor: const Color.fromRGBO(26, 26, 26, 1),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              side: const BorderSide(color: Color.fromRGBO(51, 51, 51, 1)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              labelStyle: const TextStyle(color: Color.fromRGBO(204, 204, 204, 1), fontSize: 12, height: 0),
            ),
          ),
        ),
      ),
    );
  }

  List<TreeNode> _children(TreeNode parent) {
    List<TreeNode> children = <TreeNode>[];
    void traverse(TreeNode currentNode) {
      for (var child in currentNode.children ?? <TreeNode>[]) {
        children.add(child); // Add the current child as an inner node
        traverse(child); // Recursively traverse the child's subtree
      }
    }

    traverse(parent);

    return children;
  }

  IconData _expandedIcon(TreeNode node) {
    return _collapsed.containsKey(node.value) && _collapsed[node.value]! ? Icons.keyboard_arrow_down_rounded : Icons.keyboard_arrow_right;
  }

  Widget? _buildSelectAllIcon() {
    if (_totalItems == widget.value.length) {
      return SvgPicture.asset('assets/check.svg', width: 15.04, height: 15.04);
    } else {
      if (widget.value.isNotEmpty) {
        return Container(color: const Color(0xFF6678FF), height: 1, width: 11.2);
      }
    }

    return null;
  }

  Color _itemBg(TreeNode node) {
    if (node.children?.isNotEmpty ?? false) {
      return const Color.fromRGBO(38, 38, 38, 1);
    }

    return widget.value.contains(node) ? const Color.fromRGBO(51, 51, 51, 1) : const Color.fromRGBO(26, 26, 26, 1);
  }

  void _toggleDropDown({bool close = false}) async {
    if (_isOpen || close) {
      await _animationController.reverse();
      _overlayEntry?.remove();
      setState(() => _isOpen = false);
    } else {
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(_overlayEntry!);
      setState(() => _isOpen = true);
      _animationController.forward();
    }
  }

  void _closeIfOpen() {
    if (_isOpen) {
      _focusNode.unfocus();
      _toggleDropDown(close: true);
    }
  }

  void _toggleNode(TreeNode node) {
    setState(() {
      if (widget.value.contains(node)) {
        widget.value.remove(node);
        _deselectDescendants(node);
        _updateParentSelection(node);
      } else {
        widget.value.add(node);
        _selectDescendants(node);
        _updateParentSelection(node);
      }
    });
    widget.onChanged(widget.value);
    _controller.text = widget.value.join('; ');
    SchedulerBinding.instance.addPostFrameCallback((_) => _overlayEntry?.markNeedsBuild());
  }

  void _updateParentSelection(TreeNode node) {
    TreeNode? parent;
    for (var rootNode in widget.items) {
      if (node == rootNode) {
        parent = rootNode;
        return;
      }

      parent = _findParent(node, rootNode);
      if (parent != null) {
        final allChildrenSelected = parent.children?.every((element) => widget.value.contains(element)) ?? false;
        if (allChildrenSelected) {
          widget.value.add(parent);
          _updateParentSelection(parent); // Recursively update parent nodes
        } else {
          widget.value.remove(parent);
          _updateParentSelection(parent); // Recursively update parent nodes
        }
      }
    }
  }

  TreeNode? _findParent(TreeNode target, TreeNode current) {
    for (var child in current.children ?? <TreeNode>[]) {
      if (child == target) {
        return current;
      }
      final found = _findParent(target, child);
      if (found != null) {
        return found;
      }
    }

    return null;
  }

  // Recursively select descendants
  void _selectDescendants(TreeNode node) {
    for (var child in (node.children ?? <TreeNode>[])) {
      if (!widget.value.contains(child)) {
        widget.value.add(child);
        _selectDescendants(child);
      }
    }
  }

  // Recursively deselect descendants
  void _deselectDescendants(TreeNode node) {
    for (var child in (node.children ?? <TreeNode>[])) {
      if (widget.value.contains(child)) {
        widget.value.remove(child);
        _deselectDescendants(child);
      }
    }
  }

  void _expandSection(TreeNode node) {
    setState(() => _collapsed.update(node.value, (_) => !(_collapsed[node.value] ?? false), ifAbsent: () => false));
    SchedulerBinding.instance.addPostFrameCallback((_) => _overlayEntry!.markNeedsBuild());
  }

  int get _totalItems {
    List<TreeNode> children = <TreeNode>[];
    for (var node in widget.items) {
      children.add(node);
      children.addAll(_children(node));
    }

    return children.length;
  }

  int get _totalNodes {
    List<TreeNode> parent = <TreeNode>[];
    void traverse(TreeNode currentNode) {
      if (currentNode.children?.isNotEmpty ?? false) {
        parent.add(currentNode); // Add the current child as an inner node
        for (var child in currentNode.children ?? <TreeNode>[]) {
          traverse(child); // Recursively traverse the child's subtree
        }
      }
    }

    for (var node in widget.items) {
      if (node.children?.isNotEmpty ?? false) {
        traverse(node);
      }
    }

    return parent.length;
  }

  // Function to select all nodes
  void _selectAll() {
    setState(() {
      final total = widget.value.length;
      widget.value.clear();
      if (total != _totalItems) {
        for (var node in widget.items) {
          _selectAllNodes(node);
        }
      }
    });

    _controller.text = widget.value.join('; ');
    SchedulerBinding.instance.addPostFrameCallback((_) => _overlayEntry?.markNeedsBuild());
  }

  // Recursive function to select all nodes
  void _selectAllNodes(TreeNode node) {
    widget.value.add(node);
    for (var child in node.children ?? <TreeNode>[]) {
      _selectAllNodes(child);
    }
  }

  void _expandAll() {
    setState(() {
      final total = _collapsed.length;
      _collapsed.clear();
      if (total != _totalNodes) {
        for (var node in widget.items) {
          _expandAllSections(node);
        }
      }
    });
    SchedulerBinding.instance.addPostFrameCallback((_) => _overlayEntry?.markNeedsBuild());
  }

  void _expandAllSections(TreeNode node) {
    if (node.children?.isNotEmpty ?? false) {
      _collapsed.putIfAbsent(node.value, () => true);
      for (var child in node.children ?? <TreeNode>[]) {
        _expandAllSections(child);
      }
    }
  }
}

class CustomCheck extends StatelessWidget {
  const CustomCheck({this.child, super.key});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      child: child,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(13, 13, 13, 1),
        border: Border.all(color: const Color.fromRGBO(51, 75, 255, 1)),
      ),
    );
  }
}
