import 'dart:io';
import 'dart:typed_data';
import 'package:agro_app/domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:agro_app/app/app.dart';

class CollectionPdfPreviewPage extends StatelessWidget {
  final Uint8List pdfBytes;
  final String fileName;

  const CollectionPdfPreviewPage({
    super.key,
    required this.pdfBytes,
    required this.fileName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsValue.bgMain,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
        title: Text('Receipt Preview', style: Styles.txtBlackColorW70020),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.download_outlined,
              color: ColorsValue.primary,
            ),
            onPressed: () async {
              try {
                Utility.showLoader();

                Directory? downloadDir;
                if (Platform.isAndroid) {
                  downloadDir = Directory("/storage/emulated/0/Download");
                  if (!await downloadDir.exists()) {
                    downloadDir = await getExternalStorageDirectory();
                  }
                } else {
                  downloadDir = await getApplicationDocumentsDirectory();
                }

                downloadDir ??= await getApplicationDocumentsDirectory();

                String filePath = '${downloadDir.path}/$fileName';
                int counter = 1;
                while (await File(filePath).exists()) {
                  final name = fileName.contains('.')
                      ? fileName.substring(0, fileName.lastIndexOf('.'))
                      : fileName;
                  final ext = fileName.contains('.')
                      ? fileName.substring(fileName.lastIndexOf('.'))
                      : '';
                  filePath = '${downloadDir.path}/${name}_$counter$ext';
                  counter++;
                }

                final file = File(filePath);
                await file.writeAsBytes(pdfBytes);

                Utility.closeLoader();
                Utility.snacBar(
                  'Downloaded to: ${file.path.split("/").last}',
                  ColorsValue.primary,
                );

                // File downloaded successfully without opening
              } catch (e) {
                Utility.closeLoader();
                Utility.showMessage(
                  'Failed to save file: $e',
                  MessageType.error,
                  null,
                  '',
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.share, color: ColorsValue.primary),
            onPressed: () async {
              await Printing.sharePdf(bytes: pdfBytes, filename: fileName);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: PdfPreview(
        build: (format) => pdfBytes,
        maxPageWidth: 700,
        pdfFileName: fileName,
        allowPrinting: false,
        allowSharing: false,
        canChangePageFormat: false,
        canChangeOrientation: false,
        actions: const [],
      ),
    );
  }
}
