import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitmom_guide/presentation/screen/testimonial/add/add_testimonial_screen.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'widget/image_frame_widget.dart';
import 'widget/like_button_widget.dart';

class TestimonialScreen extends StatefulWidget {
  const TestimonialScreen({super.key});

  @override
  State<TestimonialScreen> createState() => _TestimonialScreenState();
}

class _TestimonialScreenState extends State<TestimonialScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F3),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('testimonials').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "Belum ada testimoni",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          var testimonials = snapshot.data!.docs;

          return Column(
            children: [
              Expanded(
                child: CarouselSlider.builder(
                  options: CarouselOptions(
                    height: screenHeight * 0.55,
                    enlargeCenterPage: true,
                    autoPlay: true,
                    autoPlayInterval: const Duration(seconds: 4),
                    viewportFraction: 0.85,
                  ),
                  itemCount: testimonials.length,
                  itemBuilder: (context, index, realIndex) {
                    var testimonial = testimonials[index];
                    var data = testimonial.data() as Map<String, dynamic>;

                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                          Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      LikeButton(docId: testimonial.id),
                                      Text(
                                        '${data['totalLikes'] ?? 0} orang menyukai',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.pinkAccent,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 15),

                                  // Gambar Before & After
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Flexible(
                                        child: ImageFrame(
                                          imagePath: data['before'] ?? '',
                                          screenWidth: screenWidth,
                                        ),
                                      ),
                                      const Icon(Icons.arrow_forward,
                                          color: Colors.pink, size: 30),
                                      Flexible(
                                        child: ImageFrame(
                                          imagePath: data['after'] ?? '',
                                          screenWidth: screenWidth,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    data['name'] ?? '',
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.pinkAccent,
                                    ),
                                  ),

                                  ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxHeight: screenHeight * 0.15,
                                      maxWidth: screenWidth *
                                          0.8, // Batasi lebar agar sama rata
                                    ),
                                    child: SingleChildScrollView(
                                      child: Text(
                                        data['description'] ??
                                            'Tidak ada deskripsi.',
                                        maxLines: 20,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black87),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 15),
            ],
          );
        },
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(
      //           builder: (context) => const AddTestimonialScreen()),
      //     );
      //   },
      //   child: const Icon(Icons.add),
      // ),
    );
  }
}
