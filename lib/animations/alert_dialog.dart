import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickcoat/animations/hover_extensions.dart';

class AlertDialogHelper {
  final String title;
  final String content;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final bool dismissible;

  AlertDialogHelper({
    required this.title,
    required this.content,
    required this.confirmText,
    required this.cancelText,
    required this.onConfirm,
    required this.onCancel,
    this.dismissible = true,
  });

  Future<void> show(BuildContext context) async {
    await showCupertinoDialog(
      context: context,
      barrierDismissible: dismissible,
      builder: (context) {
        return AlertDialog(
          title: Text(
            title,
            style: GoogleFonts.roboto(
              fontSize: MediaQuery.of(context).size.width / 70,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          content:
              content.isNotEmpty
                  ? Text(
                    content,
                    style: GoogleFonts.roboto(
                      fontSize: MediaQuery.of(context).size.width / 80,
                      color: Colors.black,
                    ),
                  )
                  : null,
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: onCancel,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        MediaQuery.of(context).size.width / 100,
                      ),
                      color: Colors.red,
                    ),
                    height: MediaQuery.of(context).size.width / 40,
                    width: MediaQuery.of(context).size.width / 10,
                    child: Center(
                      child: Text(
                        cancelText,
                        style: GoogleFonts.roboto(
                          color: Colors.white,
                          fontSize: MediaQuery.of(context).size.width / 80,
                        ),
                      ),
                    ),
                  ),
                ).showCursorOnHover,
                SizedBox(width: MediaQuery.of(context).size.width / 80),
                GestureDetector(
                  onTap: onConfirm,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        MediaQuery.of(context).size.width / 100,
                      ),
                      color: Colors.green,
                    ),
                    height: MediaQuery.of(context).size.width / 40,
                    width: MediaQuery.of(context).size.width / 10,
                    child: Center(
                      child: Text(
                        confirmText,
                        style: GoogleFonts.roboto(
                          color: Colors.white,
                          fontSize: MediaQuery.of(context).size.width / 80,
                        ),
                      ),
                    ),
                  ),
                ).showCursorOnHover,
              ],
            ),
          ],
        );
      },
    );
  }
}
