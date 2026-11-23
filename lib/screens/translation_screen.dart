import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/translation_provider.dart';

class TranslationScreen extends StatefulWidget {
  const TranslationScreen({super.key});
  @override
  State<TranslationScreen> createState() => _TranslationScreenState();
}

class _TranslationScreenState extends State<TranslationScreen> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<TranslationProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Traduction')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(p.from.name),
                  IconButton(
                    icon: const Icon(Icons.swap_horiz),
                    onPressed: p.swap,
                  ),
                  Text(p.to.name),
                ],
              ),
              TextFormField(
                controller: _controller,
                maxLines: 4,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Écrivez le texte...',
                ),
                validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Texte requis' : null,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: p.loading
                    ? null
                    : () {
                  if (_formKey.currentState!.validate()) {
                    p.translate(_controller.text);
                  }
                },
                child: p.loading
                    ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Traduire'),
              ),
              const SizedBox(height: 16),
              if (p.error != null)
                Text(p.error!, style: const TextStyle(color: Colors.red)),
              if (p.result.isNotEmpty)
                SelectableText(p.result, style: const TextStyle(fontSize: 18)),
            ],
          ),
        ),
      ),
    );
  }
}