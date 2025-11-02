import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:quickcoat/core/colors/app_colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:video_player/video_player.dart';
import 'package:quickcoat/screen/Costumer/sections/my_purchase_sections/showRatingDialog.dart';

/// ✅ Checks if user already rated a product for a specific order
Future<bool> hasUserAlreadyRated(String productId, String orderId, String userId) async {
  try {
    final productQuery = await FirebaseFirestore.instance
        .collection('products')
        .where('productId', isEqualTo: int.tryParse(productId) ?? productId)
        .limit(1)
        .get();

    if (productQuery.docs.isEmpty) {
      debugPrint('❌ Product not found for productId: $productId');
      return false;
    }

    final productDocId = productQuery.docs.first.id;

    final ratingQuery = await FirebaseFirestore.instance
        .collection('products')
        .doc(productDocId)
        .collection('ratings')
        .where('userId', isEqualTo: userId)
        .where('orderId', isEqualTo: orderId)
        .limit(1)
        .get();

    final alreadyRated = ratingQuery.docs.isNotEmpty;
    if (alreadyRated) {
      debugPrint('🟡 User already rated product: $productId for order: $orderId');
    }

    return alreadyRated;
  } catch (e) {
    debugPrint('🔥 Error checking existing rating: $e');
    return false;
  }
}

Widget buildDelivered() {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    return const Center(child: Text("Please sign in to see your orders"));
  }

  return StreamBuilder<QuerySnapshot>(
    stream:
        FirebaseFirestore.instance
            .collection("orders")
            .where("userId", isEqualTo: user.uid)
            .where("status", isEqualTo: "Delivered")
            .snapshots(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
        return const Center(child: Text("No pending orders"));
      }

      final orders = snapshot.data!.docs;

      return Column(
        children:
            orders.map((doc) {
              final order = doc.data() as Map<String, dynamic>;
              final cartItems = List<Map<String, dynamic>>.from(
                order["cartItems"] ?? [],
              );

              return Container(
                margin: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 12,
                ),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Order: ${doc.id}",
                          style: GoogleFonts.roboto(
                            fontWeight: FontWeight.bold,
                            fontSize: MediaQuery.of(context).size.width / 80,
                          ),
                        ),
                        Text(
                          order['status'] ?? "Pending",
                          style: GoogleFonts.roboto(
                            color: Colors.orange.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Column(
                      children:
                          cartItems.map((item) {
                            final imageUrl =
                                item["productImages"] is String
                                    ? item["productImages"]
                                    : (item["productImages"] as List?)
                                            ?.isNotEmpty ==
                                        true
                                    ? item["productImages"][0]
                                    : "https://via.placeholder.com/100";
                            return Container(
                              margin: const EdgeInsets.only(top: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      imageUrl,
                                      height: 80,
                                      width: 80,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item["productName"] ?? "No name",
                                          style: GoogleFonts.roboto(
                                            fontWeight: FontWeight.bold,
                                            fontSize:
                                                MediaQuery.of(
                                                  context,
                                                ).size.width /
                                                90,
                                          ),
                                        ),
                                        Text(
                                          "Size: ${item["selectedSize"] ?? "-"} | Color: ${item["selectedColor"] ?? "-"}",
                                          style: GoogleFonts.roboto(
                                            fontSize:
                                                MediaQuery.of(
                                                  context,
                                                ).size.width /
                                                110,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text("x${item["quantity"] ?? 1}"),
                                            Text(
                                              "₱${item["productPrice"]}",
                                              style: GoogleFonts.roboto(
                                                fontWeight: FontWeight.bold,
                                                fontSize:
                                                    MediaQuery.of(
                                                      context,
                                                    ).size.width /
                                                    90,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          order['timestamp'] != null
                                              ? DateFormat(
                                                "MMMM dd, yyyy 'at' hh:mm:ss a",
                                              ).format(
                                                (order['timestamp']
                                                        as Timestamp)
                                                    .toDate()
                                                    .toLocal(),
                                              )
                                              : "",
                                          style: GoogleFonts.roboto(
                                            fontSize:
                                                MediaQuery.of(
                                                  context,
                                                ).size.width /
                                                110,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                    ),
                    const Divider(height: 20, thickness: 1),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Total: ₱${order['total']}",
                          style: GoogleFonts.roboto(
                            fontWeight: FontWeight.bold,
                            fontSize: MediaQuery.of(context).size.width / 85,
                          ),
                        ),
                        Spacer(),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.color8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadiusGeometry.circular(8),
                            ),
                          ),
                          onPressed: () {
                            showReturnRefundDialog(
                              context,
                              doc.id,
                            ); // Pass order ID
                          },
                          child: Text(
                            'Request Return&Refund',
                            style: GoogleFonts.roboto(
                              fontSize: MediaQuery.of(context).size.width / 90,
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 30,
                        ),
                         ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.color8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadiusGeometry.circular(8),
                            ),
                          ),
                          onPressed: () async {
                        final firstItem =
                            cartItems.isNotEmpty ? cartItems.first : null;
                        if (firstItem == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("No product found in this order"),
                            ),
                          );
                          return;
                        }

                        final productId = firstItem["productId"];
                        final productName = firstItem["productName"];
                        final orderId = doc.id;
                        final userId = FirebaseAuth.instance.currentUser!.uid;

                        // 🔍 Check if already rated
                        final alreadyRated = await hasUserAlreadyRated(
                          productId.toString(),
                          orderId,
                          userId,
                        );

                        if (alreadyRated) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("You have already rated this product."),
                            ),
                          );
                          return;
                        }

                        // ✅ Show rating dialog
                        showRatingDialog(
                            context, productId.toString(), orderId, productName);
                      },
                          child: Row(
                            children: [
                              Text(
                                'Rate Order',
                                style: GoogleFonts.roboto(
                                  fontSize: MediaQuery.of(context).size.width / 90,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              Icon(Icons.star_border_rounded, color: Colors.amber,)
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
      );
    },
  );
}

void showReturnRefundDialog(BuildContext context, String orderId) {
  final TextEditingController reasonController = TextEditingController();
  String? selectedReason;

  final List<PlatformFile> pickedImages = [];
  PlatformFile? pickedVideo;
  ChewieController? videoChewieController;
  VideoPlayerController? videoController;

  final List<String> reasons = [
    'Damaged Item',
    'Wrong Item Delivered',
    'Item Not as Described',
    'Other',
  ];

  double attachProgress = 0.0;
  bool isAttachingVideo = false;

  Future<void> pickMedia(StateSetter setState) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'mp4', 'mov', 'avi'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;

      final images =
          result.files
              .where(
                (f) =>
                    ['jpg', 'jpeg', 'png'].contains(f.extension?.toLowerCase()),
              )
              .toList();
      final videos =
          result.files
              .where(
                (f) =>
                    ['mp4', 'mov', 'avi'].contains(f.extension?.toLowerCase()),
              )
              .toList();

      // ✅ Handle images
      for (final img in images) {
        if (pickedImages.length >= 9) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You can attach up to 9 photos only.'),
            ),
          );
          break;
        }

        final alreadyExists = pickedImages.any((f) => f.name == img.name);
        if (!alreadyExists) pickedImages.add(img);
      }

      // ✅ Handle single video limit
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

          // Simulate attachment progress
          for (int i = 0; i <= 100; i++) {
            await Future.delayed(const Duration(milliseconds: 20));
            attachProgress = i / 100;
            setState(() {});
          }

          // Initialize video preview after "progress" finishes
          final uri = Uri.dataFromBytes(
            pickedVideo!.bytes!,
            mimeType: 'video/mp4',
          );
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Media selection failed: $e")));
    }
  }

  // 🚀 Step 2: Upload all to Supabase
  Future<List<String>> uploadAllToSupabase() async {
    final supabase = Supabase.instance.client;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final List<String> urls = [];

    // Upload images
    for (final file in pickedImages) {
      try {
        final fileBytes = file.bytes!;
        final path =
            'ReturnandRefund/${user.uid}_${DateTime.now().millisecondsSinceEpoch}_${file.name}';
        await supabase.storage.from('QuickCoat').uploadBinary(path, fileBytes);
        final url = supabase.storage.from('QuickCoat').getPublicUrl(path);
        urls.add(url);
      } catch (e) {
        debugPrint("Image upload error for ${file.name}: $e");
      }
    }

    // Upload single video
    if (pickedVideo != null) {
      try {
        final fileBytes = pickedVideo!.bytes!;
        final path =
            'ReturnandRefund/${user.uid}_${DateTime.now().millisecondsSinceEpoch}_${pickedVideo!.name}';
        await supabase.storage.from('QuickCoat').uploadBinary(path, fileBytes);
        final url = supabase.storage.from('QuickCoat').getPublicUrl(path);
        urls.add(url);
      } catch (e) {
        debugPrint("Video upload error: $e");
      }
    }

    return urls;
  }

  // 🪟 Step 3: Show the dialog
  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(
              'Return & Refund',
              style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
            ),
            content: SizedBox(
              height: MediaQuery.of(context).size.height / 1.8,
              width: MediaQuery.of(context).size.width / 3,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select reason for return & refund:',
                      style: GoogleFonts.roboto(),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: selectedReason,
                      items:
                          reasons
                              .map(
                                (r) => DropdownMenuItem<String>(
                                  value: r,
                                  child: Text(r, style: GoogleFonts.roboto()),
                                ),
                              )
                              .toList(),
                      onChanged: (v) => setState(() => selectedReason = v),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: reasonController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        hintText: 'Add more details (optional)...',
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

                    // 🖼️ Media Previews
                    if (pickedVideo != null || pickedImages.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 🎥 Video on top (full width)
                          // 🖼️ Media Previews Section
                          if (pickedVideo != null || pickedImages.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 🎥 Video on top
                                if (pickedVideo != null)
                                  Stack(
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        height: 220,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: Colors.grey.shade300,
                                          ),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          child:
                                              isAttachingVideo
                                                  ? Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                          20,
                                                        ),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          "Attaching video...",
                                                          style:
                                                              GoogleFonts.roboto(
                                                                fontSize: 14,
                                                                color:
                                                                    Colors
                                                                        .grey
                                                                        .shade700,
                                                              ),
                                                        ),
                                                        const SizedBox(
                                                          height: 12,
                                                        ),
                                                        LinearProgressIndicator(
                                                          value: attachProgress,
                                                          minHeight: 6,
                                                          color:
                                                              AppColors.color8,
                                                          backgroundColor:
                                                              Colors
                                                                  .grey
                                                                  .shade300,
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                4,
                                                              ),
                                                        ),
                                                        const SizedBox(
                                                          height: 8,
                                                        ),
                                                        Text(
                                                          "${(attachProgress * 100).toInt()}%",
                                                          style:
                                                              GoogleFonts.roboto(
                                                                fontSize: 13,
                                                                color:
                                                                    Colors
                                                                        .grey
                                                                        .shade600,
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                  : (videoChewieController !=
                                                          null
                                                      ? Chewie(
                                                        controller:
                                                            videoChewieController!,
                                                      )
                                                      : const Center(
                                                        child: Text(
                                                          "Video preview unavailable",
                                                        ),
                                                      )),
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
                                              decoration: const BoxDecoration(
                                                color: Colors.black54,
                                                shape: BoxShape.circle,
                                              ),
                                              padding: const EdgeInsets.all(4),
                                              child: const Icon(
                                                Icons.close,
                                                color: Colors.white,
                                                size: 18,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),

                                const SizedBox(height: 12),

                                // 🖼️ Images below video
                                if (pickedImages.isNotEmpty)
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children:
                                        pickedImages.map((img) {
                                          return Stack(
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
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
                                                        const BoxDecoration(
                                                          color: Colors.black54,
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                    padding:
                                                        const EdgeInsets.all(2),
                                                    child: const Icon(
                                                      Icons.close,
                                                      color: Colors.white,
                                                      size: 16,
                                                    ),
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
                  ],
                ),
              ),
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      videoController?.dispose();
                      videoChewieController?.dispose();
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.roboto(color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.color8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () async {
                      if (selectedReason == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please select a reason'),
                          ),
                        );
                        return;
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Uploading files...')),
                      );

                      final uploadedUrls = await uploadAllToSupabase();

                      await FirebaseFirestore.instance
                          .collection('orders')
                          .doc(orderId)
                          .update({
                            'status1': 'pending',
                            'status': 'Return&Refund',
                            'returnReason': selectedReason,
                            'returnDetails': reasonController.text.trim(),
                            'returnRequestedAt': Timestamp.now(),
                            'returnMedia': uploadedUrls, // ✅ list of URLs
                          });

                      videoController?.dispose();
                      videoChewieController?.dispose();

                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Return & refund requested successfully ✅',
                          ),
                        ),
                      );
                    },
                    child: Text(
                      'Submit',
                      style: GoogleFonts.roboto(color: Colors.white),
                    ),
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
