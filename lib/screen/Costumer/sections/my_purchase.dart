import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:quickcoat/core/colors/app_colors.dart';
import 'package:quickcoat/screen/header&footer/headerwithoutsignin.dart';
import 'dart:ui' as ui;

class MyPurchase extends StatefulWidget {
  const MyPurchase({super.key});

  @override
  State<MyPurchase> createState() => _MyPurchaseState();
}

class _MyPurchaseState extends State<MyPurchase> {
  int selectedIndex = 0;

  Widget _buildSelectedWidget() {
    switch (selectedIndex) {
      case 0:
        return buildAll();
      case 1:
        return buildPending();
      case 2:
        return buildProcessing();
      case 3:
        return buildShipped();
      case 4:
        return buildDelivered();
      case 5:
        return buildCancelled();
      case 6:
        return buildReturnRefund();
      default:
        return buildAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              const HeaderWithout(),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width / 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Purchase',
                      style: GoogleFonts.roboto(
                        fontSize: MediaQuery.of(context).size.width / 60,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
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
                      height: MediaQuery.of(context).size.width / 2.8,
                      width: MediaQuery.of(context).size.width / 1,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          children: [
                            _buildNavBar(context),
                            const SizedBox(height: 20),
                            _buildSelectedWidget(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavBar(BuildContext context) {
    final tabs = [
      "All",
      "Pending",
      "Processing",
      "Shipped",
      "Delivered",
      "Cancelled",
      "Return & Refund",
    ];

    final List<double> textWidths =
        tabs.map((title) {
          final textPainter = TextPainter(
            text: TextSpan(
              text: title,
              style: GoogleFonts.roboto(
                fontSize: MediaQuery.of(context).size.width / 90,
              ),
            ),
            textDirection: ui.TextDirection.ltr,
          )..layout();

          return textPainter.width;
        }).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final tabWidth = constraints.maxWidth / tabs.length;

        return SizedBox(
          height: MediaQuery.of(context).size.width / 50,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(
                  tabs.length,
                  (index) => GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedIndex = index;
                      });
                    },
                    child: SizedBox(
                      width: tabWidth,
                      child: Center(
                        child: Text(
                          tabs[index],
                          style: GoogleFonts.roboto(
                            fontSize: MediaQuery.of(context).size.width / 90,
                            fontWeight:
                                selectedIndex == index
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                            color:
                                selectedIndex == index
                                    ? AppColors.color8
                                    : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                left:
                    tabWidth * selectedIndex +
                    (tabWidth - textWidths[selectedIndex]) / 2,
                bottom: -5,
                child: Container(
                  height: 2,
                  width: textWidths[selectedIndex],
                  color: AppColors.color8,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildAll() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text("Please sign in to see your orders"));
    }

    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection("orders")
              .where("userId", isEqualTo: user.uid)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No orders found"));
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
                            order['status'] ?? "Unknown",
                            style: GoogleFonts.roboto(
                              color: AppColors.color8,
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
                                  item["productImage"] is String
                                      ? item["productImage"]
                                      : (item["productImage"] as List?)
                                              ?.isNotEmpty ==
                                          true
                                      ? item["productImage"][0]
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
                          Text(
                            order['timestamp'] != null
                                ? DateFormat(
                                  "MMMM dd, yyyy 'at' hh:mm:ss a",
                                ).format(
                                  (order['timestamp'] as Timestamp)
                                      .toDate()
                                      .toLocal(),
                                )
                                : "",
                            style: GoogleFonts.roboto(
                              fontSize: MediaQuery.of(context).size.width / 110,
                              color: Colors.grey,
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

  Widget buildPending() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text("Please sign in to see your orders"));
    }

    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection("orders")
              .where("userId", isEqualTo: user.uid)
              .where("status", isEqualTo: "Pending")
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
                                  item["productImage"] is String
                                      ? item["productImage"]
                                      : (item["productImage"] as List?)
                                              ?.isNotEmpty ==
                                          true
                                      ? item["productImage"][0]
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
                          Text(
                            order['timestamp'] != null
                                ? DateFormat(
                                  "MMMM dd, yyyy 'at' hh:mm:ss a",
                                ).format(
                                  (order['timestamp'] as Timestamp)
                                      .toDate()
                                      .toLocal(),
                                )
                                : "",
                            style: GoogleFonts.roboto(
                              fontSize: MediaQuery.of(context).size.width / 110,
                              color: Colors.grey,
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

  static Widget buildProcessing() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text("Please sign in to see your orders"));
    }

    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection("orders")
              .where("userId", isEqualTo: user.uid)
              .where("status", isEqualTo: "Processing")
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
                                  item["productImage"] is String
                                      ? item["productImage"]
                                      : (item["productImage"] as List?)
                                              ?.isNotEmpty ==
                                          true
                                      ? item["productImage"][0]
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
                          Text(
                            order['timestamp'] != null
                                ? DateFormat(
                                  "MMMM dd, yyyy 'at' hh:mm:ss a",
                                ).format(
                                  (order['timestamp'] as Timestamp)
                                      .toDate()
                                      .toLocal(),
                                )
                                : "",

                            style: GoogleFonts.roboto(
                              fontSize: MediaQuery.of(context).size.width / 110,
                              color: Colors.grey,
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

  static Widget buildShipped() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text("Please sign in to see your orders"));
    }

    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection("orders")
              .where("userId", isEqualTo: user.uid)
              .where("status", isEqualTo: "Shipped")
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
                                  item["productImage"] is String
                                      ? item["productImage"]
                                      : (item["productImage"] as List?)
                                              ?.isNotEmpty ==
                                          true
                                      ? item["productImage"][0]
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
                          Text(
                            order['timestamp'] != null
                                ? DateFormat(
                                  "MMMM dd, yyyy 'at' hh:mm:ss a",
                                ).format(
                                  (order['timestamp'] as Timestamp)
                                      .toDate()
                                      .toLocal(),
                                )
                                : "",

                            style: GoogleFonts.roboto(
                              fontSize: MediaQuery.of(context).size.width / 110,
                              color: Colors.grey,
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

  static Widget buildDelivered() {
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
                                  item["productImage"] is String
                                      ? item["productImage"]
                                      : (item["productImage"] as List?)
                                              ?.isNotEmpty ==
                                          true
                                      ? item["productImage"][0]
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
                          Text(
                            order['timestamp'] != null
                                ? DateFormat(
                                  "MMMM dd, yyyy 'at' hh:mm:ss a",
                                ).format(
                                  (order['timestamp'] as Timestamp)
                                      .toDate()
                                      .toLocal(),
                                )
                                : "",
                            style: GoogleFonts.roboto(
                              fontSize: MediaQuery.of(context).size.width / 110,
                              color: Colors.grey,
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

  static Widget buildCancelled() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text("Please sign in to see your orders"));
    }

    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection("orders")
              .where("userId", isEqualTo: user.uid)
              .where("status", isEqualTo: "Cancel")
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
                                  item["productImage"] is String
                                      ? item["productImage"]
                                      : (item["productImage"] as List?)
                                              ?.isNotEmpty ==
                                          true
                                      ? item["productImage"][0]
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
                          Text(
                            order['timestamp'] != null
                                ? DateFormat(
                                  "MMMM dd, yyyy 'at' hh:mm:ss a",
                                ).format(
                                  (order['timestamp'] as Timestamp)
                                      .toDate()
                                      .toLocal(),
                                )
                                : "",
                            style: GoogleFonts.roboto(
                              fontSize: MediaQuery.of(context).size.width / 110,
                              color: Colors.grey,
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

  static Widget buildReturnRefund() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text("Please sign in to see your orders"));
    }

    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection("orders")
              .where("userId", isEqualTo: user.uid)
              .where("status", isEqualTo: "Return&Refund")
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
                                  item["productImage"] is String
                                      ? item["productImage"]
                                      : (item["productImage"] as List?)
                                              ?.isNotEmpty ==
                                          true
                                      ? item["productImage"][0]
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
                          Text(
                            order['timestamp'] != null
                                ? DateFormat(
                                  "MMMM dd, yyyy 'at' hh:mm:ss a",
                                ).format(
                                  (order['timestamp'] as Timestamp)
                                      .toDate()
                                      .toLocal(),
                                )
                                : "",
                            style: GoogleFonts.roboto(
                              fontSize: MediaQuery.of(context).size.width / 110,
                              color: Colors.grey,
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
}
