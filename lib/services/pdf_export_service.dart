// lib/services/pdf_export_service.dart
// SceneFlow - PDF export (F5.2)
//
// Xuất toàn bộ thông tin dự án (Danh sách nhân vật + toàn bộ phân cảnh
// theo đúng thứ tự dòng thời gian / Act) ra một file PDF chuẩn hóa,
// hiển thị đúng font tiếng Việt (dùng Noto Sans qua PdfGoogleFonts —
// bộ font này có đầy đủ dấu tiếng Việt, khác với font mặc định của
// package `pdf` vốn không hỗ trợ Unicode có dấu).

import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/project.dart';
import '../models/character.dart';
import '../models/scene.dart';
import '../models/location_item.dart';

class PdfExportOptions {
  final bool includeCharacterProfiles;
  final bool includeFullScript;
  final bool useLetterSize;

  const PdfExportOptions({
    this.includeCharacterProfiles = true,
    this.includeFullScript = true,
    this.useLetterSize = false,
  });

  PdfExportOptions copyWith({
    bool? includeCharacterProfiles,
    bool? includeFullScript,
    bool? useLetterSize,
  }) {
    return PdfExportOptions(
      includeCharacterProfiles: includeCharacterProfiles ?? this.includeCharacterProfiles,
      includeFullScript: includeFullScript ?? this.includeFullScript,
      useLetterSize: useLetterSize ?? this.useLetterSize,
    );
  }
}

class PdfExportService {
  /// Builds the production report PDF and returns the raw bytes.
  static Future<Uint8List> buildProjectReport({
    required Project project,
    required List<Character> characters,
    required List<Scene> scenes,
    required List<LocationItem> locations,
    required PdfExportOptions options,
  }) async {
    final regularFont = await PdfGoogleFonts.notoSansRegular();
    final boldFont = await PdfGoogleFonts.notoSansBold();
    final italicFont = await PdfGoogleFonts.notoSansItalic();

    final doc = pw.Document(
      theme: pw.ThemeData.withFont(
        base: regularFont,
        bold: boldFont,
        italic: italicFont,
      ),
    );

    final pageFormat = options.useLetterSize ? PdfPageFormat.letter : PdfPageFormat.a4;

    // Scenes sorted into proper timeline order: by Act (following the
    // project's declared act order), then by scene code within the act.
    final actOrder = project.acts.isNotEmpty
        ? project.acts
        : scenes.map((s) => s.act).toSet().toList();

    final sortedScenes = [...scenes]..sort((a, b) {
      final actA = actOrder.indexOf(a.act);
      final actB = actOrder.indexOf(b.act);
      final safeActA = actA == -1 ? actOrder.length : actA;
      final safeActB = actB == -1 ? actOrder.length : actB;
      if (safeActA != safeActB) return safeActA.compareTo(safeActB);
      return a.code.compareTo(b.code);
    });

    final doneCount = scenes.where((s) => s.status == SceneStatus.done).length;
    final totalHours = scenes.fold<double>(0, (sum, s) => sum + s.estimatedHours);

    String locationName(String id) {
      final match = locations.where((l) => l.id == id);
      return match.isNotEmpty ? match.first.name : id;
    }

    List<String> characterNamesFor(Scene scene) {
      return scene.characterIds
          .map((id) {
        final match = characters.where((c) => c.id == id);
        return match.isNotEmpty ? match.first.name : id;
      })
          .toList();
    }

    doc.addPage(
      pw.MultiPage(
        pageFormat: pageFormat,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _buildHeader(project),
        footer: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(top: 8),
          child: pw.Text(
            'Trang ${context.pageNumber}/${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
          ),
        ),
        build: (context) => [
          pw.SizedBox(height: 12),
          _buildSummarySection(
            totalScenes: scenes.length,
            doneScenes: doneCount,
            totalCharacters: characters.length,
            totalHours: totalHours,
            progress: project.progress,
          ),
          pw.SizedBox(height: 20),

          if (options.includeCharacterProfiles) ...[
            _sectionTitle('DANH SÁCH NHÂN VẬT'),
            pw.SizedBox(height: 8),
            _buildCharacterTable(characters),
            pw.SizedBox(height: 24),
          ],

          _sectionTitle('DANH SÁCH BỐI CẢNH'),
          pw.SizedBox(height: 8),
          _buildLocationTable(locations),
          pw.SizedBox(height: 24),

          _sectionTitle('PHÂN CẢNH THEO DÒNG THỜI GIAN'),
          pw.SizedBox(height: 8),
          ..._buildSceneEntries(
            sortedScenes,
            locationName: locationName,
            characterNamesFor: characterNamesFor,
            includeFullScript: options.includeFullScript,
          ),
        ],
      ),
    );

    return doc.save();
  }

  static pw.Widget _buildHeader(Project project) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'BÁO CÁO SẢN XUẤT PHIM',
              style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600, letterSpacing: 1.2),
            ),
            pw.Text(
              project.codeName,
              style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
            ),
          ],
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          project.title,
          style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
        ),
        pw.Text(
          'Đạo diễn: ${project.director}  •  Thể loại: ${project.genre.label}  •  Ngày bắt đầu: ${project.startDate}',
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
        ),
        pw.SizedBox(height: 8),
        pw.Divider(color: PdfColors.grey400, thickness: 1),
      ],
    );
  }

  static pw.Widget _sectionTitle(String title) {
    return pw.Text(
      title,
      style: pw.TextStyle(
        fontSize: 13,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.blueGrey900,
        letterSpacing: 1,
      ),
    );
  }

  static pw.Widget _buildSummarySection({
    required int totalScenes,
    required int doneScenes,
    required int totalCharacters,
    required double totalHours,
    required int progress,
  }) {
    pw.Widget statBox(String label, String value) {
      return pw.Expanded(
        child: pw.Container(
          padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300),
            borderRadius: pw.BorderRadius.circular(6),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(label, style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
              pw.SizedBox(height: 4),
              pw.Text(value, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            ],
          ),
        ),
      );
    }

    return pw.Row(
      children: [
        statBox('TỔNG SỐ CẢNH', '$totalScenes'),
        pw.SizedBox(width: 8),
        statBox('ĐÃ HOÀN THÀNH', '$doneScenes'),
        pw.SizedBox(width: 8),
        statBox('NHÂN VẬT', '$totalCharacters'),
        pw.SizedBox(width: 8),
        statBox('TIẾN ĐỘ', '$progress%'),
        pw.SizedBox(width: 8),
        statBox('SỐ GIỜ QUAY (DỰ KIẾN)', '${totalHours.toStringAsFixed(1)}h'),
      ],
    );
  }

  static pw.Widget _buildCharacterTable(List<Character> characters) {
    return pw.TableHelper.fromTextArray(
      headers: ['Tên nhân vật', 'Vai trò', 'Mô tả tâm lý'],
      data: characters
          .map((c) => [c.name, c.role.label, c.psychologicalProfile])
          .toList(),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey700),
      cellStyle: const pw.TextStyle(fontSize: 9),
      cellAlignment: pw.Alignment.centerLeft,
      columnWidths: {
        0: const pw.FlexColumnWidth(2),
        1: const pw.FlexColumnWidth(1.4),
        2: const pw.FlexColumnWidth(4),
      },
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      cellPadding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
    );
  }

  static pw.Widget _buildLocationTable(List<LocationItem> locations) {
    return pw.TableHelper.fromTextArray(
      headers: ['Bối cảnh', 'Khu vực', 'INT/EXT', 'Ngày/Đêm', 'Ghi chú'],
      data: locations
          .map((l) => [l.name, l.area, l.setting.label, l.timeOfDay.label, l.notes])
          .toList(),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey700),
      cellStyle: const pw.TextStyle(fontSize: 9),
      cellAlignment: pw.Alignment.centerLeft,
      columnWidths: {
        0: const pw.FlexColumnWidth(1.8),
        1: const pw.FlexColumnWidth(1.6),
        2: const pw.FlexColumnWidth(0.9),
        3: const pw.FlexColumnWidth(1),
        4: const pw.FlexColumnWidth(3.2),
      },
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      cellPadding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
    );
  }

  static List<pw.Widget> _buildSceneEntries(
      List<Scene> scenes, {
        required String Function(String) locationName,
        required List<String> Function(Scene) characterNamesFor,
        required bool includeFullScript,
      }) {
    String? currentAct;
    final widgets = <pw.Widget>[];

    for (final scene in scenes) {
      if (scene.act != currentAct) {
        currentAct = scene.act;
        widgets.add(pw.SizedBox(height: 14));
        widgets.add(
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            color: PdfColors.grey200,
            width: double.infinity,
            child: pw.Text(
              currentAct.toUpperCase(),
              style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
            ),
          ),
        );
        widgets.add(pw.SizedBox(height: 8));
      }

      widgets.add(
        pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 10),
          padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300),
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    '${scene.code} — ${scene.title}',
                    style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    scene.status.label,
                    style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                  ),
                ],
              ),
              pw.SizedBox(height: 3),
              pw.Text(
                '${scene.setting.label}. ${locationName(scene.locationId).toUpperCase()} - ${scene.timeOfDay.label}  •  ${scene.pages}  •  ~${scene.estimatedHours}h',
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
              ),
              pw.SizedBox(height: 3),
              pw.Text(
                'Nhân vật: ${characterNamesFor(scene).join(", ")}',
                style: pw.TextStyle(fontSize: 9, fontStyle: pw.FontStyle.italic, color: PdfColors.grey800),
              ),
              pw.SizedBox(height: 6),
              pw.Text(
                scene.description,
                style: const pw.TextStyle(fontSize: 9.5),
              ),
              if (includeFullScript && scene.actionDialogueText.trim().isNotEmpty) ...[
                pw.SizedBox(height: 6),
                pw.Divider(color: PdfColors.grey300, thickness: 0.5),
                pw.Text(
                  scene.actionDialogueText,
                  style: const pw.TextStyle(fontSize: 9, lineSpacing: 2),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return widgets;
  }

  /// Opens the platform print/preview dialog (works on mobile, desktop and
  /// web) so the user can save the report as a PDF file or print it.
  static Future<void> previewAndPrint({
    required Project project,
    required List<Character> characters,
    required List<Scene> scenes,
    required List<LocationItem> locations,
    required PdfExportOptions options,
  }) async {
    await Printing.layoutPdf(
      name: '${project.codeName}_production_report.pdf',
      onLayout: (format) => buildProjectReport(
        project: project,
        characters: characters,
        scenes: scenes,
        locations: locations,
        options: options,
      ),
    );
  }

  /// Shares / saves the generated PDF directly (bypasses the print dialog).
  static Future<void> shareReport({
    required Project project,
    required List<Character> characters,
    required List<Scene> scenes,
    required List<LocationItem> locations,
    required PdfExportOptions options,
  }) async {
    final bytes = await buildProjectReport(
      project: project,
      characters: characters,
      scenes: scenes,
      locations: locations,
      options: options,
    );
    await Printing.sharePdf(
      bytes: bytes,
      filename: '${project.codeName}_production_report.pdf',
    );
  }
}