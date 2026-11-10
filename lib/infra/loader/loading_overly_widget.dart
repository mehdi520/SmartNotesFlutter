import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Full-screen loader. With [progress] (0.0–1.0, null = unknown) it shows the upload percentage.
class LoadingOverlay extends StatelessWidget {
  final ValueListenable<double?>? progress;

  const LoadingOverlay({super.key, this.progress});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Opacity(opacity: 0.5, child: ModalBarrier(dismissible: false, color: Colors.black)),
        Center(
          child:
              progress == null
                  ? const CircularProgressIndicator()
                  : ValueListenableBuilder<double?>(
                    valueListenable: progress!,
                    builder:
                        (context, value, _) =>
                            value == null
                                ? const CircularProgressIndicator()
                                : Material(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          width: 56,
                                          height: 56,
                                          child: CircularProgressIndicator(value: value, strokeWidth: 5),
                                        ),
                                        const SizedBox(height: 14),
                                        Text(
                                          'Uploading attachments… ${(value * 100).round()}%',
                                          style: const TextStyle(fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                  ),
        ),
      ],
    );
  }
}
