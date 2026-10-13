import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'todo_model.dart';

class DatabaseHomeScreen extends StatefulWidget {
  const DatabaseHomeScreen({super.key});

  @override
  State<DatabaseHomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<DatabaseHomeScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Todo> _todos = [];
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    final todos = await _dbHelper.getTodos();
    setState(() {
      _todos = todos;
    });
  }

  // Função para exibir o formulário de adição/edição de tarefas
  void _showTodoForm({Todo? todo}) {
    _titleController.text = todo?.title ?? '';
    _descriptionController.text = todo?.description ?? '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Para que o teclado não cubra os campos
      builder: (_) => SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                todo == null ? 'Adicionar Nova Tarefa' : 'Editar Tarefa',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descrição (Opcional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_titleController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('O título não pode ser vazio!')),
                    );
                    return;
                  }

                  try {
                    // debug
                    debugPrint('Salvar pressionado. title=${_titleController.text}');

                    if (todo == null) {                      // Adicionar nova tarefa
                      final result = await _dbHelper.insertTodo(Todo(
                        title: _titleController.text,
                        description: _descriptionController.text,
                      ));
                      debugPrint('insertTodo result: $result');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Tarefa salva com sucesso!')),
                      );
                    } else {
                      // Atualizar tarefa existente
                      todo.title = _titleController.text;
                      todo.description = _descriptionController.text;
                      final result = await _dbHelper.updateTodo(todo);
                      debugPrint('updateTodo result: $result');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Tarefa atualizada!')),
                      );
                    }
                    _titleController.clear();
                    _descriptionController.clear();
                    await _loadTodos(); // Recarregar a lista de tarefas
                    Navigator.of(context).pop(); // Fechar o modal
                  } catch (e, st) {
                    debugPrint('Erro ao salvar tarefa: $e\n$st');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erro ao salvar: $e')),
                    );
                  }
                },
                child: Text(todo == null ? 'Salvar Tarefa' : 'Atualizar Tarefa'),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  // Função para alternar o status de 'concluído'
  void _toggleTodoStatus(Todo todo) async {
    todo.isDone = !todo.isDone;
    await _dbHelper.updateTodo(todo);
    _loadTodos();
  }

  // Função para deletar uma tarefa
  void _deleteTodo(int id) async {
    await _dbHelper.deleteTodo(id);
    _loadTodos();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tarefa excluída!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Tarefas'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: _todos.isEmpty
          ? const Center(
              child: Text(
                'Nenhuma tarefa adicionada ainda!',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: _todos.length,
              itemBuilder: (context, index) {
                final todo = _todos[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  elevation: 2,
                  child: ListTile(
                    leading: Checkbox(
                      value: todo.isDone,
                      onChanged: (bool? value) {
                        _toggleTodoStatus(todo);
                      },
                    ),
                    title: Text(
                      todo.title,
                      style: TextStyle(
                        decoration: todo.isDone
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        color: todo.isDone ? Colors.grey : Colors.black,
                      ),
                    ),
                    subtitle: Text(
                      todo.description.isNotEmpty
                          ? todo.description
                          : 'Sem descrição',
                      style: TextStyle(
                        decoration: todo.isDone
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        color: todo.isDone ? Colors.grey : Colors.grey[700],
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showTodoForm(todo: todo),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteTodo(todo.id!),
                        ),
                      ],
                    ),
                    onTap: () => _showTodoForm(todo: todo), // Tocar para editar
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTodoForm(),
        tooltip: 'Adicionar Tarefa',
        child: const Icon(Icons.add),
      ),
    );
  }
}