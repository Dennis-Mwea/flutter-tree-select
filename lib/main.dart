import 'package:flutter/material.dart';
import 'package:tree_select/models/tree_node.dart';
import 'package:tree_select/tree_select_data.dart';
import 'package:tree_select/widgets/tree_select.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(borderSide: BorderSide(color: Color.fromRGBO(51, 75, 225, 1)), borderRadius: BorderRadius.zero),
          errorBorder: OutlineInputBorder(borderSide: BorderSide(color: Color.fromRGBO(51, 75, 225, 1)), borderRadius: BorderRadius.zero),
          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color.fromRGBO(51, 75, 225, 1)), borderRadius: BorderRadius.zero),
          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Color.fromRGBO(51, 75, 225, 1)), borderRadius: BorderRadius.zero),
          disabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Color.fromRGBO(51, 75, 225, 1)), borderRadius: BorderRadius.zero),
          focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide(color: Color.fromRGBO(51, 75, 225, 1)), borderRadius: BorderRadius.zero),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<TreeNode> _selectedNodes = <TreeNode>[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0d0d0d),
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: TreeSelect(
          flatten: true,
          items: continents,
          value: _selectedNodes,
          onChanged: (List<TreeNode>? value) => setState(() {
            if (value != null) {
              _selectedNodes = value;
            }
          }),
        ),
      ),
    );
  }
}
