import 'dart:io';
import 'dart:math';
import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:video_player/video_player.dart';
import 'package:quickcoat/core/colors/app_colors.dart';

final supabase = Supabase.instance.client;

void showRatingDialog(BuildContext context, dynamic productId, String orderId, String productName) {
  final TextEditingController commentController = TextEditingController();
  double rating = 0;

  final List<PlatformFile> pickedImages = [];
  PlatformFile? pickedVideo;
  ChewieController? videoChewieController;
  VideoPlayerController? videoController;

  double attachProgress = 0.0;
  bool isAttachingVideo = false;

  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  Future<void> pickMedia(StateSetter setState) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'mp4', 'mov', 'avi'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;

      final images = result.files.where((f) => ['jpg', 'jpeg', 'png'].contains(f.extension?.toLowerCase())).toList();
      final videos = result.files.where((f) => ['mp4', 'mov', 'avi'].contains(f.extension?.toLowerCase())).toList();

      for (final img in images) {
        if (pickedImages.length >= 9) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You can attach up to 9 photos only.')),
          );
          break;
        }
        if (!pickedImages.any((f) => f.name == img.name)) pickedImages.add(img);
      }

      if (videos.isNotEmpty) {
        if (pickedVideo != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You can only attach one video.')),
          );
        } else {
          pickedVideo = videos.first;
          isAttachingVideo = true;
          attachProgress = 0.0;
          setState(() {});

          for (int i = 0; i <= 100; i++) {
            await Future.delayed(const Duration(milliseconds: 20));
            attachProgress = i / 100;
            setState(() {});
          }

          final uri = Uri.dataFromBytes(pickedVideo!.bytes!, mimeType: 'video/mp4');
          videoController = VideoPlayerController.networkUrl(uri);
          await videoController!.initialize();

          videoChewieController = ChewieController(
            videoPlayerController: videoController!,
            autoPlay: false,
            looping: false,
            aspectRatio: videoController!.value.aspectRatio,
          );

          isAttachingVideo = false;
          setState(() {});
        }
      } else {
        setState(() {});
      }
    } catch (e) {
      debugPrint("Media selection error: $e");
      isAttachingVideo = false;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Media selection failed: $e")),
      );
    }
  }

  Future<List<String>> uploadAllToSupabase() async {
    final List<String> urls = [];

    for (final file in pickedImages) {
      try {
        final fileBytes = file.bytes!;
        final path = 'Ratings/${user.uid}_${DateTime.now().millisecondsSinceEpoch}_${file.name}';
        await supabase.storage.from('QuickCoat').uploadBinary(path, fileBytes);
        final url = supabase.storage.from('QuickCoat').getPublicUrl(path);
        urls.add(url);
      } catch (e) {
        debugPrint("Image upload error: $e");
      }
    }

    if (pickedVideo != null) {
      try {
        final fileBytes = pickedVideo!.bytes!;
        final path = 'Ratings/${user.uid}_${DateTime.now().millisecondsSinceEpoch}_${pickedVideo!.name}';
        await supabase.storage.from('QuickCoat').uploadBinary(path, fileBytes);
        final url = supabase.storage.from('QuickCoat').getPublicUrl(path);
        urls.add(url);
      } catch (e) {
        debugPrint("Video upload error: $e");
      }
    }

    return urls;
  }

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Rate $productName', style: GoogleFonts.roboto(fontWeight: FontWeight.bold)),
            content: SizedBox(
              height: MediaQuery.of(context).size.height / 1.8,
              width: MediaQuery.of(context).size.width / 3,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ⭐ Rating stars
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(
                            index < rating ? Icons.star_rounded : Icons.star_border_rounded,
                            color: Colors.amber,
                            size: 32,
                          ),
                          onPressed: () => setState(() => rating = index + 1.0),
                        );
                      }),
                    ),
                    const SizedBox(height: 10),

                    TextField(
                      controller: commentController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Write your review...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    ElevatedButton.icon(
                      onPressed: () async => await pickMedia(setState),
                      icon: const Icon(Icons.attach_file),
                      label: Text(
                        (pickedImages.isEmpty && pickedVideo == null)
                            ? "Attach Photos/Videos"
                            : "Add More (${pickedImages.length} photos${pickedVideo != null ? " + 1 video" : ""})",
                        style: GoogleFonts.roboto(),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.color8,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // 🖼️ Media previews
                    if (pickedVideo != null || pickedImages.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (pickedVideo != null)
                            Stack(
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: 220,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: isAttachingVideo
                                        ? Padding(
                                            padding: const EdgeInsets.all(20),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text("Attaching video...",
                                                    style: GoogleFonts.roboto(fontSize: 14, color: Colors.grey.shade700)),
                                                const SizedBox(height: 12),
                                                LinearProgressIndicator(
                                                  value: attachProgress,
                                                  minHeight: 6,
                                                  color: AppColors.color8,
                                                  backgroundColor: Colors.grey.shade300,
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                const SizedBox(height: 8),
                                                Text("${(attachProgress * 100).toInt()}%",
                                                    style: GoogleFonts.roboto(fontSize: 13, color: Colors.grey.shade600)),
                                              ],
                                            ),
                                          )
                                        : (videoChewieController != null
                                            ? Chewie(controller: videoChewieController!)
                                            : const Center(child: Text("Video preview unavailable"))),
                                  ),
                                ),
                                if (!isAttachingVideo)
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: GestureDetector(
                                      onTap: () {
                                        videoController?.dispose();
                                        videoChewieController?.dispose();
                                        pickedVideo = null;
                                        setState(() {});
                                      },
                                      child: Container(
                                        decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                        padding: const EdgeInsets.all(4),
                                        child: const Icon(Icons.close, color: Colors.white, size: 18),
                                      ),
                                    ),
                                  ),
                              ],
                            ),

                          const SizedBox(height: 12),

                          if (pickedImages.isNotEmpty)
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: pickedImages.map((img) {
                                return Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.memory(
                                        img.bytes!,
                                        height: 100,
                                        width: 100,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: GestureDetector(
                                        onTap: () {
                                          pickedImages.remove(img);
                                          setState(() {});
                                        },
                                        child: Container(
                                          decoration:
                                              const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                          padding: const EdgeInsets.all(2),
                                          child: const Icon(Icons.close, color: Colors.white, size: 16),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () {
                      videoController?.dispose();
                      videoChewieController?.dispose();
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel', style: TextStyle(color: Colors.white)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.color8),
                    onPressed: () async {
                      if (rating == 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please provide a rating.')),
                        );
                        return;
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Uploading attachments...')),
                      );

                      final uploadedUrls = await uploadAllToSupabase();

                      // 🔍 find product document by productId field
                      final productQuery = await FirebaseFirestore.instance
                          .collection('products')
                          .where('productId', isEqualTo: int.tryParse(productId.toString()) ?? productId)
                          .limit(1)
                          .get();

                      if (productQuery.docs.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Product not found.")),
                        );
                        return;
                      }

                      final productDocId = productQuery.docs.first.id;
final user = FirebaseAuth.instance.currentUser!;
String userName = "Anonymous User";

try {
  final docSnap = await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .get();

  if (docSnap.exists) {
    final data = docSnap.data()!;
    userName = data['full_name'] ?? data['name'] ?? "Anonymous User";
    debugPrint("✅ Loaded user name: $userName");
  } else {
    debugPrint("❌ Document not found for UID: ${user.uid}");
  }
} catch (e) {
  debugPrint("🔥 Error fetching Firestore user: $e");
}

                      await FirebaseFirestore.instance
                          .collection('products')
                          .doc(productDocId)
                          .collection('ratings')
                          .add({
                        'rating': rating,
                        'comment': commentController.text.trim(),
                        'media': uploadedUrls,
                        'userId': user.uid,
                          'customerName': userName, // 🆕 Save customer name

                        'orderId': orderId,
                        'createdAt': FieldValue.serverTimestamp(),
                      });

                      videoController?.dispose();
                      videoChewieController?.dispose();

                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Thanks for your feedback! ✅')),
                      );
                    },
                    child: const Text('Submit', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          );
        },
      );
    },
  );
}
