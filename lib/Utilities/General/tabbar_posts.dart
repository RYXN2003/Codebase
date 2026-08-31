import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../Views/post_view.dart';

class TabBarPosts extends StatefulWidget {
  const TabBarPosts({super.key});

  @override
  State<TabBarPosts> createState() => _TabBarPostsState();
}

class _TabBarPostsState extends State<TabBarPosts> {
  final currentUser = FirebaseAuth.instance.currentUser;

  List<Widget> userposts = [];

  bool shouldGatherPosts = true;

  @override
  Widget build(BuildContext context) {
    // Gets all the users posts from firebase and creates a grid element for each one
    return StreamBuilder(
                stream: FirebaseFirestore.instance.collection('Posts')
                .where('UserID', isEqualTo: currentUser!.email).snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
                  if (!snapshot.hasData){
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if(snapshot.hasData && shouldGatherPosts)
                  {
                    final posts = snapshot.data?.docs.toList();
                    for (var post in posts!){
                      final postWidget = createGridElement(post,context);
                      userposts.add(postWidget);
                    }
                    shouldGatherPosts = false;
                  }
                  return GridView(
                    gridDelegate: 
                    const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                    children: userposts,
                  );
                },
          );
  }

  // UI for each grid element
  Widget createGridElement(QueryDocumentSnapshot<Object?> postData, BuildContext context) {
    Map<String,dynamic> data = {
      'Username': postData['Username'],
      'UserID': postData['UserID'],
      'Title': postData['Title'],
      'ProfilePic': postData['ProfilePic'],
      'MediaURL': postData['MediaURL'],
      'Likes': postData['Likes'],
      'LikedBy': postData['LikedBy'],
      'CommentCount': postData['CommentCount']
    };
    return Padding(
          padding: const EdgeInsets.all(5),
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).
              push(MaterialPageRoute(builder: (context) => PostView(postData: data)));
            },
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(postData['MediaURL'].first),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(5)
              ),
            ),
          ),
        );
  }
}