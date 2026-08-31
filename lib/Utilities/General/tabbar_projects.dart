import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codebase/Constants/colors.dart';
import 'package:codebase/Views/project_view.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../Services/firebase_firesstore/firestore.dart';

class TabBarProjects extends StatefulWidget {
  const TabBarProjects({super.key});

  @override
  State<TabBarProjects> createState() => _TabBarProjectsState();
}

class _TabBarProjectsState extends State<TabBarProjects> {
  List<Widget> projectList = [];
  bool shouldGatherProjects = true;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('Projects')
      .where('Team', arrayContains: userProfileData!['Username']).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
        if (!snapshot.hasData){
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if(snapshot.hasData && shouldGatherProjects)
        {
          final projects = snapshot.data?.docs.toList();
          for (var project in projects!){
            final projectWidget = createProjectWidget(project,context);
            projectList.add(projectWidget);
          }
          shouldGatherProjects = false;
        }
        return GridView(
          gridDelegate: 
          SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 1, 
          mainAxisExtent: MediaQuery.of(context).size.height * 0.25),
          children: projectList,
        );
      },
    );
  }
  
  createProjectWidget(QueryDocumentSnapshot<Object?> project, BuildContext context) {
    Map<String,dynamic> projectdata = {
      'CoverImage': project['CoverImage'],
      'Fans': project['Fans'],
      'Name': project['Name'],
      'Posts': project['Posts'],
      'Started': project['Started'],
      'Team': project['Team'],
      'TotalFans': project['TotalFans'],
      'TotalMembers': project['TotalMembers'],
      'TotalPosts': project['TotalPosts'],
    };

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => ProjectView(projectData: projectdata))
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: secondaryGrey,
            borderRadius: BorderRadius.circular(30)
          ),
          child: Column(
            children: [
            // Header
              Padding(
                padding: const EdgeInsets.all(10),
              // Header
                child: Row(
                  children: [
                  // Cover image
                    CircleAvatar(
                      radius: 35,
                      backgroundImage: NetworkImage(project['CoverImage']),
                    ),
                    const SizedBox(width: 10,),
                  // Title and est date
                    Column(
                      children: [
                        Text(
                          project['Name'],
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 20
                          ),
                        ),
                        Text(
                          'est. ${project['Started']}',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 13
                          ),
                        ),
                      ],
                    ),
                  // 
                  ],
                ),
              ),
            // Stats
              Padding(
                padding:const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                  // Fans
                    Column(
                      children: [
                        Text(
                          'Fans',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 15
                          ),
                        ),
                        Text(
                          project['TotalFans'].toString(),
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 20
                          ),
                        )
                      ],
                    ),
                  // Team Members
                    Column(
                      children: [
                        Text(
                          'Members',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 15
                          ),
                        ),
                        Text(
                          project['TotalMembers'].toString(),
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 20
                          ),
                        )
                      ],
                    ),
                  // Posts
                    Column(
                      children: [
                        Text(
                          'Posts',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 15
                          ),
                        ),
                        Text(
                          project['TotalPosts'].toString(),
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 20
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}