// Dialog to edit booth properties (called from admin mapping)
import 'package:flutter/material.dart';
import '../services/db_service.dart';

class BoothEditDialog extends StatefulWidget {
  final Map<String, dynamic> booth;
  const BoothEditDialog({super.key, required this.booth});

  @override
  State<BoothEditDialog> createState() => _BoothEditDialogState();
}

class _BoothEditDialogState extends State<BoothEditDialog> {
  final _codeCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _sizeCtrl = TextEditingController();
  final _xCtrl = TextEditingController();
  final _yCtrl = TextEditingController();
  final _wCtrl = TextEditingController();
  final _hCtrl = TextEditingController();

  final DBService _db = DBService();

  @override
  void initState() {
    super.initState();
    final b = widget.booth;
    _codeCtrl.text = b['booth_code']?.toString() ?? '';
    _priceCtrl.text = b['price']?.toString() ?? '0';
    _sizeCtrl.text = b['size']?.toString() ?? '';
    _xCtrl.text = b['x']?.toString() ?? '0';
    _yCtrl.text = b['y']?.toString() ?? '0';
    _wCtrl.text = b['width']?.toString() ?? '0';
    _hCtrl.text = b['height']?.toString() ?? '0';
  }

  Future<void> _save() async {
    final id = widget.booth['id'] as int;
    final updated = {
      'booth_code': _codeCtrl.text.trim(),
      'price': double.tryParse(_priceCtrl.text) ?? 0.0,
      'size': _sizeCtrl.text.trim(),
      'x': double.tryParse(_xCtrl.text) ?? 0.0,
      'y': double.tryParse(_yCtrl.text) ?? 0.0,
      'width': double.tryParse(_wCtrl.text) ?? 0.0,
      'height': double.tryParse(_hCtrl.text) ?? 0.0,
    };
    await _db.updateBooth(id, updated);
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  Future<void> _delete() async {
    final id = widget.booth['id'] as int;
    await _db.deleteBooth(id);
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit booth ${widget.booth['booth_code'] ?? ''}'),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: _codeCtrl, decoration: const InputDecoration(labelText: 'Booth code')),
          TextField(controller: _priceCtrl, decoration: const InputDecoration(labelText: 'Price'), keyboardType: TextInputType.number),
          TextField(controller: _sizeCtrl, decoration: const InputDecoration(labelText: 'Size')),
          const SizedBox(height: 8),
          const Text('Coordinates (svg-space)'),
          Row(children: [
            Expanded(child: TextField(controller: _xCtrl, decoration: const InputDecoration(labelText: 'x'), keyboardType: TextInputType.number)),
            const SizedBox(width: 8),
            Expanded(child: TextField(controller: _yCtrl, decoration: const InputDecoration(labelText: 'y'), keyboardType: TextInputType.number)),
          ]),
          Row(children: [
            Expanded(child: TextField(controller: _wCtrl, decoration: const InputDecoration(labelText: 'width'), keyboardType: TextInputType.number)),
            const SizedBox(width: 8),
            Expanded(child: TextField(controller: _hCtrl, decoration: const InputDecoration(labelText: 'height'), keyboardType: TextInputType.number)),
          ]),
        ]),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
        TextButton(onPressed: _delete, child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ElevatedButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}