// ignore_for_file: use_build_context_synchronously

import 'package:codebase/Constants/colors.dart';
import 'package:codebase/Views/chat_view.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../Services/firebase_firesstore/firestore.dart';

class ConversationsView extends StatefulWidget {
  const ConversationsView({super.key});
  @override
  State<ConversationsView> createState() => _ConversationsViewState();
}

class _ConversationsViewState extends State<ConversationsView> {
  // List of all the conversation widgets
  Widget ?conversatonsList;
  // List of user results from search bar
  List<Map<String,dynamic>> userResults = [];
  // List of conversation data maps for all user convos
  List<Map<String,dynamic>> userConversations = [];
  // Loading bool use to trigger a change in widgets
  bool conversationsLoading = true;
  // If the user clicks new convo button
  bool createNewConvo = false;

  @override
  void initState() {
    handleConversations();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainGrey,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: <Widget> [ 
          // Main page
            Column(
            children: [
              // Padding
                const SizedBox(height: 10,),
              // Page header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        // Padding
                        const SizedBox(width: 20,),
                        // My inbox text
                        Text(
                          'My Inbox',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w400
                          )
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed:() async{
                            await gatherUserResults().then((value) => userResults = value);
                            setState(() {
                              createNewConvo = true;
                            });
                          }, 
                          icon: const Icon(Icons.add_box_rounded),
                          color: Colors.white,
                        ),
                      ],
                    )
                  ],
                ),
              // Padding
              const SizedBox(height: 10,),
              // Chat search
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: TextField(
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 15
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: secondaryGrey,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none
                          ),
                          hintText: 'Search by username',
                          hintStyle: GoogleFonts.poppins(
                            color: Colors.white
                          ),
                          prefixIcon: const Icon(Icons.search),
                          prefixIconColor: Colors.white
                        ),
                      ),
                    )
                  ],
                ),
              // Padding
                const SizedBox(height: 20,),
              // Conversations
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30)
                    ),
                    color: secondaryGrey
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: conversationsLoading ? 
                    Row(children: const [CircularProgressIndicator()]) : conversatonsList!,
                  )
                ),
              ),
              ],
            ),
          // Create new convo widget
            Visibility(
              visible: createNewConvo,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: mainGrey
                ),
                margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.1,
                vertical: MediaQuery.of(context).size.height * 0.15),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [ 
                    // Padding
                      const SizedBox(height: 10,),
                    // Title 
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          const SizedBox(width: 10,),
                          Text('Start a new chat',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 20
                          ),),
                          // Padding
                          Expanded(child: Container()),
                          IconButton(
                            onPressed: (){
                              setState(() {
                                createNewConvo = false;
                              });
                            },
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white,
                            )
                          )
                        ],
                      ),
                    // Search bar to find a user
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                style: GoogleFonts.poppins(
                                  color: Colors.black,
                                  fontSize: 15
                                ),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: BorderSide.none
                                  ),
                                  hintText: 'Search by username',
                                  prefixIcon: const Icon(Icons.search),
                                  prefixIconColor: Colors.black
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    // List of results
                      Expanded(
                        child: ListView.builder(
                          itemCount: userResults.length < 15 ? userResults.length : 15,
                          itemBuilder:(context, index) {
                            return Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  child: Row(
                                    children: [
                                      // Profile picture
                                      CircleAvatar(
                                        backgroundImage: NetworkImage(userResults[index]['ProfilePic']),
                                        radius: 25,
                                      ),
                                      // Padding
                                      const SizedBox(width: 10,),
                                      // Username
                                      Text(userResults[index]['Username'],
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 18,
                                      ),),
                                      // Padding
                                      Expanded(child: Container()),
                                      // Message button
                                      ElevatedButton(
                                        onPressed: (){
                                          Navigator.of(context).
                                          push(MaterialPageRoute(builder: (context) => ChatView(recieverData: userResults[index])));
                                        },
                                        child: const Icon(Icons.chat_bubble)
                                      )
                                    ],
                                  ),
                                )
                              ],
                            );
                        },))
                  ],
                ),
              ),
            )
         ]
        ),
      ),
    );
  }
  
  Future<void> handleConversations() async{
     List<int> unreadCount = [];
    // Check for unread messages on all convos
      await getUnreadMessageCount().then((value) {
        unreadCount = value;
      });
    // Get the time of last message on every convo

    // Gets a list of convo data
    await getConversations().then((value){
      setState(() {
        userConversations = value;
      });
    });
   
    if (userConversations.isNotEmpty) {
      conversatonsList = 
         ListView.builder(
          itemCount: userConversations.length,
          itemBuilder:(context, index) {
            return GestureDetector(
              onTap: () async{
                // Set all messages in the convo to read by the current user
                await setMessagesAsRead(users: [userConversations[index]['Username'], userProfileData!['Username']]); 
                Navigator.of(context).
                pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => 
                  ChatView(recieverData: userConversations[index])), (route) => false);
              },
                child: Container(
                  color: secondaryGrey,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    child: Row(
                      children: [
                        // Profile picture
                        CircleAvatar(
                          backgroundImage: NetworkImage(userConversations[index]['ProfilePic']),
                          radius: 35,
                        ),
                        // Padding
                        const SizedBox(width: 15,),
                       // Username and new message count
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(userConversations[index]['Username'],
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold
                            ),),
                            Text('${unreadCount[index].toString()} New Messages',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 15
                            ),),
                          ],
                        ),
                        // Padding
                        Expanded(child: Container()),
                        // Time and notification icon
                        Column(
                          children: [
                            unreadCount[index] > 0 ? const Icon(
                              Icons.circle,
                              size: 15,
                              color: Colors.blue,
                            )
                            : const Text('')
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              );
            
          },
         );
      
      conversationsLoading = false;
    }
    else{
      conversatonsList = Text('No conversations yet',
      style: GoogleFonts.poppins(color: Colors.white),);
      setState(() {
        conversationsLoading = false;
      });
    }
  }
}