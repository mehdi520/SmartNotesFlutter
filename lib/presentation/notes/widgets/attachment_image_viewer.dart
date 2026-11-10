import 'dart:typed_data';

import 'package:flutter/material.dart';

/// One image shown in [AttachmentImageViewer].
class AttachmentPreviewItem {
  final String name;
  final String? subtitle;
  final Future<Uint8List?> Function() load;

  const AttachmentPreviewItem({required this.name, required this.load, this.subtitle});
}

/// Full-screen image gallery: swipe between images, pinch or double-tap to zoom,
/// optional download and delete actions.
class AttachmentImageViewer extends StatefulWidget {
  final List<AttachmentPreviewItem> items;
  final int initialIndex;

  /// Asks for confirmation and deletes item [index]. Returns true if it was deleted.
  final Future<bool> Function(BuildContext context, int index)? onDelete;

  /// Saves item [index] with its already loaded bytes.
  final Future<void> Function(int index, Uint8List bytes)? onDownload;

  const AttachmentImageViewer({super.key, required this.items, this.initialIndex = 0, this.onDelete, this.onDownload});

  static Future<void> open(
    BuildContext context, {
    required List<AttachmentPreviewItem> items,
    int initialIndex = 0,
    Future<bool> Function(BuildContext context, int index)? onDelete,
    Future<void> Function(int index, Uint8List bytes)? onDownload,
  }) {
    return Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        transitionDuration: const Duration(milliseconds: 220),
        pageBuilder:
            (_, __, ___) => AttachmentImageViewer(
              items: items,
              initialIndex: initialIndex,
              onDelete: onDelete,
              onDownload: onDownload,
            ),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  State<AttachmentImageViewer> createState() => _AttachmentImageViewerState();
}

class _AttachmentImageViewerState extends State<AttachmentImageViewer> {
  late final List<AttachmentPreviewItem> _items = [...widget.items];

  /// Original position of each shown item in [widget.items], so callbacks get the right index.
  late final List<int> _origin = List.generate(widget.items.length, (i) => i);
  late final PageController _pages = PageController(initialPage: widget.initialIndex);
  late int _index = widget.initialIndex;
  final Map<int, Future<Uint8List?>> _loads = {};
  bool _zoomed = false;
  bool _chrome = true;
  bool _working = false;

  Future<Uint8List?> _load(int i) => _loads[_origin[i]] ??= _items[i].load();

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  Future<void> _download() async {
    final bytes = await _load(_index);
    if (bytes == null || widget.onDownload == null) return;
    setState(() => _working = true);
    try {
      await widget.onDownload!(_origin[_index], bytes);
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _delete() async {
    setState(() => _working = true);
    final ok = await widget.onDelete!(context, _origin[_index]);
    if (!mounted) return;
    setState(() => _working = false);
    if (!ok) return;
    if (_items.length == 1) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _items.removeAt(_index);
      _origin.removeAt(_index);
      if (_index >= _items.length) _index = _items.length - 1;
      _zoomed = false;
    });
    _pages.jumpToPage(_index);
  }

  @override
  Widget build(BuildContext context) {
    final item = _items[_index];
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pages,
            physics: _zoomed ? const NeverScrollableScrollPhysics() : const PageScrollPhysics(),
            itemCount: _items.length,
            onPageChanged:
                (i) => setState(() {
                  _index = i;
                  _zoomed = false;
                }),
            itemBuilder:
                (_, i) => _ZoomableImage(
                  key: ValueKey(_origin[i]),
                  bytes: _load(i),
                  onZoomChanged: (z) {
                    if (z != _zoomed) setState(() => _zoomed = z);
                  },
                  onTap: () => setState(() => _chrome = !_chrome),
                ),
          ),
          // Top bar
          AnimatedOpacity(
            opacity: _chrome ? 1 : 0,
            duration: const Duration(milliseconds: 180),
            child: IgnorePointer(
              ignoring: !_chrome,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xCC000000), Color(0x00000000)],
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(4, 4, 4, 24),
                    child: Row(
                      children: [
                        IconButton(
                          tooltip: 'Close',
                          color: Colors.white,
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                item.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                              ),
                              Text(
                                [
                                  if (_items.length > 1) '${_index + 1} of ${_items.length}',
                                  if (item.subtitle != null) item.subtitle!,
                                ].join(' · '),
                                style: const TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        if (_working)
                          const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            ),
                          ),
                        if (widget.onDownload != null)
                          IconButton(
                            tooltip: 'Download',
                            color: Colors.white,
                            icon: const Icon(Icons.download_outlined),
                            onPressed: _working ? null : _download,
                          ),
                        if (widget.onDelete != null)
                          IconButton(
                            tooltip: 'Delete',
                            color: Colors.white,
                            icon: const Icon(Icons.delete_outline),
                            onPressed: _working ? null : _delete,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One page: loads the bytes, pinch-to-zoom up to 5x, double-tap toggles 2.5x at the tap point.
class _ZoomableImage extends StatefulWidget {
  final Future<Uint8List?> bytes;
  final ValueChanged<bool> onZoomChanged;
  final VoidCallback onTap;

  const _ZoomableImage({super.key, required this.bytes, required this.onZoomChanged, required this.onTap});

  @override
  State<_ZoomableImage> createState() => _ZoomableImageState();
}

class _ZoomableImageState extends State<_ZoomableImage> with SingleTickerProviderStateMixin {
  final _controller = TransformationController();
  late final AnimationController _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 220));
  Animation<Matrix4>? _zoomAnim;
  Offset _doubleTapAt = Offset.zero;

  @override
  void initState() {
    super.initState();
    _anim.addListener(() {
      if (_zoomAnim != null) _controller.value = _zoomAnim!.value;
    });
    _controller.addListener(() => widget.onZoomChanged(_controller.value.getMaxScaleOnAxis() > 1.01));
  }

  @override
  void dispose() {
    _anim.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _toggleZoom() {
    final zoomedIn = _controller.value.getMaxScaleOnAxis() > 1.01;
    const scale = 2.5;
    final target =
        zoomedIn
            ? Matrix4.identity()
            : (Matrix4.identity()
              ..translateByDouble(-_doubleTapAt.dx * (scale - 1), -_doubleTapAt.dy * (scale - 1), 0, 1)
              ..scaleByDouble(scale, scale, 1, 1));
    _zoomAnim = Matrix4Tween(
      begin: _controller.value,
      end: target,
    ).animate(CurvedAnimation(parent: _anim, curve: Curves.easeOut));
    _anim.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: widget.bytes,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        }
        final bytes = snap.data;
        if (bytes == null) {
          return const _ViewerMessage(icon: Icons.cloud_off_outlined, text: 'Could not load this image');
        }
        return GestureDetector(
          onTap: widget.onTap,
          onDoubleTapDown: (d) => _doubleTapAt = d.localPosition,
          onDoubleTap: _toggleZoom,
          child: InteractiveViewer(
            transformationController: _controller,
            minScale: 1,
            maxScale: 5,
            child: SizedBox.expand(
              child: Image.memory(
                bytes,
                fit: BoxFit.contain,
                gaplessPlayback: true,
                errorBuilder:
                    (_, __, ___) => const _ViewerMessage(
                      icon: Icons.broken_image_outlined,
                      text: 'Preview not available for this image type',
                    ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ViewerMessage extends StatelessWidget {
  final IconData icon;
  final String text;
  const _ViewerMessage({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white54, size: 48),
        const SizedBox(height: 12),
        Text(text, style: const TextStyle(color: Colors.white70)),
      ],
    ),
  );
}
