import 'dart:io';

import 'package:codebase/Constants/colors.dart';
import 'package:codebase/Constants/routes.dart';
import 'package:codebase/Services/firebase_firesstore/firestore.dart';
import 'package:codebase/Services/firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CreateProfileView extends StatefulWidget {
  const CreateProfileView({super.key});

  @override
  State<CreateProfileView> createState() => _CreateProfileViewState();
}

class _CreateProfileViewState extends State<CreateProfileView> {

  String ?mediaURL;
  PlatformFile ?profilePic;
  ImageProvider ?previewImage;
  String ?username;
  String ?fieldSelection;
  List fieldOptions = ['Mobile Development', 'Game Development', 'System development',
                      'Software Development', 'Creative Design',];
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'CodeBase',
          style: GoogleFonts.rubik(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.w700,),
        ),
        backgroundColor: mainGrey,
      ),
      body: SafeArea(
          bottom: false,
          child: Container(
            color: const Color.fromARGB(255, 35, 35, 35),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                const SizedBox(height: 10,),
                // Welcome message
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Welcome to CodeBase',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 25
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10,),
                // Photo selecter & preview
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundImage: previewImage,
                      backgroundColor: Colors.grey,
                      radius: 80,
                      child: IconButton(
                        icon: const Icon(Icons.mode_edit),
                        iconSize: 30,
                        color: Colors.white,
                        onPressed: () async {
                          // Allow the user to pick photos/videos
                          final file = await FilePicker.platform.pickFiles();
                          // check if they have selected anything
                          if (file == null) return;
                          // If they have chosen an image
                          setState(() {
                            profilePic = file.files.first;
                            previewImage = FileImage(File(profilePic!.path.toString()));
                          });
                        },
                        ),
                    )
                  ],
                ),
                const SizedBox(height: 10,),
                // Username textfield
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                     SizedBox(
                       width: MediaQuery.of(context).size.width * 0.5,
                       child: TextField(
                          onChanged: (value) => username = value,
                          style: GoogleFonts.poppins(
                              fontSize: 18,
                              color: Colors.white),
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Choose a Username',
                            hintStyle: GoogleFonts.poppins(
                                      color: Colors.white),
                          ),
                        ),
                     ),
                    const Icon(
                      Icons.mode_edit,
                      color: Colors.white,
                     )
                  ],
                ),
                const SizedBox(height: 5,),
                // Selection box for their field of expertise
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DropdownButton(
                      iconEnabledColor: Colors.white,
                      alignment: Alignment.center,
                      hint: Text('Select a field',
                        style: GoogleFonts.poppins(
                              fontSize: 18,
                              color: Colors.white),
                      ),
                      dropdownColor: Colors.black,
                      value: fieldSelection,
                      onChanged: (value) {
                        setState(() {
                          fieldSelection = value.toString();
                        });
                      },
                      items: fieldOptions.map((selection) {
                        return DropdownMenuItem(
                          value: selection,
                          child: Text(selection,
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              color: Colors.white),
                          )
                        );
                      }).toList()
                    )
                  ],
                ),
                const SizedBox(height: 30,),
                // Create profile button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green
                  ),
                  onPressed: () async {
                    if (profilePic !=  null){
                      // Upload the profile pic
                      await uploadImage(profilePic!).then((result) {
                        setState(() {
                          mediaURL = result;
                        });
                      }); 
                    }
                    else if(profilePic == null){
                      // TODO Change this image to a placeholder user profile pic
                      mediaURL = 'https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg?cs=srgb&dl=pexels-pixabay-220453.jpg&fm=jpg';
                    }

                    if(username != null && fieldSelection != null){
                      // Upload the profile data to firestore doc
                      await uploadNewUser(
                       username: username!,
                       field: fieldSelection!,
                       profilePic: mediaURL,
                      );
                    // Send the user to the home view
                    Navigator.of(context).pushNamedAndRemoveUntil(homeRoute, (route) => false);
                    }
                  },
                  child: Text(
                    'Create Profile',
                    style: GoogleFonts.poppins(
                              fontSize: 18,
                              color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                )
              ],
            ),
          )),
      );
  }
}