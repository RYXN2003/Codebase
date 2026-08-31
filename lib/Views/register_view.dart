import 'package:flutter/material.dart';
import 'package:codebase/Constants/routes.dart';
import 'package:codebase/Services/auth/auth_exceptions.dart';
import 'package:codebase/Services/auth/auth_service.dart';
import 'package:codebase/Utilities/General/show_error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
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
      appBar: AppBar(title: const Text('Register')),
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
                    onPressed: () async{
                      final email = _email.text;
                      final password = _password.text;
                      
                      try 
                      {
                        // Registering the user with email and password
                        await AuthService.firebase().createUser
                        (email: email, password: password);
                        // Send email verification
                        AuthService.firebase().sendEmailVerification();
                        // ignore: use_build_context_synchronously
                        Navigator.of(context).pushNamed(verifyEmailRoute);
                      }
                      // possible exceptions when registering 
                      on WeakPasswordAuthException
                      {
                        await showErrorDialog(context, 'Weak password');
                      }
                      on EmailAlreadyInUseAuthException
                      {
                        await showErrorDialog(context, 'Email already in use');
                      }
                      on InvalidEmailAuthException
                      {
                        await showErrorDialog(context, 'Invalid email address');
                      }
                      on GenericAuthException
                      {
                        await showErrorDialog(context, 'Registation Error');
                      }
                    },
                    child: const Text("Register"),
                  ),
          TextButton(
                onPressed: ()
                {
                  Navigator.of(context).pushNamedAndRemoveUntil(loginRoute, (route) => false);
                }, 
                child: 
                const Text('Already Registered? Login Here!')
            )
            ],
          ),
    );
  }
}
