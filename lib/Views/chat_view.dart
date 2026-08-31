import 'package:codebase/Constants/colors.dart';
import 'package:codebase/Constants/routes.dart';
import 'package:codebase/Services/firebase_firesstore/firestore.dart';
import 'package:codebase/Utilities/General/chat_section.dart';
import 'package:codebase/Utilities/General/message.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatView extends StatefulWidget {
  final Map<String,dynamic> recieverData;

  const ChatView({super.key,  required this.recieverData,});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  // List of messages
  List<Message> messages = [] ;
  // The widget for the chat section
  Widget ?chatSection;
  // Waits until the posts have been formatted
  bool hasFormatedPosts = false;
  // Send message text controller
  TextEditingController messageToSend = TextEditingController();

  @override
  void initState() {
    handleConversation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
              Container(
                color: Colors.black,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                    // back arrow
                      IconButton(
                        onPressed: (){
                          Navigator.of(context).pushNamedAndRemoveUntil(
                           homeRoute, (route) => false);
                        },
                        icon: const Icon(Icons.arrow_back,
                        color: Colors.white,) 
                      ),
                    // Padding
                      const SizedBox(width: 20,),
                    // User Profile Pic 
                      CircleAvatar(
                        radius: 25,
                        backgroundImage: NetworkImage(widget.recieverData['ProfilePic']),
                      ),
                    // Padding
                      const SizedBox(width: 10,),
                    // Username
                      Text(widget.recieverData['Username'],
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15
                      ),),
                    ],
                  ),
                ),
              ),
            // Chat section
              hasFormatedPosts ? chatSection! : 
              const Expanded( child:CircularProgressIndicator()),
            // Write a chat message
              Container(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                  child: Row(
                    children: [
                      // Input messsage text field
                        Expanded(
                          child: TextField(
                            controller: messageToSend,
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 15
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none
                              ),
                              hintText: 'Send a message',
                              prefixIcon: const Icon(Icons.search),
                              prefixIconColor: Colors.black
                            ),
                          ),
                        ),
                      // Padding
                        const SizedBox(width: 10,),
                      // Send button
                        SizedBox(
                          width: 50,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100)
                                )
                            ),
                            onPressed: () async{
                              // List of users in a convo
                                List<String> userList = [userProfileData!['Username'], widget.recieverData['Username']];
                              if (messageToSend.text.isNotEmpty){
                                // If there is no messages then create a new conversations doc
                                if(messages.isEmpty){
                                  await createConversation(users: userList);
                                }
                                // Create a new message
                                Message newMessage = Message(
                                  time: '${TimeOfDay.now().hour}:${TimeOfDay.now().minute}',
                                  text: messageToSend.text,
                                  date: DateTime.now(),
                                  isSentByMe: true,
                                  seenBy: [userProfileData!['Username']]
                                );
                                // Clear the input box
                                messageToSend.clear();
                                // Update the local message list
                                setState(() {
                                  // add the new message to local list
                                  messages.add(newMessage);
                                  // update the listview
                                  chatSection = createChatSection(messages);
                                }); 
                                // Push the new list to firestore
                                  await uploadNewMessage(users: userList, messageToUpload: newMessage);
                              }
                              
                            },
                            child: const Icon(Icons.send)
                          ),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        )
      ),
    );
  }
  
  void handleConversation() async{
    // Chat data
    Map<String,dynamic> chatData = {};
    // Search firestore for a prevoius conversation
    await searchForPreviousConvo(widget.recieverData['Username'])
    .then((value) {
      chatData = value;
    });
    // Check if its empty or not
    if(chatData.isEmpty){
      setState(() {
        chatSection = 
           Expanded(
             child: Container(
              color: secondaryGrey,
                child: Column(
                  children:[ 
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text('No message yet',
                        style: GoogleFonts.poppins(color: Colors.white, fontSize: 20),),
                      ],
                  ),
                  ]
                ),
              ),
           );
        hasFormatedPosts = true;
      });
    } 
    // If it has data
    if(chatData.isNotEmpty){
      // Get all messages from the conversation
      await getAllMessagesFromConvo(users: chatData['Users'])
      .then((value) {
        messages = value;
      });
      setState(() {
        chatSection = 
          createChatSection(messages);
          hasFormatedPosts = true;
      });
    }
  }
}