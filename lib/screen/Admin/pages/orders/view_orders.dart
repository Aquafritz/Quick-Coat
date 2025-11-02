import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:quickcoat/animations/hover_extensions.dart';
import 'package:quickcoat/core/colors/app_colors.dart';
import 'package:quickcoat/screen/Admin/top_bar.dart';
import 'package:video_player/video_player.dart';

class ViewOrders extends StatelessWidget {
  final Map<String, dynamic> orderData;
  final String orderId;
  final String orderType;

  const ViewOrders({
    super.key,
    required this.orderData,
    required this.orderId,
    required this.orderType,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            TopBar(),

            Padding(
              padding: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.width / 80,
                horizontal: MediaQuery.of(context).size.width / 80,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Get.back();
                        },
                        child: Icon(Icons.arrow_back_ios),
                      ).showCursorOnHover.moveUpOnHover,
                      Text(
                        'Order Details',
                        style: GoogleFonts.roboto(
                          fontSize: MediaQuery.of(context).size.width / 70,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  contextCard(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget contextCard(BuildContext context) {
    final cartItems = List<Map<String, dynamic>>.from(
      orderData["cartItems"] ?? [],
    );

    final selectedAddress = orderData["selectedAddress"] ?? {};
    final userDetails = orderData["userDetails"] ?? {};
    final orderDate =
        (orderData["timestamp"] != null)
            ? DateFormat(
              'MMM dd, yyyy – hh:mm a',
            ).format(orderData["timestamp"].toDate())
            : "-";

    final cancelledAt =
        (orderData['cancelledAt'] != null)
            ? DateFormat(
              'MMM dd, yyyy – hh:mm a',
            ).format(orderData['cancelledAt'].toDate())
            : "N/A";

    final returnRequestedAt =
        (orderData['returnRequestedAt'] != null)
            ? DateFormat(
              'MMM dd, yyyy – hh:mm a',
            ).format(orderData['returnRequestedAt'].toDate())
            : "N/A";

    return Container(
      width: MediaQuery.of(context).size.width / 1.5,
      height: MediaQuery.of(context).size.width / 2.7,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.width / 80,
          horizontal: MediaQuery.of(context).size.width / 80,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Costumer Information
              CircleAvatar(
                radius: MediaQuery.of(context).size.width / 20,
                backgroundImage:
                    userDetails['profile_picture'] != null
                        ? NetworkImage(userDetails['profile_picture'])
                        : null,
                child:
                    userDetails['profile_picture'] == null
                        ? const Icon(Icons.person, size: 50)
                        : null,
              ),
              SizedBox(height: MediaQuery.of(context).size.width / 60),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Customer Information",
                    style: GoogleFonts.roboto(
                      fontSize: MediaQuery.of(context).size.width / 90,
                      fontWeight: FontWeight.bold,
                      color: AppColors.color8,
                    ),
                  ),
                  Divider(color: AppColors.color8, thickness: 2),
                  Text(
                    "Customer Name: ",
                    style: GoogleFonts.roboto(
                      fontSize: MediaQuery.of(context).size.width / 90,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "${userDetails["full_name"] ?? "N/A"}",
                    style: GoogleFonts.roboto(
                      fontSize: MediaQuery.of(context).size.width / 100,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.width / 90),
                  Text(
                    "Customer Phone Number: ",
                    style: GoogleFonts.roboto(
                      fontSize: MediaQuery.of(context).size.width / 90,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "${userDetails["phone_number"] ?? "N/A"}",
                    style: GoogleFonts.roboto(
                      fontSize: MediaQuery.of(context).size.width / 100,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.width / 90),
                  Text(
                    "Customer Email Address: ",
                    style: GoogleFonts.roboto(
                      fontSize: MediaQuery.of(context).size.width / 90,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "${userDetails["email_Address"] ?? "N/A"}",
                    style: GoogleFonts.roboto(
                      fontSize: MediaQuery.of(context).size.width / 100,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.width / 90),
                  Text(
                    "Customer Address: ",
                    style: GoogleFonts.roboto(
                      fontSize: MediaQuery.of(context).size.width / 90,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "${selectedAddress["house_number"] ?? "N/A"} ${selectedAddress["barangay"] ?? "N/A"} ${selectedAddress["city_municipality"] ?? "N/A"} ${selectedAddress["province"] ?? "N/A"}  ${selectedAddress["country"] ?? "N/A"}  ${selectedAddress["postal_code"] ?? "N/A"}",
                    style: GoogleFonts.roboto(
                      fontSize: MediaQuery.of(context).size.width / 100,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.width / 60),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Order Information",
                    style: GoogleFonts.roboto(
                      fontSize: MediaQuery.of(context).size.width / 90,
                      fontWeight: FontWeight.bold,
                      color: AppColors.color8,
                    ),
                  ),
                  Divider(color: AppColors.color8, thickness: 2),
                  Text(
                    "Order Status: ",
                    style: GoogleFonts.roboto(
                      fontSize: MediaQuery.of(context).size.width / 90,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "${orderData['status'] ?? 'N/A'}",
                    style: GoogleFonts.roboto(
                      fontSize: MediaQuery.of(context).size.width / 100,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.width / 90),
                  Text(
                    "Date Ordered: ",
                    style: GoogleFonts.roboto(
                      fontSize: MediaQuery.of(context).size.width / 90,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "$orderDate",
                    style: GoogleFonts.roboto(
                      fontSize: MediaQuery.of(context).size.width / 100,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.width / 90),
                  // 💳 Payment Method (fetched from Firestore)
                  Text(
                    "Payment Method:",
                    style: GoogleFonts.roboto(
                      fontSize: MediaQuery.of(context).size.width / 90,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    orderData['payment_method'] != null &&
                            orderData['payment_method'].toString().isNotEmpty
                        ? orderData['payment_method'].toString()
                        : "Not specified",
                    style: GoogleFonts.roboto(
                      fontSize: MediaQuery.of(context).size.width / 100,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.width / 90),
                  if (orderType == "Cancelled") ...[
                    Text(
                      "Cancellation Reason: ",
                      style: GoogleFonts.roboto(
                        fontSize: MediaQuery.of(context).size.width / 90,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "${orderData['cancelReason'] ?? 'N/A'}",
                      style: GoogleFonts.roboto(
                        fontSize: MediaQuery.of(context).size.width / 100,
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    SizedBox(height: MediaQuery.of(context).size.width / 90),
                    Text(
                      "Cancellation Date: ",
                      style: GoogleFonts.roboto(
                        fontSize: MediaQuery.of(context).size.width / 90,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "$cancelledAt",
                      style: GoogleFonts.roboto(
                        fontSize: MediaQuery.of(context).size.width / 100,
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    SizedBox(height: MediaQuery.of(context).size.width / 90),
                    Text(
                      "Subtotal: ",
                      style: GoogleFonts.roboto(
                        fontSize: MediaQuery.of(context).size.width / 90,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "${orderData['subtotal'] ?? 'N/A'}",
                      style: GoogleFonts.roboto(
                        fontSize: MediaQuery.of(context).size.width / 100,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.width / 90),
                    Text(
                      "Total: ",
                      style: GoogleFonts.roboto(
                        fontSize: MediaQuery.of(context).size.width / 90,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "${orderData['total'] ?? 'N/A'}",
                      style: GoogleFonts.roboto(
                        fontSize: MediaQuery.of(context).size.width / 100,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.width / 90),
                  ],
                  if (orderType == "Return&Refund") ...[
                    Text(
                      "Return Reason: ",
                      style: GoogleFonts.roboto(
                        fontSize: MediaQuery.of(context).size.width / 90,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Return Reason: ${orderData['returnReason'] ?? 'N/A'}",
                      style: GoogleFonts.roboto(
                        fontSize: MediaQuery.of(context).size.width / 100,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.width / 90),

                    Text(
                      "Refund Details: ",
                      style: GoogleFonts.roboto(
                        fontSize: MediaQuery.of(context).size.width / 90,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "${orderData['returnDetails'] ?? 'Pending'}",
                      style: GoogleFonts.roboto(
                        fontSize: MediaQuery.of(context).size.width / 100,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.width / 90),
                    Text(
                      "Return Requested At: ",
                      style: GoogleFonts.roboto(
                        fontSize: MediaQuery.of(context).size.width / 90,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "$returnRequestedAt",
                      style: GoogleFonts.roboto(
                        fontSize: MediaQuery.of(context).size.width / 100,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.width / 90),
                    Text(
                      "Refund Status: ",
                      style: GoogleFonts.roboto(
                        fontSize: MediaQuery.of(context).size.width / 90,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "${orderData['status1'] ?? 'Pending'}",
                      style: GoogleFonts.roboto(
                        fontSize: MediaQuery.of(context).size.width / 100,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    buildReturnMediaSection(context),
                  ],
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.width / 60),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Product Information",
                    style: GoogleFonts.roboto(
                      fontSize: MediaQuery.of(context).size.width / 90,
                      fontWeight: FontWeight.bold,
                      color: AppColors.color8,
                    ),
                  ),
                  Divider(color: AppColors.color8, thickness: 2),

                  ListView.builder(
                    itemCount: cartItems.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      final imageUrl =
                          item["productImages"] is String
                              ? item["productImages"]
                              : (item["productImages"] as List?)?.isNotEmpty ==
                                  true
                              ? item["productImages"][0]
                              : "https://via.placeholder.com/80";

                      return Container(
                        width: MediaQuery.of(context).size.width / 1.5,
                        padding: EdgeInsets.all(
                          MediaQuery.of(context).size.width / 100,
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                imageUrl,
                                width:
                                    MediaQuery.of(context).size.width /
                                    10, // bigger image
                                height: MediaQuery.of(context).size.width / 10,
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Product Name:",
                                    style: GoogleFonts.roboto(
                                      fontSize:
                                          MediaQuery.of(context).size.width /
                                          100,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    item["productName"] ?? "No name",
                                    style: GoogleFonts.roboto(
                                      fontSize:
                                          MediaQuery.of(context).size.width /
                                          110,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  Text(
                                    "Product Size:",
                                    style: GoogleFonts.roboto(
                                      fontSize:
                                          MediaQuery.of(context).size.width /
                                          100,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "${item["selectedSize"] ?? ""}",
                                    style: GoogleFonts.roboto(
                                      fontSize:
                                          MediaQuery.of(context).size.width /
                                          110,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  Text(
                                    "Size Description:",
                                    style: GoogleFonts.roboto(
                                      fontSize:
                                          MediaQuery.of(context).size.width /
                                          100,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "${item["productSizedDescription"] ?? ""}",
                                    style: GoogleFonts.roboto(
                                      fontSize:
                                          MediaQuery.of(context).size.width /
                                          110,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  Text(
                                    "Product Color:",
                                    style: GoogleFonts.roboto(
                                      fontSize:
                                          MediaQuery.of(context).size.width /
                                          100,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "${item["selectedColor"] ?? ""}",
                                    style: GoogleFonts.roboto(
                                      fontSize:
                                          MediaQuery.of(context).size.width /
                                          110,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  Text(
                                    "Product Quantity:",
                                    style: GoogleFonts.roboto(
                                      fontSize:
                                          MediaQuery.of(context).size.width /
                                          100,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "x${item["quantity"] ?? 1}",
                                    style: GoogleFonts.roboto(
                                      fontSize:
                                          MediaQuery.of(context).size.width /
                                          110,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  Text(
                                    "Product Price:",
                                    style: GoogleFonts.roboto(
                                      fontSize:
                                          MediaQuery.of(context).size.width /
                                          100,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "₱${item["productPrice"] ?? 0} ",
                                    style: GoogleFonts.roboto(
                                      fontSize:
                                          MediaQuery.of(context).size.width /
                                          110,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildReturnMediaSection(BuildContext context) {
    final mediaList = orderData['returnMedia'] ?? [];

    if (mediaList.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Text(
          "No attached media",
          style: GoogleFonts.roboto(
            fontSize: MediaQuery.of(context).size.width / 100,
            color: Colors.grey.shade600,
          ),
        ),
      );
    }

    // Separate videos and images
    final videoList =
        mediaList.where((url) {
          final lower = url.toString().toLowerCase();
          return lower.endsWith('.mp4') ||
              lower.endsWith('.mov') ||
              lower.endsWith('.avi');
        }).toList();

    final imageList =
        mediaList.where((url) {
          final lower = url.toString().toLowerCase();
          return lower.endsWith('.jpg') ||
              lower.endsWith('.jpeg') ||
              lower.endsWith('.png') ||
              lower.endsWith('.webp');
        }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: MediaQuery.of(context).size.width / 90),
        Text(
          "Attached Media:",
          style: GoogleFonts.roboto(
            fontSize: MediaQuery.of(context).size.width / 90,
            fontWeight: FontWeight.bold,
            color: AppColors.color8,
          ),
        ),
        Divider(color: AppColors.color8, thickness: 2),
        const SizedBox(height: 10),

        // 🎥 Show video on top (full width)
        if (videoList.isNotEmpty) ...[
          ...videoList.map((url) {
            return Container(
              width: 400,
              margin: const EdgeInsets.only(bottom: 15),
              height: 250,
              child: ReturnVideoPlayer(url: url),
            );
          }).toList(),
        ],

        // 🖼️ Show images below in a grid-like layout
        if (imageList.isNotEmpty)
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children:
                imageList.map<Widget>((url) {
                  return GestureDetector(
                    onTap:
                        () => showDialog(
                          context: context,
                          builder:
                              (_) => Dialog(
                                backgroundColor: Colors.black87,
                                child: InteractiveViewer(
                                  child: Image.network(
                                    url,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                        ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        url,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            width: 120,
                            height: 120,
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        },
                        errorBuilder:
                            (context, error, stackTrace) => Container(
                              width: 120,
                              height: 120,
                              color: Colors.grey.shade300,
                              child: const Icon(
                                Icons.broken_image,
                                color: Colors.grey,
                              ),
                            ),
                      ),
                    ),
                  );
                }).toList(),
          ),
      ],
    );
  }
}

class ReturnVideoPlayer extends StatefulWidget {
  final String url;
  const ReturnVideoPlayer({super.key, required this.url});

  @override
  State<ReturnVideoPlayer> createState() => _ReturnVideoPlayerState();
}

class _ReturnVideoPlayerState extends State<ReturnVideoPlayer> {
  late VideoPlayerController _videoController;
  ChewieController? _chewieController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(widget.url),
      );
      await _videoController.initialize();
      _chewieController = ChewieController(
        videoPlayerController: _videoController,
        autoPlay: false,
        looping: false,
        aspectRatio: _videoController.value.aspectRatio,
      );
      setState(() => _isLoading = false);
    } catch (e) {
      debugPrint("Video load error: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _videoController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Chewie(controller: _chewieController!),
    );
  }
}
