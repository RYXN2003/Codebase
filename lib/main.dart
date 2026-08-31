import 'package:codebase/Views/conversations_view.dart';
import 'package:codebase/Views/create_post_view.dart';
import 'package:codebase/Views/home_view.dart';
import 'package:codebase/Views/verify_email_view.dart';
import 'package:flutter/material.dart';
import 'package:codebase/Constants/routes.dart';
import 'package:codebase/Services/auth/auth_service.dart';
import 'package:codebase/Views/login_view.dart';
import 'package:codebase/Views/register_view.dart';
import 'Views/profile_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp( 
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
      routes: 
      {
        homeRoute:(context) => const HomeView(),
        loginRoute: (context) => const LoginView(),
        registerRoute: (context) => const RegisterView(),
        verifyEmailRoute:(context) => const VerifyEmailView(),
        conversationsRoute:(context) => const ConversationsView(),
        profileRoute:(context) => const ProfileView(),
        createPostRoute:(context) => const CreatePostView(),
      },
      debugShowCheckedModeBanner: false,
    )
    );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: AuthService.firebase().initialise(),
        builder: (context, snapshot)  
        {
          switch(snapshot.connectionState)
          {
            // Firebase loaded
            case ConnectionState.done:
              // current user details
              final user = AuthService.firebase().currentUser;
              // If already logged in
              if(user!=null)
              {
                // If email is verified
                if(user.isEmailVerified)
                {
                  return const HomeView();
                }
                // If email is not verified
                else
                {
                    return const VerifyEmailView();
                }
              }
              // If hasnt logged in yet
              else
              {
                  return const LoginView();
              }
              
            // Firebase hasnt loaded yet
            default:
               return const CircularProgressIndicator();
          }
        },
      );
  }
}



