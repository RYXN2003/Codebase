import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:codebase/Constants/colors.dart';
import 'package:codebase/Utilities/General/show_error_dialog.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:codebase/Services/firebase_firesstore/firestore.dart';

class CreatePostView extends StatefulWidget {
  const CreatePostView({super.key});

  @override
  State<CreatePostView> createState() => _CreatePostViewState();
}

class _CreatePostViewState extends State<CreatePostView> {

  int activeIndex = 0;
  UploadTask? uploadTask;
  final _titleTextController = TextEditingController();
  List<PlatformFile> imgList = [];
  // a list of download urls
  List<String> urls = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainGrey,
      appBar: AppBar(
          centerTitle: true,
          title: const Text('Create a post'),
          backgroundColor: mainGrey,
        ),
      body: 
      // Preview of the post the user is creating
      SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
          color: const Color(0xFF444444).withOpacity(0.4),
          borderRadius: BorderRadius.circular(50)),
          margin: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // profile pic and name
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child:
                  Row(
                     children: 
                     [
                      const Padding(
                        padding: EdgeInsets.only(left: 20, right: 10),
                        child: CircleAvatar(
                          radius: 25,
                          backgroundImage: NetworkImage('https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg?cs=srgb&dl=pexels-pixabay-220453.jpg&fm=jpg'),
                        ),
                      ),
                      Text(
                        'Sunset Studios',
                        style: GoogleFonts.poppins(
                          color: Colors.white),
                      )
                     ],
                    ),
              ),
              // image carousel
              carousel(),
                // Dot indicator
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: 
                    [
                      // Displays the dot indicator widget
                      dotIndicator()
                    ]
                 ),
              ),
              // Post title
              Padding(
                padding: const EdgeInsets.only(bottom: 10, left: 20),
                child: Row(
                  children: 
                    [
                      const Padding(
                        padding: EdgeInsets.only(right: 5),
                        child: Icon (
                          Icons.edit,
                          color: Colors.white,
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _titleTextController,
                          style: GoogleFonts.poppins(
                              color: Colors.white,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Choose a title',
                            hintStyle: GoogleFonts.poppins(
                                      color: Colors.white)
                          ),
                        ),
                      ),
                    ]
                ),
              ),
              // Upload media button
              SizedBox(
                width: 150,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainGrey,
                    shadowColor:Colors.white
                  ),
                  onPressed: () async{
                    // Allow the user to pick photos/videos
                    final file = await FilePicker.platform.pickFiles();
                    // check if they have selected anything
                    if (file == null) return;
                    // If they have selected something
                    setState(() {
                      imgList.addAll(file.files);
                    });
                  },
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text('Upload file'),
                        Icon(Icons.photo_camera)
                      ],
                  )
                        ),
              ),
              // Post button
              SizedBox(
                width: 150,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shadowColor:Colors.white
                  ),
                  onPressed: () async{
                    // The user hasn't added any cards to the post
                    if (imgList.isEmpty){
                      await showErrorDialog(context, 'Please add either text or media to the post');
                    }
                    else{
                      for (var i in imgList)
                      {
                        // Define the firebase storage path
                        final path = 'Users/Post-Media/${i.name}';
                        // Convert the path to a file format
                        final file = File(i.path.toString());
                        // Create a storage reference
                        final ref = FirebaseStorage.instance.ref().child(path);
                        // Upload the file to cloud
                        setState(() {
                          uploadTask = ref.putFile(file);
                        });
                        // wait until the upload is complete
                        final snapshot = await uploadTask!.whenComplete(() => {});
                        // Reset the upload task 
                        setState(() {
                          uploadTask = null;
                        });
                        // Get the download link of the file
                        final urlDownload = await snapshot.ref.getDownloadURL();
                        // Adding the download url to a list
                        urls.add(urlDownload);
                      }
                      // Upload the post data to firestore
                      uploadPost(urls, _titleTextController.text);
                    }
                  },
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text('Post'),
                        Icon(Icons.post_add)
                      ],
                  )
                        ),
              ),
              // Upload progress bar
              uploadProgress(),
            ],
          ),
        ),
      ),
    );
  }

// The templete for the carousel items
  buildImage (PlatformFile image, int index,) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: Image.file(
        File(image.path.toString()),
        fit: BoxFit.cover,
      ),
    );
  }

  // Creates a dot indicator linked to the images
  Widget dotIndicator() {
    // If the user hasnt selected an image yet
    if (imgList.isEmpty)
    {
      return const Text('Upload a photo/video to begin', style: TextStyle(color: Colors.white),);
    }
    return AnimatedSmoothIndicator(
      activeIndex: activeIndex,
      count: imgList.length,
      effect: const SwapEffect(
        dotHeight: 7,
        dotWidth: 7,
        activeDotColor: Colors.white 
      ),
    );
  }
  
  // Creates a progress indicator for the image uploads
  Widget uploadProgress() =>
    StreamBuilder<TaskSnapshot> (
      stream: uploadTask?.snapshotEvents,
      builder: (context, snapshot) 
      {
        if (snapshot.hasData){
          final data = snapshot.data!;
          // How much of the file has currently been uploaded
          double progress = data.bytesTransferred / data.totalBytes;

            return SizedBox(
              height: 50,
              child: Stack(
                fit: StackFit.expand,
                children: 
                [
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white,
                    color: mainPurple,
                  ),
                  Center(
                    child: Text('${(100 * progress).roundToDouble()}%'),
                  )
                ],
              ),
          );
        }
        else{
          return const SizedBox(height: 50,);
        }
      },);

  // Image slider widget 
  Widget carousel(){
    return Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: CarouselSlider.builder(
                options: CarouselOptions(
                  height: 300,
                  enableInfiniteScroll: false,
                  enlargeCenterPage: true,
                  viewportFraction: 0.9,
                  onPageChanged: (index, reason) => setState(() => activeIndex = index)
                ),
                itemCount: imgList.length,
                itemBuilder: (context, index, realIndex) {
                  final image = imgList[index];
                    return buildImage(image, index);
                  },),
                );
  }
  
}

