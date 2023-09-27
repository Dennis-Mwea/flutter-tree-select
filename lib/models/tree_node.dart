import 'package:equatable/equatable.dart';

class TreeNode extends Equatable {
  final String value;
  final String label;
  final bool selected;
  final List<TreeNode>? children;

  const TreeNode({required this.value, required this.label, this.children, this.selected = false});

  @override
  List<Object?> get props => <Object?>[value, label, selected, children];

  @override
  String toString() => label;
}
