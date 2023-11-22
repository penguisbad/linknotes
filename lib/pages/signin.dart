import 'package:flutter/material.dart';
import 'package:linknotes/widgets/contentcontainer.dart';
import 'package:linknotes/widgets/errordialog.dart';
import 'package:linknotes/pages/createaccount.dart';
import 'package:linknotes/pages/dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignInPage extends StatefulWidget {

  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInState();

}

class _SignInState extends State<SignInPage> {

  var _email = '';
  var _password = '';
  var _passwordVisible = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(onWillPop: () async => false ,child: Scaffold(
      body: ContentContainer(
        maxWidth: 300.0,
        child: ListView(children: [
          const SizedBox(height: 50.0),
          const Text('LinkNotes',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 30.0,
              color: Color.fromRGBO(180, 180, 190, 1)
            ),
          ),
          const SizedBox(height: 50.0),
          TextField(
            onChanged: (value) => _email = value,
            style: Theme.of(context).textTheme.displaySmall!,
            decoration: const InputDecoration(
              hintText: 'email'
            )
          ),
          const SizedBox(height: 10.0),
          TextField(
            onChanged: (value) => _password = value,
            style: Theme.of(context).textTheme.displaySmall!,
            obscureText: !_passwordVisible,
            decoration: InputDecoration(
              hintText: 'password',
              suffixIcon: Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: IconButton(
                  onPressed: () => setState(() {
                    _passwordVisible = !_passwordVisible;
                  }),
                  icon: Icon(_passwordVisible ? Icons.visibility_off : Icons.visibility, color: Theme.of(context).primaryColor)
                )
              )
            ),
          ),
          const SizedBox(height: 50.0),
          Center(child: SizedBox(width: 200.0, child: ElevatedButton(
            onPressed: () async {
              try {
                await FirebaseAuth.instance.signInWithEmailAndPassword(email: _email, password: _password);

              } on FirebaseAuthException catch (e) {
                (() {
                  showDialog(context: context, builder: (_) => ErrorDialog(message: e.message ?? ''));
                })();
                return;
              }

              (() {
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => const DashboardPage()
                ));
              })();
            },
            child: Text('Sign in', style: Theme.of(context).textTheme.displaySmall!)
          ))),
          const SizedBox(height: 10.0),
          Center(child: SizedBox(width: 200.0, child: ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateAccountPage()));
            },
            child: Text('Create account', style: Theme.of(context).textTheme.displaySmall!)
          ))),
          const SizedBox(height: 50.0),
          TextButton(
            onPressed: () {},
            child: Text('I forgot my password', style: Theme.of(context).textTheme.displaySmall!)
          ),
          const SizedBox(height: 10.0),
          TextButton(
            onPressed: () {},
            child: Text('Offline mode', style: Theme.of(context).textTheme.displaySmall!)
          ),
          const SizedBox(height: 50.0)
        ])
      )
    ));
  }

}