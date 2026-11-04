import 'package:flutter/material.dart';
import 'package:century_cqg/Screens/Watchlist/service/watchlist_service.dart';

Future<String?> showCreateWatchlistDialog(
  BuildContext context,
  WatchlistService watchlistService,
) {
  final controller = TextEditingController();
  String? errorText;
  var isSubmitting = false;

  return showDialog<String>(
    context: context,
    builder:
        (dialogContext) => StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            Future<void> submit() async {
              final name = controller.text.trim();
              if (name.isEmpty) {
                setDialogState(() => errorText = 'Watchlist name is required.');
                return;
              }

              setDialogState(() => isSubmitting = true);
              final created = await watchlistService.addWatchedList(
                dialogContext,
                name,
              );
              if (!dialogContext.mounted) {
                return;
              }

              if (created) {
                Navigator.of(dialogContext).pop(name);
                return;
              }

              setDialogState(() {
                isSubmitting = false;
                errorText =
                    watchlistService.watchlistMutationError ??
                    'Unable to create watchlist.';
              });
            }

            return AlertDialog(
              title: const Text('Create watchlist'),
              content: TextField(
                controller: controller,
                autofocus: true,
                style: const TextStyle(color: Colors.black),
                cursorColor: Colors.black,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => submit(),
                onChanged: (_) {
                  if (errorText != null) {
                    setDialogState(() => errorText = null);
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Watchlist name',
                  labelStyle: const TextStyle(color: Colors.black54),
                  floatingLabelStyle: const TextStyle(color: Colors.black),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black54),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  errorText: errorText,
                ),
              ),
              actions: [
                TextButton(
                  onPressed:
                      isSubmitting
                          ? null
                          : () => Navigator.of(dialogContext).pop(),
                  style: TextButton.styleFrom(foregroundColor: Colors.black),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isSubmitting ? null : submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC600),
                    foregroundColor: Colors.black,
                  ),
                  child:
                      isSubmitting
                          ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black,
                            ),
                          )
                          : const Text('Create'),
                ),
              ],
            );
          },
        ),
  ).whenComplete(controller.dispose);
}
