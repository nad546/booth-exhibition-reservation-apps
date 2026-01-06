import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_provider.dart';
import '../../services/db_service.dart';
import '../../widgets/app_drawer.dart';

class ManageExhibitionsScreen extends ConsumerStatefulWidget {
  const ManageExhibitionsScreen({super.key});

  @override
  ConsumerState<ManageExhibitionsScreen> createState() =>
      _ManageExhibitionsScreenState();
}

class _ManageExhibitionsScreenState
    extends ConsumerState<ManageExhibitionsScreen> {

  final _db = DBService();
  List<Map<String, dynamic>> _exhibitions = [];

  @override
  void initState() {
    super.initState();
    _loadExhibitions();
  }

  /// 🚀 Load only exhibitions owned by logged-in organizer
  Future<void> _loadExhibitions() async {
    final auth = ref.read(authProvider);

    final data = await _db.getExhibitionsByOrganizer(
      auth.username!,   // filter by account
    );

    setState(() => _exhibitions = data);
  }

  Future<void> _deleteExhibition(int id) async {
    await _db.delete("exhibitions", "id = ?", [id]);
    await _loadExhibitions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      /// 👇 enables hamburger menu
      drawer: const AppDrawer(),

      appBar: AppBar(
        title: const Text("Manage Exhibitions"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(12),
        child: ListView.builder(
          itemCount: _exhibitions.length,
          itemBuilder: (_, i) {
            final ex = _exhibitions[i];

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    /// Title
                    Text(
                      (ex["title"] ?? "").toString().toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    /// Date Range
                    Text(
                      "${ex["start_date"] ?? ""}  →  ${ex["end_date"] ?? ""}",
                      style: const TextStyle(fontSize: 12),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [

                        /// ✏ EDIT EXHIBITION
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/organizer/create-exhibition',
                              arguments: ex, // send values to edit mode
                            );
                          },
                        ),

                        /// 🗑 DELETE EXHIBITION
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text("Delete this exhibition?"),
                                content: const Text(
                                  "This action cannot be undone.",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text("Cancel"),
                                  ),
                                  ElevatedButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text("Delete"),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              await _deleteExhibition(ex["id"] as int);
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
