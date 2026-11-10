import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:note_book/domain/models/common_models/base_response_model.dart';
import 'package:note_book/domain/models/note/data_model/note_attachment_model.dart';
import 'package:note_book/domain/models/note/data_model/note_data_model.dart';
import 'package:note_book/domain/models/note/resp_models/get_notes_res_model.dart';
import 'package:note_book/domain/note/usecase/note_usecase.dart';
import 'package:note_book/infra/files/file_saver.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Builds PDFs for a single note or a whole notebook (all notes merged into one PDF)
/// and saves them (browser download on web, share sheet on Android/iOS).
/// Image attachments are embedded; other attachments are listed by name.
class NotePdfService {
  final NoteUsecase _noteUsecase;

  NotePdfService(this._noteUsecase);

  static const _primary = PdfColor(0.42, 0.306, 1.0); // #6B4EFF (AppColors.primary)
  static const _grey = PdfColor(0.42, 0.42, 0.42);

  /// Returns null on success, otherwise an error message.
  Future<String?> downloadNote(int noteId) async {
    final Either result = await _noteUsecase.getNote(noteId);
    return result.fold(
      (error) async => (error as BaseResponseModel).message ?? 'Could not load the note',
      (data) async {
        final note = (data as GetNoteResModel).data;
        if (note == null) return 'Note not found';
        final bytes = await _build(title: note.title ?? 'Note', notes: [note], isNoteBook: false);
        await FileSaver.save(bytes, '${_safeName(note.title ?? 'note')}.pdf', mimeType: 'application/pdf');
        return null;
      },
    );
  }

  /// All notes in the notebook merged into one PDF. Returns null on success, otherwise an error message.
  Future<String?> downloadNoteBook(int noteBookId) async {
    final Either result = await _noteUsecase.getNoteBookExport(noteBookId);
    return result.fold(
      (error) async => (error as BaseResponseModel).message ?? 'Could not load the notebook',
      (data) async {
        final export = data as GetNoteBookExportResModel;
        if (export.data.isEmpty) return 'This notebook has no notes yet';
        final title = export.noteBookTitle.isEmpty ? 'Notebook' : export.noteBookTitle;
        final bytes = await _build(title: title, notes: export.data, isNoteBook: true);
        await FileSaver.save(bytes, '${_safeName(title)}.pdf', mimeType: 'application/pdf');
        return null;
      },
    );
  }

  Future<Uint8List> _build({
    required String title,
    required List<NoteDataModel> notes,
    required bool isNoteBook,
  }) async {
    final regular = pw.Font.ttf(await rootBundle.load('assets/fonts/Poppins-Regular.ttf'));
    final bold = pw.Font.ttf(await rootBundle.load('assets/fonts/Poppins-Bold.ttf'));
    final images = await _loadImages(notes);

    final doc = pw.Document(title: title, author: 'Smart Notes', creator: 'Smart Notes');
    final theme = pw.ThemeData.withFont(base: regular, bold: bold);
    final generatedAt = DateFormat('MMM dd, yyyy hh:mm a').format(DateTime.now());

    pw.PageTheme pageTheme() => pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.fromLTRB(40, 40, 40, 36),
          theme: theme,
        );

    pw.Widget footer(pw.Context ctx) => pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(top: 12),
          child: pw.Text('$title  ·  Page ${ctx.pageNumber} of ${ctx.pagesCount}',
              style: const pw.TextStyle(fontSize: 9, color: _grey)),
        );

    // Notebook: cover + table of contents, then each note on its own page(s).
    if (isNoteBook) {
      doc.addPage(pw.MultiPage(
        pageTheme: pageTheme(),
        footer: footer,
        build: (ctx) => [
          pw.Text(title, style: pw.TextStyle(fontSize: 26, fontWeight: pw.FontWeight.bold, color: _primary)),
          pw.SizedBox(height: 4),
          pw.Text('${notes.length} ${notes.length == 1 ? 'note' : 'notes'}  ·  Generated $generatedAt',
              style: const pw.TextStyle(fontSize: 10, color: _grey)),
          pw.Divider(color: _primary, thickness: 1.2),
          pw.SizedBox(height: 8),
          pw.Text('Contents', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          ...List.generate(notes.length, (i) {
            final n = notes[i];
            return pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 3),
              child: pw.Row(children: [
                pw.SizedBox(width: 24, child: pw.Text('${i + 1}.')),
                pw.Expanded(child: pw.Text(n.title ?? '')),
                pw.Text(_date(n.createdAt), style: const pw.TextStyle(fontSize: 9, color: _grey)),
              ]),
            );
          }),
        ],
      ));
    }

    for (var i = 0; i < notes.length; i++) {
      final note = notes[i];
      doc.addPage(pw.MultiPage(
        pageTheme: pageTheme(),
        footer: footer,
        build: (ctx) => _noteWidgets(note, images, index: isNoteBook ? i + 1 : null),
      ));
    }

    return doc.save();
  }

  List<pw.Widget> _noteWidgets(NoteDataModel note, Map<int, pw.ImageProvider> images, {int? index}) {
    final attachments = note.attachments ?? const <NoteAttachmentModel>[];
    final details = (note.details ?? '').replaceAll('\r\n', '\n');

    return [
      pw.Text(index == null ? (note.title ?? '') : '$index. ${note.title ?? ''}',
          style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: _primary)),
      pw.SizedBox(height: 2),
      pw.Text(
        [if ((note.noteBookName ?? '').isNotEmpty) note.noteBookName!, _dateTime(note.createdAt)]
            .where((s) => s.isNotEmpty)
            .join('  ·  '),
        style: const pw.TextStyle(fontSize: 10, color: _grey),
      ),
      pw.Divider(color: PdfColors.grey300),
      pw.SizedBox(height: 4),
      // One widget per line so long notes can flow across pages.
      ...details.split('\n').map((line) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 3),
            child: pw.Text(line.isEmpty ? ' ' : line, style: const pw.TextStyle(fontSize: 11, lineSpacing: 2)),
          )),
      if (attachments.isNotEmpty) ...[
        pw.SizedBox(height: 14),
        pw.Text('Attachments (${attachments.length})',
            style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 4),
        ...attachments.map((a) => pw.Bullet(
              text: '${a.fileName}  (${a.readableSize})',
              style: const pw.TextStyle(fontSize: 10),
            )),
        ...attachments.where((a) => images.containsKey(a.attachmentId)).expand((a) => [
              pw.SizedBox(height: 10),
              pw.Container(
                alignment: pw.Alignment.center,
                constraints: const pw.BoxConstraints(maxHeight: 320),
                child: pw.Image(images[a.attachmentId]!, fit: pw.BoxFit.contain),
              ),
              pw.SizedBox(height: 2),
              pw.Center(child: pw.Text(a.fileName, style: const pw.TextStyle(fontSize: 9, color: _grey))),
            ]),
      ],
    ];
  }

  /// Downloads image attachments so they can be embedded. Unsupported/broken images are skipped.
  Future<Map<int, pw.ImageProvider>> _loadImages(List<NoteDataModel> notes) async {
    final result = <int, pw.ImageProvider>{};
    final imageAttachments = notes
        .expand((n) => n.attachments ?? const <NoteAttachmentModel>[])
        .where((a) => a.isImage)
        .toList();

    for (final a in imageAttachments) {
      final Either r = await _noteUsecase.downloadAttachment(a.attachmentId);
      r.fold((_) {}, (bytes) {
        try {
          result[a.attachmentId] = pw.MemoryImage(bytes as Uint8List);
        } catch (_) {
          // Format not supported by the PDF library (e.g. svg/heic): listed by name only.
        }
      });
    }
    return result;
  }

  static String _date(String? serverDate) {
    final d = DateTime.tryParse(serverDate ?? '');
    return d == null ? '' : DateFormat('MMM dd, yyyy').format(d);
  }

  static String _dateTime(String? serverDate) {
    final d = DateTime.tryParse(serverDate ?? '');
    return d == null ? '' : DateFormat('MMM dd, yyyy hh:mm a').format(d);
  }

  static String _safeName(String name) {
    final cleaned = name.replaceAll(RegExp(r'[\\/:*?"<>|]+'), '_').trim();
    if (cleaned.isEmpty) return 'note';
    return cleaned.length > 80 ? cleaned.substring(0, 80) : cleaned;
  }
}
