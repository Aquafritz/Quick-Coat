import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickcoat/core/colors/app_colors.dart';

class Products extends StatelessWidget {
  final List<Map<String, dynamic>> products = [
    {
      "image": "assets/images/product1.png",
      "title": "Classic Coat",
      "description": "A timeless classic for all seasons.",
      "colors": [
        Colors.black,
        Colors.brown,
        Colors.grey,
        Colors.blue,
        Colors.red,
        Colors.green,
      ],
      "price": "₱6,800",
    },
    {
      "image": "assets/images/product2.png",
      "title": "Modern Jacket",
      "description": "Stay stylish and warm with this modern jacket.",
      "colors": [
        Colors.blue,
        Colors.red,
        Colors.green,
        Colors.yellow,
        Colors.purple,
        Colors.orange,
      ],
      "price": "₱8,500",
    },
    {
      "image": "assets/images/product3.png",
      "title": "Winter Coat",
      "description": "Perfect for cold winter days.",
      "colors": [
        Colors.white,
        Colors.black,
        Colors.grey,
        Colors.brown,
        Colors.blue,
        Colors.teal,
      ],
      "price": "₱10,200",
    },
    {
      "image": "assets/images/product4.png",
      "title": "Leather Jacket",
      "description": "Premium leather for a bold look.",
      "colors": [
        Colors.brown,
        Colors.black,
        Colors.grey,
        Colors.red,
        Colors.orange,
        Colors.green,
      ],
      "price": "₱12,000",
    },
    {
      "image": "assets/images/product5.png",
      "title": "Casual Blazer",
      "description": "Smart and casual for any occasion.",
      "colors": [
        Colors.blue,
        Colors.grey,
        Colors.black,
        Colors.brown,
        Colors.green,
        Colors.pink,
      ],
      "price": "₱7,300",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: MediaQuery.of(context).size.width / 80,
        horizontal: MediaQuery.of(context).size.width / 15,
      ),
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Text(
            'Our Products',
            style: TextStyle(
              color: Colors.black,
              fontSize: MediaQuery.of(context).size.width / 65,
              fontWeight: FontWeight.bold,
              fontFamily: GoogleFonts.inter().fontFamily,
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.width / 150),
          Text(
            'Discover our wide range of high-quality kapote products',
            style: TextStyle(
              color: Colors.black,
              fontSize: MediaQuery.of(context).size.width / 90,
              fontFamily: GoogleFonts.inter().fontFamily,
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.width / 90),

          // Product Grid
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sidebar filter
              SizedBox(
                width:
                    MediaQuery.of(context).size.width /
                    5, // give the filter panel a fixed width
                height: MediaQuery.of(context).size.width / 5,
                child: Card(
                  elevation: 8,
                  child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Filters',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 150,
                            ),
                            Icon(Icons.filter_list),
                          ],
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.width / 80,
                        ),
                        Text('Size'),
                        Container(
                          width:
                              MediaQuery.of(context).size.width /
                              5, // ✅ control the width of the dropdown
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey, // border color
                              width: 1.5, // border thickness
                            ),
                            borderRadius: BorderRadius.circular(
                              10,
                            ), // rounded corners
                          ),
                          child: DropdownButton<String>(
                            isExpanded:
                                true, // ✅ makes dropdown take full width of container
                            underline:
                                SizedBox(), // ✅ removes the default underline
                            elevation: 8,
                            borderRadius: BorderRadius.circular(10),
                            items: [
                              DropdownMenuItem(
                                value: "S",
                                child: Text("Small"),
                              ),
                              DropdownMenuItem(
                                value: "M",
                                child: Text("Medium"),
                              ),
                              DropdownMenuItem(
                                value: "L",
                                child: Text("Large"),
                              ),
                            ],
                            onChanged: (value) {},
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.width / 80,
                        ),
                        Text('Colors'),
                        Container(
                          width:
                              MediaQuery.of(context).size.width /
                              5, // ✅ control the width of the dropdown
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey, // border color
                              width: 1.5, // border thickness
                            ),
                            borderRadius: BorderRadius.circular(
                              10,
                            ), // rounded corners
                          ),
                          child: DropdownButton<String>(
                            isExpanded:
                                true, // ✅ makes dropdown take full width of container
                            underline:
                                SizedBox(), // ✅ removes the default underline
                            elevation: 8,
                            borderRadius: BorderRadius.circular(10),
                            items: [
                              DropdownMenuItem(
                                value: "black",
                                child: Text("Black"),
                              ),
                              DropdownMenuItem(
                                value: "blue",
                                child: Text("Blue"),
                              ),
                              DropdownMenuItem(
                                value: "red",
                                child: Text("Red"),
                              ),
                            ],
                            onChanged: (value) {},
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.width / 80,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width / 1,
                          height: MediaQuery.of(context).size.width / 35,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.color8,
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {},
                            child: Text(
                              'Apply Filters',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(width: MediaQuery.of(context).size.width / 100),

              // Product Grid → take the remaining space
              Expanded(
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(), // let parent scroll
                  itemCount: products.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: 3 / 4,
                  ),
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product Image
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(
                                  product["image"],
                                  fit: BoxFit.contain,
                                  width: double.infinity,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.width / 80,
                            ),

                            // Product Title
                            Text(
                              product["title"],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                fontFamily: GoogleFonts.inter().fontFamily,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),

                            // Description
                            Text(
                              product["description"],
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),

                            SizedBox(
                              height: MediaQuery.of(context).size.width / 80,
                            ),

                            Container(
                              width: MediaQuery.of(context).size.width / 10,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.black,
                                        width: 1,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text("S"),
                                    ),
                                  ),

                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.black,
                                        width: 1,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text("M"),
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.black,
                                        width: 1,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text("L"),
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.black,
                                        width: 1,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text("XL"),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(
                              height: MediaQuery.of(context).size.width / 80,
                            ),

                            // Colors Row
                            Row(
                              children:
                                  (product["colors"] as List<Color>)
                                      .take(4)
                                      .map(
                                        (color) => Container(
                                          margin: const EdgeInsets.only(
                                            right: 4,
                                          ),
                                          width: 15,
                                          height: 15,
                                          decoration: BoxDecoration(
                                            color: color,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.grey.shade300,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                            ),

                            SizedBox(
                              height: MediaQuery.of(context).size.width / 80,
                            ),

                            // Price
                            Text(
                              product["price"],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.color11,
                              ),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.width / 80,
                            ),

                            Container(
                              width: MediaQuery.of(context).size.width / 1,
                              height: MediaQuery.of(context).size.width / 35,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.color8,
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () {
                                  Get.toNamed('/productDetails');
                                },
                                child: Text(
                                  'View Details',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
