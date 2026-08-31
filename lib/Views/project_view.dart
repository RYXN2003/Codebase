import 'package:codebase/Constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProjectView extends StatefulWidget {
  Map<String,dynamic> projectData = {};

  ProjectView({super.key,  required this.projectData,});

  @override
  State<ProjectView> createState() => _ProjectViewState();
}

class _ProjectViewState extends State<ProjectView> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: mainGrey,
        body: SafeArea(
          bottom: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            // Header
              Row(
                children: [
                // back arrow
                  IconButton(
                    onPressed: (){
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.arrow_back,
                    color: Colors.white,) 
                  ),
                ],
              ),
            // Project Credentials
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    Expanded(
                    flex: 1,
                    // Project cover image
                    child: Column(
                      children: [
                        CircleAvatar(
                            radius: 70,
                            backgroundImage: NetworkImage(widget.projectData['CoverImage']),
                          ),
                        // est date
                        Text(
                          'est. ${widget.projectData['Started']}',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 15
                          ),
                        ),
                      ],
                    ),
                    ),
                  // Padding
                    const SizedBox(width: 5,),
                  Expanded(
                    flex: 2,
                  // Project info
                    child: Column(
                      children: [
                      // Title
                        Text(
                          widget.projectData['Name'],
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 25
                          ),
                        ),
                      // Become A Fan button 
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5)
                            ),
                            backgroundColor: Colors.white
                          ),
                          onPressed: (){},
                          label: Text(
                            'Become A Fan',
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 13),
                          ),
                          icon: const Icon(
                            Icons.add_reaction,
                            color: Colors.black,
                          ), 
                        ),
                      // Padding
                        const SizedBox(height: 10,),
                      // Account stats
                       Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Fans(Followers)
                           Column(
                             children: [
                               Text('Fans',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold
                                ),),
                                Text(widget.projectData['TotalFans'].toString(),
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold
                                ),)
                             ],
                           ),
                          // Total members
                           Column(
                             children: [
                                Text('Members',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold
                                ),),
                                Text(widget.projectData['TotalMembers'].toString(),
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold
                                ))
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
                                Text(widget.projectData['TotalPosts'].toString(),
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold
                                ),)
                             ],
                           ),
                        ],
                       ),
                      ],
                    ),
                  ),
                ],
                ),
              ),
            // Padding
              const SizedBox(height: 10,),
            // Tabbar 
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
            // Tabbar View
              Expanded(
                child: TabBarView(
                  children: [
                    Container(),
                    Container()
                  ]
                ),
              )         
            ],
          )
        )
      ),
    );
  }
}