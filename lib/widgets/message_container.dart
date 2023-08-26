import 'package:flutter/material.dart';

class MessageContainer extends StatelessWidget {
  const MessageContainer({super.key, required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return message.isNotEmpty
        ? Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.error.withAlpha(50),
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          border: Border.all(color: Theme.of(context).colorScheme.error.withAlpha(155))
      ),
      child: Row(
        children: [
          Expanded(child: Text(message)
          )
        ],
      ),
    ): const SizedBox();
  }
}