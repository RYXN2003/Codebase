import 'package:carousel_slider/carousel_slider.dart';
import 'package:codebase/Constants/colors.dart';
import 'package:codebase/Services/firebase_firesstore/firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class PostView extends StatefulWidget {
  // The data map for the post
  final Map<String,dynamic> postData;

  const PostView({super.key,  required this.postData,});

  @override
  State<PostView> createState() => _PostViewState();
}

class _PostViewState extends State<PostView> {
  // Comment section widget
  Widget ?commentSection;
  // List of the post comments
  List<Map<String,dynamic>> ?postComments;
  // Comment created by the currnet user
  final comment = TextEditingController();
  // Progres bool while loading comments
  bool loading = true;
  // Can the user delete a comment
  bool canDeleteComment = false;

  @override
  void initState() {
    gatherComments();
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      backgroundColor: mainGrey,
      title: Text(widget.postData['Title'],
      style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 20,
            ),),
      centerTitle: true,
    ),
    body: SafeArea(
      bottom: false,
      child: Container(
        color: mainGrey,
        child: Column(
          children: [
            // Images carousel
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: CarouselSlider.builder(
                itemBuilder: (context, index, realIndex) {
                  final image = widget.postData['MediaURL'][index];
                  return buildImage(image);
                },
                itemCount: widget.postData['MediaURL'].length,
                options: CarouselOptions(
                enableInfiniteScroll: false,
                enlargeCenterPage: true,
                viewportFraction: 1,
                height: MediaQuery.of(context).size.height / 2.5)),
            ),
            // Likes and comments bar
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: const Color.fromARGB(255, 237, 232, 232),
                ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Likes
                  Row(
                    children: [
                        IconButton(
                          onPressed:() async{
                            // Liked the post 
                           
                          },
                          icon: const Icon(
                            Icons.thumb_up_sharp,
                            color: mainGrey,
                          ) ,
                        ),
                      Text(
                        widget.postData['Likes'].toString(),
                        style: GoogleFonts.poppins(
                          color: mainGrey
                        )
                      )
                    ],
                  ),
                  // Comments
                  Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(right: 5),
                        child: Icon(
                          Icons.chat_bubble_outline,
                          color: mainGrey,
                        ),
                      ),
                      Text(
                        widget.postData['CommentCount'].toString(),
                        style: GoogleFonts.poppins(
                          color: mainGrey
                        )
                      )
                    ],
                  ),
                ],
              ),
            ),
            // Comment section
            loading ? const CircularProgressIndicator() : commentSection!,
            // Write a comment bar
             Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: TextField(
                    controller: comment,
                    style: GoogleFonts.poppins(
                        fontSize: 18,
                        color: Colors.white),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Write a comment',
                      hintStyle: GoogleFonts.poppins(
                                color: Colors.white),
                    ),
                  ),
                 ),
                 ElevatedButton(
                  onPressed: () async{
                    // Get the current datetime
                    DateTime dateTime = DateTime.now();
                    // Create a map for the comment
                    final commentToUpload = <String,dynamic> {
                      'Text': comment.text,
                      'Username': widget.postData['Username'],
                      'Timestamp': DateFormat.Hm().format(dateTime).toString(),
                      'Datestamp': DateFormat.yMd().format(dateTime).toString()
                    };
                    // Upload the comment to the post
                    await uploadComment(
                    comment: commentToUpload,
                    postTitle: widget.postData['Title'],
                    userID: widget.postData['UserID']);
                    // Reset the text field
                    comment.clear();
                  },
                  child: const Text('Post')),
                ],
              ),
          ],
        ),
      )),
     
  );
   // Get all post comments from firestore
    Future<void> gatherComments()async {
      if(widget.postData['CommentCount'] == 0){
        setState(() {
          commentSection = Expanded(child:Text('No comments yet',
          style: GoogleFonts.poppins(color: Colors.white),));
          loading = false;
        });
      }
      else{
        // Get the list of comment maps
        await getPostComments(postTitle: widget.postData['Title'], userID: widget.postData['UserID'])
        .then((value) {
          setState(() {
              postComments = value;
              commentSection = 
                Expanded(
                  child: ListView.builder(
                    itemCount: postComments!.length,
                    itemBuilder:(context, index) {
                    // Allowing the user the option to delete comment if they own it
                      if(postComments![index]['Username'] == userProfileData!['Username']){
                          canDeleteComment = true;
                      }
                      return Row(
                        children: [
                        // Username
                          Text('${widget.postData['Username']} :',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 12
                            ),
                          ),
                          // padding
                          const SizedBox(width: 10,),
                        // Comment text
                          Text(postComments![index]['Text'],
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 12
                            ),
                          ),
                          // padding
                          const SizedBox(width: 10,),
                        // Date text
                          Text(postComments![index]['Datestamp'],
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 12
                            ),
                          ),
                          // padding
                          const SizedBox(width: 10,),
                        // Time text
                          Text(postComments![index]['Timestamp'],
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 12
                            ),
                          ),
                        // Delete button
                          Visibility(
                            visible: canDeleteComment,
                            child: ElevatedButton(
                              onPressed: () async{
                                await deleteComment(
                                  comment: postComments![index]['Text'],
                                  timePosted: postComments![index]['Timestamp'],
                                  postTitle: widget.postData['Title'],
                                  userID: widget.postData['UserID']);
                              },
                              child: const Text('Delete')),
                          ),
                        ],
                      );
                    },
                  ),
                );
            loading = false;
          });
        });
      }
    }
    // Frame for each carousel image
  Widget buildImage (dynamic image)  {
      return ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Image.network(
          image,
          fit: BoxFit.cover,
          width: MediaQuery.of(context).size.width,
        ),
      );
  }
}