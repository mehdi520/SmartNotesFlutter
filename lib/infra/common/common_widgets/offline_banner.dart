import 'package:flutter/material.dart';

/// Shown above a list that came from the offline cache.
class OfflineBanner extends StatelessWidget {
  final DateTime? cachedAt;
  final VoidCallback? onRetry;

  const OfflineBanner({super.key, required this.cachedAt, this.onRetry});

  static String _ago(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 1) return 'just now';
    if (d.inMinutes < 60) return '${d.inMinutes} min ago';
    if (d.inHours < 24) return '${d.inHours} h ago';
    return '${d.inDays} d ago';
  }

  @override
  Widget build(BuildContext context) {
    final t = cachedAt;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child:
          t == null
              ? const SizedBox.shrink()
              : Container(
                key: const ValueKey('offline'),
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4E5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFFD8A8)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.cloud_off_outlined, size: 18, color: Color(0xFFB45309)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "You're offline. Showing notes saved ${_ago(t)}. Changes need a connection.",
                        style: const TextStyle(fontSize: 12, color: Color(0xFF92400E)),
                      ),
                    ),
                    if (onRetry != null)
                      TextButton(
                        onPressed: onRetry,
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFFB45309),
                          visualDensity: VisualDensity.compact,
                        ),
                        child: const Text('Retry'),
                      ),
                  ],
                ),
              ),
    );
  }
}
