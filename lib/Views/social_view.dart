import 'dart:ui';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codebase/Constants/colors.dart';
import 'package:codebase/Constants/routes.dart';
import 'package:codebase/Views/post_view.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../Services/firebase_firesstore/firestore.dart';


class SocialView extends StatefulWidget {
  const SocialView({super.key});

  @override
  State<SocialView> createState() => _SocialViewState();
}

class _SocialViewState extends State<SocialView> {

  int activeIndex = -1;
  List<Map<String,dynamic>> userPosts = [];
  bool shouldGatherPosts = true;

  @override
  Widget build(BuildContext context) {
    // Should the filter posts bar be disblayed
    return Scaffold(
      backgroundColor: mainGrey,
      body: SafeArea(
          // Removes the bottom safe area
          bottom: false,
          child: Container(
            color: mainGrey,
            child:Column(
              // Container for the entire page widgets
              mainAxisSize: MainAxisSize.min,
              children: 
              [
                Container(
                  color: mainGrey,
                  child:
                    // Logo 
                    Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Holds the row elements
                        Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: Center(
                            child: IconButton(
                              onPressed: () {
                                
                              },
                              icon: const Icon(Icons.dark_mode),
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(
                        // The App logo
                        height: 60,
                        width: 150,
                        child: Center(
                          child: Text('CodeBase',
                              style: GoogleFonts.rubik(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.w700,),
                           ),
                         ),
                       ), 
                        // Create post button
                        Center(
                          child: IconButton(
                          
                            onPressed:() {
                              Navigator.of(context).pushNamed(createPostRoute);
                            }, 
                            icon: const Icon(Icons.add_box_rounded),
                            color: Colors.white,
                          ),
                        ) 
                      ],
                    ),
                ),
                // My feed and filter row   
                  Container(
                      color: mainGrey,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'My Feed',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w400
                              )
                              ),
                            ElevatedButton(
                              onPressed: (){},
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)
                                )
                              ),
                              
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Filter',
                                      style: 
                                      GoogleFonts.poppins(
                                        color: Colors.black,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600
                                      ),
                                    ),
                                    const Icon(
                                      Icons.youtube_searched_for,
                                      size: 20,
                                      color: Colors.black,
                                    ),
                                  ],
                                )
                              )
                            
                          ],
                        ),
                      ),
                    ),
                // User post
                  getUserPosts(),
            ],
                ), 
            )
          ),
       );

  }
  // Frame for each carousel image
  Widget buildImage (dynamic image)  {
       return Image.network(
          image,
          fit: BoxFit.cover,
          width: MediaQuery.of(context).size.width,
        );
    
  }
  // Creates an image carousel for each post
  Widget carousel(List<dynamic>? images){
  List<dynamic>? imgList;
  // Check if the post has any images
  if (images == null){
    imgList = [];
  }
  else{
    imgList = images;
  }
 
  return CarouselSlider.builder(
    options: CarouselOptions(
      height: MediaQuery.of(context).size.height / 2.5,
      enableInfiniteScroll: false,
      enlargeCenterPage: true,
      viewportFraction: 1,
    ),
    itemCount: imgList.length,
    itemBuilder: (context, index, realIndex) {
      final image = imgList![index];
      return buildImage(image);
    });
       
}
  // Gets the data from the post doc
  Map<String, dynamic> getPostData(QueryDocumentSnapshot<Object?> post) { 
    // Creating a new map with all the post data
    final Map<String,dynamic> postData = {
      'Title': post['Title'],
      'MediaURL': post['MediaURL'],
      'Likes': post['Likes'],
      'CommentCount': post['CommentCount'],
      'UserID': post['UserID'],
      'Username': post['Username'],
      'ProfilePic': post['ProfilePic'],
    };
    return postData;
  }
  // Gets a list of all posts
  getUserPosts() {
    if(userPosts.isEmpty){
      return StreamBuilder(
                stream: FirebaseFirestore.instance.collection('Posts').snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
                  if (!snapshot.hasData){
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if(snapshot.hasData && shouldGatherPosts)
                  {
                    final posts = snapshot.data?.docs.toList();
                    for(var post in posts!){
                      // Seperate the data into fucntion parameters
                      final Map<String,dynamic> postData = getPostData(post);
                      // Add it to the list of posts
                      userPosts.insert(0,postData);
                      // Stop from recuring
                      shouldGatherPosts = false;
                    }
                  }
                  return Expanded(
                    child: ListView.builder(
                      itemCount: userPosts.length,
                      itemBuilder: (context, index) {
                        bool hasLiked = false;
                        // Getting the post data by the index
                        final post = userPosts[index];
                        // Check if usr has already liked this post
                        checkIfLiked(postTitle: post['Title'],userID: post['UserID']).then((value) => hasLiked = value);
                        // creating the post widget
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: secondaryGrey,
                          ),
                          
                          margin: const EdgeInsets.symmetric(horizontal: 3,vertical: 10),
                          child: Column(
                            children: [
                              // Username & icons tabbar 
                                Padding(
                                  padding: const EdgeInsets.all(15),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [ 
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 25,
                                              backgroundImage: NetworkImage(post['ProfilePic']),
                                            ),
                                            const SizedBox(width: 15),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  post['Username'],
                                                  style: GoogleFonts.poppins(
                                                    color: Colors.white,
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold
                                                  ),
                                                ),
                                                Text(
                                                  // TODO make this work
                                                'Game development',
                                                style: GoogleFonts.poppins(
                                                  color: Colors.white,
                                                  fontSize: 15
                                                ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const Icon(
                                          Icons.more_horiz,
                                          color: Colors.white,
                                          size: 30,
                                        )
                                  ]
                                  ),
                                ),
                              // Image carousel 
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).
                                    push(MaterialPageRoute(builder: (context) => PostView(postData: post)));
                                  },
                                  child: carousel(post['MediaURL'])),
                              // Likes and comment bar
                                Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 20),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                    // Post title
                                      Text(post['Title'],
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 18
                                        ),
                                      ),
                                    // Likes & comments
                                      Row(
                                        children: [
                                          IconButton(
                                            onPressed:() async{
                                              // Liked the post 
                                              if(!hasLiked){
                                                likePost(postTitle: post['Title'],userID: post['UserID'])
                                                .then((value) => hasLiked = value);
                                              }
                                              else if(hasLiked){
                                                unlikePost(postTitle: post['Title'],userID: post['UserID'])
                                                .then((value) => hasLiked = false);
                                              }
                                            },
                                            icon: Icon(
                                              Icons.thumb_up_sharp,
                                              color: hasLiked ? Colors.blue :Colors.white,
                                            ) ,
                                          ),
                                          Text(
                                            post['Likes'].toString(),
                                            style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold
                                            )
                                          ),
                                          IconButton(
                                            onPressed:() async{
                                          
                                            },
                                            icon: Icon(
                                              Icons.chat_bubble_outline,
                                              color: hasLiked ? Colors.blue :Colors.white,
                                            ) ,
                                          ),
                                          Text(
                                            post['CommentCount'].toString(),
                                            style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold
                                            )
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
          );
    }
    return const SizedBox();
  }
}
