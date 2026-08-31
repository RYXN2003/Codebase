import 'package:codebase/Constants/colors.dart';
import 'package:codebase/Services/firebase_firesstore/firestore.dart';
import 'package:codebase/Views/conversations_view.dart';
import 'package:codebase/Views/create_profile_view.dart';
import 'package:codebase/Views/profile_view.dart';
import 'package:codebase/Views/social_view.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState(){
    // Check if the user owns a profile
    checkForProfile().then((result) {
      setState(() {
      userHasProfile = result;
    });
    // Save the user profile details locally
    getUserProfileData();
    });
    super.initState();
  }
  // Holds the index of the active page
  int navIndex = 0;
  // Should the tabbar be visible
  bool tabbarVisible = true;
  // Does the user own a profile
  bool ?userHasProfile;
  // Find the correct page to display
  Widget choosePage(){
    if(userHasProfile == null){
      return const CircularProgressIndicator();
    }
    else if (!userHasProfile!){
      tabbarVisible = false;
      return const CreateProfileView();
    }
    return selectPage();
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold
    (
      extendBody: true,
      backgroundColor: mainGrey,
      body: choosePage(),
      bottomNavigationBar: CurvedNavigationBar(
        height: 60,
        animationDuration: const Duration(milliseconds: 200),
        backgroundColor: mainGrey.withOpacity(0),
        buttonBackgroundColor: Colors.deepPurple,
        color: mainGrey,
        index: navIndex,
        onTap: (selectedIndex) {
          setState(() {
            navIndex = selectedIndex;
          });
        },
        items: const [
           Icon(
              Icons.home_rounded,
              color: Colors.white,
              size: 30,
            ),
           Icon(
              Icons.chat_bubble_outlined,
              color: Colors.white,
              size: 30,
            ),
           Icon(
              Icons.person_2_rounded,
              color: Colors.white,
              size: 30,
            ),
        ],
      )
  
    );
  }
   Widget selectPage(){
    if(navIndex == 0){
      return const SocialView();
    }
    if(navIndex == 1){
      return const ConversationsView();
    }
    if(navIndex == 2){
      return const ProfileView();
    }
    else
    {
      return const SocialView();
    }
  }
}



