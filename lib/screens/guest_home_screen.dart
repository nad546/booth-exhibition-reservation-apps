import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/exhibition_provider.dart';
import '../widgets/event_card.dart';
import 'package:go_router/go_router.dart';
import '../widgets/app_drawer.dart';

import '../services/db_service.dart';

class GuestHomeScreen extends ConsumerStatefulWidget {
  const GuestHomeScreen({super.key});

  @override
  ConsumerState<GuestHomeScreen> createState() =>
      _GuestHomeScreenState();
}

class _GuestHomeScreenState extends ConsumerState<GuestHomeScreen> {

  final _db = DBService();

  List<Map<String, dynamic>> _filteredResults = [];
  bool _searchActive = false;

  @override
  Widget build(BuildContext context) {
    final exhAsync = ref.watch(exhibitionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Published Exhibitions"),
        actions: [

          // 🔎 SEARCH BUTTON (works now)
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _openSearchDialog(context),
          ),
        ],
      ),

      drawer: const AppDrawer(),

      // ─────────────────────────────
      // NORMAL MODE → show provider list
      // SEARCH MODE → show filtered list
      // ─────────────────────────────
      body: _searchActive
          ? _buildFilteredList()
          : exhAsync.when(
        data: (list) => ListView.builder(
          itemCount: list.length,
          itemBuilder: (_, i) => GestureDetector(
            onTap: () => context.goNamed(
              'exhibition_detail',
              pathParameters: {
                'id': list[i].id.toString()
              },
            ),
            child: EventCard(
              title: list[i].title,
              subtitle: list[i].description,
              dateRange:
              '${list[i].startDate} - ${list[i].endDate}',
            ),
          ),
        ),
        loading: () =>
        const Center(child: CircularProgressIndicator()),
        error: (e, s) =>
            Center(child: Text("Error: $e")),
      ),

      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.login),
        label: const Text("Login"),
        onPressed: () => context.goNamed("login"),
      ),
    );
  }

  // =========================================================
  // UI — Filtered Results List
  // =========================================================
  Widget _buildFilteredList() {
    if (_filteredResults.isEmpty) {
      return const Center(
        child: Text("No exhibitions match your search"),
      );
    }

    return ListView.builder(
      itemCount: _filteredResults.length,
      itemBuilder: (_, i) {
        final ex = _filteredResults[i];

        return GestureDetector(
          onTap: () => context.goNamed(
            'exhibition_detail',
            pathParameters: {
              'id': ex["id"].toString(),
            },
          ),
          child: EventCard(
            title: ex["title"] ?? "",
            subtitle: ex["description"] ?? "",
            dateRange:
            "${ex["start_date"]} - ${ex["end_date"]}",
          ),
        );
      },
    );
  }

  // =========================================================
  // SEARCH DIALOG
  // =========================================================
  Future<void> _openSearchDialog(BuildContext context) async {
    final nameCtrl = TextEditingController();
    final startCtrl = TextEditingController();
    final endCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Search / Filter Exhibitions"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration:
              const InputDecoration(labelText: "Filter by name"),
            ),
            TextField(
              controller: startCtrl,
              decoration:
              const InputDecoration(labelText: "Start date"),
            ),
            TextField(
              controller: endCtrl,
              decoration:
              const InputDecoration(labelText: "End date"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              await _applySearchFilter(
                nameCtrl.text.trim(),
                startCtrl.text.trim(),
                endCtrl.text.trim(),
              );
            },
            child: const Text("Apply"),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // SEARCH LOGIC — matches your DBService API
  // =========================================================
  Future<void> _applySearchFilter(
      String name,
      String start,
      String end,
      ) async {

    final results = await _db.searchExhibitions(
      keyword: name.isEmpty ? null : name,
      startDate: start.isEmpty ? null : start,
      endDate: end.isEmpty ? null : end,
    );

    setState(() {
      _filteredResults = results;
      _searchActive = true;
    });
  }
}
