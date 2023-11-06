// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:sqflite_todo/db/db.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'SQFLite'),
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
  List<Map<String, dynamic>> items = [];

  bool isLoading = true;

  void refreshItems() async {
    final data = await DBHelper.getItems();
    setState(() {
      items = data;
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    refreshItems();
  }

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  Future<void> _addItem() async {
    await DBHelper.createItem(
        _titleController.text, _descriptionController.text);
    refreshItems();
  }

  Future<void> _updateItem(int id) async {
    await DBHelper.updateItem(
        id, _titleController.text, _descriptionController.text);
    refreshItems();
  }

  void _deleteItem(int id) async {
    await DBHelper.deleteItem(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Item deletado com sucesso!'),
    ));
    refreshItems();
  }

  void _showForm(int? id) async {
    if (id != null) {
      final existingItem = items.firstWhere((element) => element['id'] == id);
      _titleController.text = existingItem['title'];
      _descriptionController.text = existingItem['description'];
    }

    showModalBottomSheet(
        context: context,
        elevation: 5,
        isScrollControlled: true,
        builder: (_) => Container(
              padding: EdgeInsets.only(
                  top: 15,
                  left: 15,
                  right: 15,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 120),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(hintText: 'Título'),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 16),
                    child: TextField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(hintText: 'Descrição'),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      id == null ? await _addItem() : await _updateItem(id);
                      _titleController.text = '';
                      _descriptionController.text = '';
                      Navigator.of(context).pop();
                    },
                    child: Text(id == null ? 'Criar novo item' : 'Atualizar'),
                  )
                ],
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(null),
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) => Card(
          color: Colors.pink.shade100,
          margin: const EdgeInsets.all(5),
          child: ListTile(
            title: Text(items[index]['title']),
            subtitle: Text(items[index]['description']),
            trailing: SizedBox(
              width: 100,
              child: Row(children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showForm(items[index]['id']),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteItem(items[index]['id']),
                )
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
