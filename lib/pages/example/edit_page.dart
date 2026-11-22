import 'package:app/l10n/l10n.dart';
import 'package:app/widget/base_page_state.dart';
import 'package:flutter/material.dart';

class EditPageExample extends BasePage {
  const EditPageExample({super.key, this.initialValue = ''});

  final String initialValue;

  @override
  BasePageState<EditPageExample> createState() => _EditPageExampleState();
}

class _EditPageExampleState extends BasePageState<EditPageExample> {
  late final TextEditingController _controller;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState?.validate() ?? false) {
      popPage<String>(_controller.text.trim());
    }
  }

  @override
  PreferredSizeWidget buildAppBar(BuildContext context) =>
      AppBar(title: Text(context.l10n.editTitle));

  @override
  Widget buildPageBody(BuildContext context) {
    final l10n = context.l10n;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _controller,
              autofocus: true,
              maxLength: 40,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _save(),
              validator: (value) => value == null || value.trim().isEmpty
                  ? l10n.enterTitle
                  : null,
              decoration: InputDecoration(labelText: l10n.title),
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: _save, child: Text(l10n.save)),
          ],
        ),
      ),
    );
  }
}
