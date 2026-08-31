import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codebase/Utilities/General/message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
  // User has profile?
  bool userhasProfile = false;
  // Current user Auth credentials
  final currentUser = FirebaseAuth.instance.currentUser;
  // Post data to upload
  Map<String, dynamic> postToUpload = {};
  // Database reference
  var postCollection = FirebaseFirestore.instance.collection('Posts');
  // User profile data map
  Map<String, dynamic> ?userProfileData;

// Uploads a user created post to firestore
  void uploadPost(List<String>? mediaURLS, String postTitle) async{
    // Create a map to upload
     postToUpload = {
        'Username': userProfileData!['Username'],
        'ProfilePic': userProfileData!['ProfilePic'],
        'UserID': currentUser!.email,
        'MediaURL': mediaURLS,
        'Title': postTitle,
        'Likes': 0,
        'LikedBy': [],
        'CommentCount': 0,
     };
    // Upload the map to the post collection
    await postCollection.add(postToUpload);
    // Old total posts value
    final ref = await FirebaseFirestore.instance.collection('Users').doc(currentUser!.email).get();
    // New value 
    final totalPosts = ref['TotalPosts'] + 1;
    // Increase the users total post value by 1
    await FirebaseFirestore.instance.collection('Users').doc(currentUser!.email)
    .update({
      'TotalPosts': totalPosts    });
    
  }
// Search for their profile doc
  Future<bool> checkForProfile() async{
  final doc = await FirebaseFirestore.instance.collection('Users').doc(currentUser!.email).get();
  final result = doc.exists;
  return result;
}
// Upload new user doc
  uploadNewUser({required String username, required String field,
 String ?profilePic}) async{
  // Create a new storage ref for the profile
  await FirebaseFirestore.instance.collection('Users')
  .doc(currentUser!.email.toString())
  .set({
    'Username': username,
    'Field': field,
    'ProfilePic': profilePic,
    'TotalLikes': 0,
    'TotalPosts': 0,
    'Fans': 0,
  });
}
// Get and save user profile doc data
  getUserProfileData() async {
  // Get the doc reference 
  final profileData = await FirebaseFirestore.instance.collection('Users').doc(currentUser!.email.toString())
  .get();
  // Store in local profile map
  userProfileData = {
    'Username': profileData['Username'],
    'ProfilePic': profileData['ProfilePic'],
    'Field': profileData['Field'],
    'TotalLikes': profileData['TotalLikes'],
    'TotalPosts': profileData['TotalPosts'],
    'Fans': profileData['Fans'],
  };
}
// Gets the profile pic from a given user
  Future<String> getUserProfilePic({required String userID}) async{
  // Get a ref to the doc of the user 
  final ref = await FirebaseFirestore.instance.collection('Users')
  .doc(userID).get();
  // Get there profile picture
  final pic = ref['ProfilePic'];
  // return the picture
  return pic;
}
// Checks if the current user has liked each post
  Future<bool> checkIfLiked({required String postTitle, required String userID}) async{
    // has liked the post
    bool hasLiked = false;
    // Get all posts by the relevent user 
    final userPosts = FirebaseFirestore.instance.collection('Posts')
    .where('UserID', isEqualTo: userID);
    // Get the doc of the relevent post from firestore
    final doc = await userPosts.where('Title', isEqualTo: postTitle).get();
    final post = doc.docs.first;
    // Check if the user has liked the post
    for (var i in post['LikedBy']){
      // User is in the liked list
      if (i == userID){
        hasLiked = true;
      }
    }
    return hasLiked;
  }
// Hanldes liking a post
  Future<bool> likePost({required String postTitle, required String userID}) async{
    // Get all posts by the relevent user 
    final userPosts = await FirebaseFirestore.instance.collection('Posts')
    .where('UserID', isEqualTo: userID)
    .where('Title', isEqualTo: postTitle)
    .get();
    // Get the list of users that have liked the post
    List<dynamic> usersLiked = await userPosts.docs.first['LikedBy'];
    // Gets the total likes of the post
    int likes = await userPosts.docs.first['Likes'];
    // Add the current user to this list
    usersLiked.add(userID);
    // Get the id of the doc 
    final docID = userPosts.docs.single.id;
    // Update the LikedBy field
    await FirebaseFirestore.instance.collection('Posts').doc(docID).update({
      'LikedBy': usersLiked,
      'Likes': likes + 1,
    });
    // Old total likes value
    final ref = await FirebaseFirestore.instance.collection('Users').doc(currentUser!.email).get();
    // New value 
    final totalLikes = ref['TotalLikes'] + 1;
    // Increase the users total post value by 1
    await FirebaseFirestore.instance.collection('Users').doc(currentUser!.email)
    .update({
      'TotalLikes': totalLikes
    });
    return true;
  }
// Handles un-liking a post
  Future<bool> unlikePost({required String postTitle, required String userID}) async{
    // Get all posts by the relevent user 
    final userPosts = await FirebaseFirestore.instance.collection('Posts')
    .where('UserID', isEqualTo: userID)
    .where('Title', isEqualTo: postTitle)
    .get();
    // Get the list of users that have liked the post
    List<dynamic> usersLiked = await userPosts.docs.first['LikedBy'];
    // Remove the current user to this list
    usersLiked.remove(userID);
    // Gets the total likes of the post
    int likes = await userPosts.docs.first['Likes'];
    // Get the id of the doc 
    final docID = userPosts.docs.single.id;
    // Update the LikedBy field
    await FirebaseFirestore.instance.collection('Posts').doc(docID).update({
      'LikedBy': usersLiked,
      'Likes': likes - 1,
    });
    // Old total likes value
    final ref = await FirebaseFirestore.instance.collection('Users').doc(currentUser!.email).get();
    // New value 
    final totalLikes = ref['TotalLikes'] - 1;
    // Increase the users total post value by 1
    await FirebaseFirestore.instance.collection('Users').doc(currentUser!.email)
    .update({
      'TotalLikes': totalLikes
    });
    return true;
  }
// Upload comment to post
 Future<void> uploadComment({required Map<String,dynamic> comment,required String postTitle, required String userID }) async{
  // Get the doc of the relevent post 
    final userPosts = await FirebaseFirestore.instance.collection('Posts')
    .where('UserID', isEqualTo: userID)
    .where('Title', isEqualTo: postTitle)
    .get();
  // Get the id of the doc 
    final docID = userPosts.docs.single.id;
  // Push to firestore
    await FirebaseFirestore.instance.collection('Posts').doc(docID)
    .collection('Comments').add(comment);
  // Increment the total comments by one
    await FirebaseFirestore.instance.collection('Posts').doc(docID)
    .update({
      'CommentCount': FieldValue.increment(1)
    });
 }
// Get all comments by post
 Future<List<Map<String,dynamic>>> getPostComments({required String postTitle, required String userID }) async{
  List<Map<String,dynamic>> comments = [];
  // Get the doc of the relevent post 
    final userPosts = await FirebaseFirestore.instance.collection('Posts')
    .where('UserID', isEqualTo: userID)
    .where('Title', isEqualTo: postTitle)
    .get();
  // Get the id of the doc 
    final docID = userPosts.docs.single.id;
  // post reference
  final ref = await FirebaseFirestore.instance.collection('Posts').doc(docID).collection('Comments').get();
  // Add each comment doc to list
  for (var element in ref.docs) {
    comments.add(element.data());
  }
  return comments;
 }
 // Delete a given comment
 Future<void> deleteComment({required String comment,required String timePosted,required String postTitle, required String userID })async{
    // Get the post doc
    final postRef = await FirebaseFirestore.instance.collection('Posts')
    .where('UserID', isEqualTo: userID)
    .where('Title', isEqualTo: postTitle)
    .get();
    // Get the id of the doc 
    final docID = postRef.docs.single.id;
    // Decrement the comment count by 1
    await FirebaseFirestore.instance.collection('Posts').doc(docID)
    .update({
      'CommentCount': FieldValue.increment(-1)
    });
    // Get the comment 
    final commentRef = await FirebaseFirestore.instance.collection('Posts').doc(docID).collection('Comments')
    .where('Text', isEqualTo: comment,)
    .where('Timestamp', isEqualTo: timePosted)
    .get();
    // Get the comment ID 
    final commentID = commentRef.docs.first.id;
    // Delete the comment
    await FirebaseFirestore.instance.collection('Posts').doc(docID)
    .collection('Comments').doc(commentID).delete();
 }
// Get a list of maps with user data
Future<List<Map<String,dynamic>>> gatherUserResults() async{
  // Init list of user data
    List<Map<String,dynamic>> userResults = [];
  // Get all user documents from firestore
    final users = await FirebaseFirestore.instance.collection('Users').get();
  // Populate the user results list with the user data maps
    for (var element in users.docs) {
      if(element['Username'] != userProfileData!['Username']){
         userResults.add(element.data());
      }
    }    
    return userResults;
}
// Search if a conversation exsits 
Future<Map<String,dynamic>> searchForPreviousConvo(String reciever) async{
  Map<String,dynamic> chatList = {};
  List<String> userList = [userProfileData!['Username'], reciever];
  // Sort the user list
  userList.sort((user1,user2) => user1.compareTo(user2));
  // Search for a conversation with current user 
  var chat = await FirebaseFirestore.instance.collection('Conversations')
  .where('Users', isEqualTo: userList)
  .get();
  // Assign the result to the map
  if(chat.docs.isNotEmpty){
    chatList = chat.docs.first.data();
  }
  // return the map
  return chatList;
}
// Get all messages from conversation 
Future<List<Message>> getAllMessagesFromConvo({required List<dynamic> users}) async{
  // init a list of messages
  List<Message> messages = [];
  // Sort the user list
  users.sort((user1,user2) => user1.compareTo(user2));
  // Find the conversation doc in firestore
  final ref = await FirebaseFirestore.instance.collection('Conversations')
  .where('Users', isEqualTo: users).get();
  // get the id of the doc
  final docID = ref.docs.first.id;
  // get the doc ref of the message collection
  final messageDocs = await FirebaseFirestore.instance.collection('Conversations').doc(docID)
  .collection('Messages')
  .get();
  // Extract all messages into a list
  for (var message in messageDocs.docs) {
    messages.add(Message(
      date: DateTime(message['Year'],message['Month'],message['Day']),
      time: message['Time'],
      text: message['Text'],
      isSentByMe: message['Username'] == userProfileData!['Username'],
      seenBy: message['SeenBy']
    ));
  }
  return messages;
}
// Upload message to convo
Future<void> uploadNewMessage({required List<dynamic> users, required Message messageToUpload})async {
  // Change the format of the message to a map
  Map<String,dynamic> message = {
    'Text': messageToUpload.text,
    'Username': userProfileData!['Username'],
    'Day': DateTime.now().day,
    'Month': DateTime.now().month,
    'Year': DateTime.now().year,
    'Time': '${TimeOfDay.now().hour}:${TimeOfDay.now().minute}',
    'SeenBy': messageToUpload.seenBy
  };
  // Sort the user list
  users.sort((user1,user2) => user1.compareTo(user2));
  // Find the conversation doc in firestore
  final ref = await FirebaseFirestore.instance.collection('Conversations')
  .where('Users', isEqualTo: users).get();
  // get the id of the doc
  final docID = ref.docs.first.id;
  // get the doc ref of the message collection
  await FirebaseFirestore.instance.collection('Conversations').doc(docID)
  .collection('Messages')
  .add(message);
}
// Create a conversation between users
Future<void> createConversation({required List<dynamic> users}) async {
  // Sort the user list
  users.sort((user1,user2) => user1.compareTo(user2));

  await FirebaseFirestore.instance.collection('Conversations')
  .add({
    'Users': users
  });
}
// Get a list of conversations from firebase
 Future<List<Map<String,dynamic>>> getConversations() async{
  // Init the list
    List<Map<String,dynamic>> convoData = [];
  // Get all conversations by user
  var ref = await FirebaseFirestore.instance.collection('Conversations')
  .where('Users', arrayContains: userProfileData!['Username']).get();
  // Loop through the docs 
   for (var element in ref.docs) {
      String reciever = '';
      for(var i in element['Users']){
      // Loop through all conversation docs and save the recievers username
        if(i != userProfileData!['Username']){
          reciever = i;
        }
      }
      // Get the profile data of the user
        final ref = await FirebaseFirestore.instance.collection('Users')
        .where('Username', isEqualTo: reciever).get();
        final user = ref.docs.first.data();
      // Add the profile data map to the list of convo maps
        convoData.add(user);
   }
    return convoData;
 }
// Set all messages in a convo to read
Future<void> setMessagesAsRead({required List<dynamic> users})async{
  // Sort the user list
  users.sort((user1,user2) => user1.compareTo(user2));
  // Find the conversation doc in firestore
  final ref = await FirebaseFirestore.instance.collection('Conversations')
  .where('Users', isEqualTo: users).get();
  // get the id of the doc
  final docID = ref.docs.first.id;
  // get the doc ref of the message collection
  final messageDocs = await FirebaseFirestore.instance.collection('Conversations').doc(docID)
  .collection('Messages')
  .get();
  // Loop through all messages and the current user to the SeenBy field
    for (var message in messageDocs.docs){
      // Get the ID od the message
      final messageID = message.id;
      // Update the field
      await FirebaseFirestore.instance.collection('Conversations')
      .doc(docID).collection('Messages').doc(messageID).update({
        'SeenBy': FieldValue.arrayUnion([userProfileData!['Username']])
      });
    }
}
// Get the count of unread messages for each convo
Future<List<int>> getUnreadMessageCount() async{
  // Count of unread messages on each post
  List<int> unreadCount = [];
  // Get all conversations by user
  var convos = await FirebaseFirestore.instance.collection('Conversations')
  .where('Users', arrayContains: userProfileData!['Username']).get();
  // Loop through convos
  for (var convo in convos.docs){
    // Get all messages in the convo ref
    final messages = await FirebaseFirestore.instance.collection('Conversations').doc(convo.id)
    .collection('Messages').get();
    // Get all messages in the convo ref
    final messagesNotSeen = await FirebaseFirestore.instance.collection('Conversations').doc(convo.id)
    .collection('Messages').where('SeenBy', arrayContains: userProfileData!['Username'])
    .get();
    // Number of unread messages
    final unreadMessages = messages.docs.length - messagesNotSeen.docs.length;
    // Add the count to list
    unreadCount.add(unreadMessages);
    print(unreadMessages);
  }
  return unreadCount;
}
