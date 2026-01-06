import 'package:flutter/material.dart';

class SearchFilterBottomSheet extends StatefulWidget {
  final void Function({
  String? keyword,
  String? startDate,
  String? endDate,
  String? minPrice,
  String? maxPrice,
  }) onApply;

  const SearchFilterBottomSheet({super.key, required this.onApply});

  @override
  State<SearchFilterBottomSheet> createState() =>
      _SearchFilterBottomSheetState();
}

class _SearchFilterBottomSheetState extends State<SearchFilterBottomSheet> {
  final _keywordCtrl = TextEditingController();
  final _startCtrl = TextEditingController();
  final _endCtrl = TextEditingController();
  final _minCtrl = TextEditingController();
  final _maxCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            const Text(
              "Search & Filter Exhibitions",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: _keywordCtrl,
              decoration: const InputDecoration(
                labelText: "Search by name / keyword",
              ),
            ),

            TextField(
              controller: _startCtrl,
              decoration: const InputDecoration(
                labelText: "From Date (YYYY-MM-DD)",
              ),
            ),

            TextField(
              controller: _endCtrl,
              decoration: const InputDecoration(
                labelText: "To Date (YYYY-MM-DD)",
              ),
            ),

            TextField(
              controller: _minCtrl,
              decoration: const InputDecoration(
                labelText: "Min Price (optional)",
              ),
            ),

            TextField(
              controller: _maxCtrl,
              decoration: const InputDecoration(
                labelText: "Max Price (optional)",
              ),
            ),

            const SizedBox(height: 14),

            ElevatedButton(
              onPressed: () {
                widget.onApply(
                  keyword: _keywordCtrl.text.trim(),
                  startDate: _startCtrl.text.trim(),
                  endDate: _endCtrl.text.trim(),
                  minPrice: _minCtrl.text.trim(),
                  maxPrice: _maxCtrl.text.trim(),
                );

                Navigator.pop(context);
              },
              child: const Text("Apply Filters"),
            )
          ],
        ),
      ),
    );
  }
}
