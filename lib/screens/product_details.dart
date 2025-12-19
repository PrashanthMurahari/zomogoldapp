import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../DAO/product_dao.dart';
import '../models/product_model.dart';
const Color primaryPurple = Color(0xFF7F55B5);

class ProductDetailsPage extends StatefulWidget {
  const ProductDetailsPage({super.key});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  final List<dynamic> _extraImages = [];
  dynamic _selectedImage;

  final PageController _pageController = PageController();

  Timer? _autoSlideTimer;
  int _currentPage = 0;

  final List<String> _metalOptions = ['Platinum', 'Gold', 'Silver', 'Copper'];
  String? _selectedMetal = 'Platinum';

  static const int maxImages = 5;

  void _startAutoSlide() {
    _autoSlideTimer?.cancel();

    if (_extraImages.length <= 1) return;

    _autoSlideTimer = Timer.periodic(
      const Duration(seconds: 2),
          (timer) {
        if (!_pageController.hasClients) return;

        _currentPage++;

        if (_currentPage >= _extraImages.length) {
          _currentPage = 0;
        }

        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      },
    );
  }

  Future<void> _pickNewImage() async {
    if (_extraImages.length >= maxImages) return;

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    dynamic data;
    if (kIsWeb) {
      data = await pickedFile.readAsBytes();
    } else {
      data = File(pickedFile.path);
    }

    setState(() {
      _extraImages.add(data);
      _selectedImage ??= data;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pageController.hasClients) {
        _currentPage = _extraImages.length - 1;
        _pageController.jumpToPage(_currentPage);
      }
    });

    _startAutoSlide(); // 🔥 START AUTO SLIDE
  }

  Widget _displayImage(dynamic img) {
    if (img is Uint8List) {
      return Image.memory(img, fit: BoxFit.cover);
    }
    if (img is File) {
      return Image.file(img, fit: BoxFit.cover);
    }
    return Container(color: Colors.grey.shade200);
  }

  Widget _buildSmallCard(dynamic image, int index) {
    final bool isPlaceholder = image == null;

    return Container(
      key: ValueKey("img_$index"),
      margin: const EdgeInsets.only(right: 8),
      width: 80,
      height: 80,
      child: InkWell(
        onTap: () {
          if (isPlaceholder) {
            _pickNewImage();
          } else {
            _currentPage = index;
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
            setState(() => _selectedImage = image);
          }
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: (!isPlaceholder && _selectedImage == image)
                  ? primaryPurple
                  : Colors.grey.shade400,
              width: (!isPlaceholder && _selectedImage == image) ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: isPlaceholder
              ? const Center(
            child: Icon(
              Icons.add_photo_alternate_outlined,
              size: 30,
              color: Colors.grey,
            ),
          )
              : ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _displayImage(image),
          ),
        ),
      ),
    );
  }
  Future<List<String>> _uploadImages(String productId) async {
    List<String> downloadUrls = [];

    for (int i = 0; i < _extraImages.length; i++) {
      try {
        final ref = FirebaseStorage.instance
            .ref("products/$productId/image_$i.jpg");

        UploadTask uploadTask;

        if (kIsWeb) {
          uploadTask = ref.putData(_extraImages[i]);
        } else {
          uploadTask = ref.putFile(_extraImages[i]);
        }

        final snapshot = await uploadTask;
        final url = await snapshot.ref.getDownloadURL();

        debugPrint("✅ IMAGE UPLOADED: $url");
        downloadUrls.add(url);
      } catch (e, s) {
        debugPrint("❌ STORAGE ERROR: $e");
        debugPrint("$s");
      }
    }

    return downloadUrls;
  }



  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Product Details",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 260,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(10),
              ),
              child: _extraImages.isEmpty
                  ? const Center(
                child: Text(
                  "Upload images using boxes below",
                  style: TextStyle(color: Colors.black54),
                ),
              )
                  : ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _extraImages.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                      _selectedImage = _extraImages[index];
                    });
                  },
                  itemBuilder: (context, index) {
                    return _displayImage(_extraImages[index]);
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),
            SizedBox(
              height: 85,
              child: ReorderableListView(
                scrollDirection: Axis.horizontal,
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) newIndex -= 1;

                    final img = _extraImages.removeAt(oldIndex);
                    _extraImages.insert(newIndex, img);

                    _currentPage = newIndex;
                    _selectedImage = _extraImages[newIndex];
                  });

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_pageController.hasClients) {
                      _pageController.jumpToPage(newIndex);
                    }
                  });

                  _startAutoSlide();
                },
                children: [
                  ..._extraImages.asMap().entries.map(
                        (entry) =>
                        _buildSmallCard(entry.value, entry.key),
                  ),
                  if (_extraImages.length < maxImages)
                    for (int i = 0;
                    i < maxImages - _extraImages.length;
                    i++)
                      _buildSmallCard(
                        null,
                        _extraImages.length + i,
                      ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Metal Name",
                  style:
                  TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border:
                    Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedMetal,
                      items: _metalOptions
                          .map(
                            (e) => DropdownMenuItem(
                          value: e,
                          child: Text(e),
                        ),
                      )
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _selectedMetal = v),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () async {
            try {
              debugPrint("➡️ SAVE STARTED");

              final productDao = ProductDao();

              final productId =
              (await productDao.generateNextProductId()).toString();

              debugPrint("🆔 PRODUCT ID: $productId");

              final imageUrls = await _uploadImages(productId);

              debugPrint("🖼 IMAGE URLS: $imageUrls");

              final product = ProductModel(
                productId: productId,
                categoryId: "",
                userId: "",
                images: imageUrls,
                metalName: _selectedMetal ?? "",
                weight: 0.0,
                purity: 0.0,
                makingCharges: 0.0,
                discount: 0.0,
                tagId: "",
                productInformation: "",
                specifications: "",
                hallmark: false,
                customizable: false,
                createdTimestamp: DateTime.now(),
                modifiedTimestamp: DateTime.now(),
              );

              debugPrint("📦 PRODUCT JSON: ${product.toJson()}");

              await productDao.addProduct(product);

              debugPrint("✅ PRODUCT SAVED");

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Product saved successfully")),
              );
            } catch (e, s) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Save failed: $e")),
              );
            }
          },

          style: ElevatedButton.styleFrom(
            backgroundColor: primaryPurple,
            padding:
            const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            "Save",
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
