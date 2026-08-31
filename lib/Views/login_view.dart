// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:codebase/Constants/routes.dart';
import 'package:codebase/Services/auth/auth_exceptions.dart';
import 'package:codebase/Services/auth/auth_service.dart';
import '../Utilities/General/show_error_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();// TODO: implement initState
    super.initState();
  }
  @override
  void dispose() {
    _email.dispose();
    _password.dispose();// TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Column(
        children: [
          TextField(
            controller: _email,
            autocorrect: false,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(hintText: 'Enter email here'),
          ),
          TextField(
            controller: _password,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            decoration: const InputDecoration(hintText: 'Enter password here'),
          ),
          TextButton(
                  onPressed: () async {
                    final email = _email.text;
                    final password = _password.text;
                    // Registering the user with email and password
                    try
                    {
                      // Attempts to sign in with the credentials inputed
                      await AuthService.firebase().logIn(email: email, password: password);
                      // Get the user credentials
                      final user = AuthService.firebase().currentUser;
                      // Check if they have verified email
                      if (user?.isEmailVerified ?? false)
                      {
                        // user is verified
                        Navigator.of(context).pushNamedAndRemoveUntil(homeRoute, (route) => false);
                      }
                      else
                      { 
                        // user isn't verified
                        Navigator.of(context).pushNamedAndRemoveUntil(verifyEmailRoute, (route) => false);
                      }
                    }
                    on UserNotFoundAuthException
                    {
                      await showErrorDialog(context, 'User Not Found');
                    }
                    on WrongPasswordAuthException
                    {
                      await showErrorDialog(context, 'Wrong Credentials');
                    }
                    on GenericAuthException
                    {
                       await showErrorDialog(context, 'Authentication Error');
                    }
                  },
                  child: const Text("Login"),
                  ),
          TextButton(
          onPressed: ()
          {
            Navigator.of(context).pushNamedAndRemoveUntil(registerRoute, (route) => false);
          }, 
          child: 
          const Text('Not registered yet? Register Here!')
          )
          ],
        ),
    );
  }
}

