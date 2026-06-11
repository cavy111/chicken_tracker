import 'package:flutter/material.dart';

Future<bool?> showConfirmDialog(BuildContext context, String title, String message) {
  return showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(onPressed: () => Navigator.of(c).pop(false), child: const Text('Cancel')),
        ElevatedButton(onPressed: () => Navigator.of(c).pop(true), child: const Text('OK')),
      ],
    ),
  );
}