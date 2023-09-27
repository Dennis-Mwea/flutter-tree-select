import 'package:tree_select/models/tree_node.dart';

final List<TreeNode> continents = <TreeNode>[
  const TreeNode(value: 'AFR', label: 'Africa', children: <TreeNode>[
    TreeNode(value: 'DZA', label: 'Algeria', children: <TreeNode>[
      TreeNode(value: 'ADR', label: 'Adrar', children: <TreeNode>[]),
      TreeNode(value: 'TAM', label: 'Tamanghasset', children: <TreeNode>[]),
      TreeNode(value: 'GUE', label: 'Guelma', children: <TreeNode>[])
    ]),
    TreeNode(value: 'AGO', label: 'Angola', children: <TreeNode>[]),
    TreeNode(value: 'BEN', label: 'Benin', children: <TreeNode>[]),
    TreeNode(value: 'BWA', label: 'Botswana', children: <TreeNode>[])
  ])
];
