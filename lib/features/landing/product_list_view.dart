import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickcoat/core/colors/app_colors.dart';

class ProductListView extends StatelessWidget {
  final List<Map<String, dynamic>> products = [
    {
      "image": "assets/images/product1.png",
      "title": "Classic Coat",
      "description": "A timeless classic for all seasons.",
      "colors": [Colors.black, Colors.brown, Colors.grey, Colors.blue, Colors.red, Colors.green],
      "price": "₱6,800"
    },
    {
      "image": "assets/images/product2.png",
      "title": "Modern Jacket",
      "description": "Stay stylish and warm with this modern jacket.",
      "colors": [Colors.blue, Colors.red, Colors.green, Colors.yellow, Colors.purple, Colors.orange],
      "price": "₱8,500"
    },
    {
      "image": "assets/images/product3.png",
      "title": "Winter Coat",
      "description": "Perfect for cold winter days.",
      "colors": [Colors.white, Colors.black, Colors.grey, Colors.brown, Colors.blue, Colors.teal],
      "price": "₱10,200"
    },
    {
      "image": "assets/images/product4.png",
      "title": "Leather Jacket",
      "description": "Premium leather for a bold look.",
      "colors": [Colors.brown, Colors.black, Colors.grey, Colors.red, Colors.orange, Colors.green],
      "price": "₱12,000"
    },
    {
      "image": "assets/images/product5.png",
      "title": "Casual Blazer",
      "description": "Smart and casual for any occasion.",
      "colors": [Colors.blue, Colors.grey, Colors.black, Colors.brown, Colors.green, Colors.pink],
      "price": "₱7,300"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: MediaQuery.of(context).size.width / 80,
      ),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.width / 2.7,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding:  EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width/80),
        itemCount: products.length,
        separatorBuilder: (_, __) => SizedBox(width: MediaQuery.of(context).size.width / 40),
        itemBuilder: (context, index) {
          final product = products[index];
          final List<Color> colors = List<Color>.from(product["colors"]);
          final bool hasMoreColors = colors.length > 5;
          return Container(
            width: MediaQuery.of(context).size.width / 5,
            padding: EdgeInsets.all(MediaQuery.of(context).size.width / 100),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width / 100),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width / 100),
                    child: Image.asset(product["image"], fit: BoxFit.cover),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.width / 150),
                Text(
                  product["title"],
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: MediaQuery.of(context).size.width / 60,
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.width / 150),
                Row(
                  children: [
                    ...List.generate(
                      hasMoreColors ? 5 : colors.length,
                      (colorIndex) => Padding(
                        padding:  EdgeInsets.only(right: MediaQuery.of(context).size.width / 180),
                        child: CircleAvatar(
                          radius: MediaQuery.of(context).size.width / 120,
                          backgroundColor: colors[colorIndex],
                        ),
                      ),
                    ),
                    if (hasMoreColors)
                      Padding(
                        padding: EdgeInsets.only(left: MediaQuery.of(context).size.width / 250),
                        child: Text(
                          "+ more",
                          style: GoogleFonts.inter(
                            fontSize: MediaQuery.of(context).size.width / 90,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).size.width / 150),
                Text(
                  product["description"] ?? "",
                  style: GoogleFonts.inter(
                    fontSize: MediaQuery.of(context).size.width / 90,
                    color: Colors.grey[700],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product["price"],
                      style: GoogleFonts.inter(
                        color: AppColors.color11,
                        fontWeight: FontWeight.bold,
                        fontSize: MediaQuery.of(context).size.width / 65,
                      ),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width / 150),
                    Text(
                      "View Details",
                      style: GoogleFonts.inter(
                        color: AppColors.color10,
                        fontSize: MediaQuery.of(context).size.width / 80,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}