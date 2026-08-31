import 'package:codebase/Constants/colors.dart';
import 'package:codebase/Services/firebase_firesstore/firestore.dart';
import 'package:codebase/Utilities/General/tabbar_posts.dart';
import 'package:codebase/Utilities/General/tabbar_projects.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Constants/routes.dart';
import '../Services/auth/auth_service.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: mainGrey,
        body: SafeArea(
            bottom: false,
            child:
                // Entire page container
                Container(
                  color: mainGrey,
                  child: Column(
                    children: [
                    // Padding
                      const SizedBox(height: 5,),
                    // Header
                    Padding(padding: const EdgeInsets.only(left: 20),
                    child:
                     Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'My Profile',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w400
                          )
                        ),
                        IconButton(onPressed:() async {
                          // calls the function to display the logout alert
                          final shouldLogout = await showLogoutDialog(context);
                          // if the user choses to log out
                          if (shouldLogout)
                          {
                            // logs the user out from firebase and send to the login view
                            await AuthService.firebase().logOut();
                            // ignore: use_build_context_synchronously
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              loginRoute, (_) => false);
                          }
                          else if (!shouldLogout)
                          {

                          }
                        },
                         icon: const Icon(
                          Icons.logout,
                          color: Colors.white,
                         )
                        )
                      ],
                     ),
                    ),
                    // Profile pic
                     Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(userProfileData!['ProfilePic']),
                          radius: 50,
                        )
                      ],
                    ),
                    // Padding
                      const SizedBox(height: 10,),
                    // Username
                     Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(userProfileData!['Username'],
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20
                          ),)
                        ],
                      ),
                    // Occupation / Field of interest
                     Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(userProfileData!['Field'],
                         style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 15
                          ),)
                      ],
                     ),
                    // Padding
                     const SizedBox(height: 35,),
                    // Account stats
                     Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // Total likes
                         Column(
                           children: [
                              Text('Likes',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold
                              ),),
                              Text(userProfileData!['TotalLikes'].toString(),
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold
                              ))
                           ],
                         ),
                        // Fans(Followers)
                         Column(
                           children: [
                             Text('Fans',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold
                              ),),
                              Text(userProfileData!['Fans'].toString(),
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold
                              ),)
                           ],
                         ),
                        // Total amount of posts
                         Column(
                           children: [
                             Text('Posts',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold
                              ),),
                              Text(userProfileData!['TotalPosts'].toString(),
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold
                              ),)
                           ],
                         ),
                      ],
                     ),
                    // Padding
                     const SizedBox(height: 10,),
                    // Tab option bar 
                     Container(
                      color: secondaryGrey,
                      child: Column(
                        children: const[
                            TabBar(
                              indicatorColor: Colors.white,
                              tabs: [
                                Tab(
                                  icon: Icon(Icons.collections, color: Colors.white,),
                                ),
                                Tab(
                                  icon: Icon(Icons.people_alt_sharp, color: Colors.white,),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    // Padding
                     const SizedBox(height: 10),
                    // Grid of user posts
                    const Expanded (
                      child: TabBarView(
                        children: [
                          TabBarPosts(),
                          TabBarProjects(),
                        ]
                        ),
                      ),
                    ],           
                  ),
               )
          ),
        ),
    );
  }

  // Logout prompt
  Future<bool> showLogoutDialog(BuildContext context)
  {
    return showDialog<bool>
    (
      context: context,
      builder:(context)
      {
        return AlertDialog
        (
          title: const Text('Sign Out'),
          content: const Text('Are you sure you want to sign out?'),
          actions:
          [
            TextButton(onPressed:(){Navigator.of(context).pop(false);},child: const Text('Cancel'),),
            TextButton(onPressed:(){Navigator.of(context).pop(true);},child: const Text('Log Out'),),
          ],
        );
      } 
    ).then((value) => value ?? false);
  }

}