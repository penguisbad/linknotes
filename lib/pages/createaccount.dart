import 'package:flutter/material.dart';
import 'package:linknotes/widgets/backbutton.dart';
import 'package:linknotes/widgets/contentcontainer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:linknotes/widgets/errordialog.dart';
import 'package:linknotes/pages/dashboard.dart';

class CreateAccountPage extends StatefulWidget {

  const CreateAccountPage({super.key});

  @override
  State<CreateAccountPage> createState() => _CreateAccountState();

}

class _CreateAccountState extends State<CreateAccountPage> {

  var _displayName = '';
  var _email = '';
  var _password = '';
  var _passwordVisible = false;
  var _confirmPassword = '';

  @override
  Widget build(BuildContext context) {
    return WillPopScope(onWillPop: () async => false, child: Scaffold(
      appBar: AppBar(
        leading: LBackButton(onPressed: () => Navigator.pop(context)),
        title: Text('Create account', style: Theme.of(context).textTheme.displayMedium!)
      ),
      body: ContentContainer(maxWidth: 300.0, child: ListView(
        children: [
          const SizedBox(height: 50.0),
          TextField(
            onChanged: (value) => _email = value,
            style: Theme.of(context).textTheme.displaySmall!,
            decoration: const InputDecoration(
              hintText: 'email'
            ),
          ),
          const SizedBox(height: 10.0),
          TextField(
            onChanged: (value) => _displayName = value,
            style: Theme.of(context).textTheme.displaySmall!,
            decoration: const InputDecoration(
              hintText: 'display name'
            ),
          ),
          const SizedBox(height: 50.0),
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
          const SizedBox(height: 10.0),
          TextField(
            onChanged: (value) => _confirmPassword = value,
            style: Theme.of(context).textTheme.displaySmall!,
            obscureText: true,
            decoration: const InputDecoration(
              hintText: 'confirm password'
            ),
          ),
          const SizedBox(height: 50.0),
          Center(child: SizedBox(width: 200.0, child: ElevatedButton(
            onPressed: () async {
              if (_password != _confirmPassword) {
                (() {
                  showDialog(context: context, builder: (_) => const ErrorDialog(message: 'Passwords must match'));
                })();
                return;
              }

              try {
                await FirebaseAuth.instance.createUserWithEmailAndPassword(email: _email, password: _password);
                await FirebaseAuth.instance.currentUser!.updateDisplayName(_displayName);
              } on FirebaseAuthException catch (e) {
                (() {
                  showDialog(context: context, builder: (_) => ErrorDialog(message: e.message!));
                })();
                return;
              }

              (() {
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => const DashboardPage()
                ));
              })();
            },
            child: Text('Create account', style: Theme.of(context).textTheme.displaySmall!)
          )))
        ]
      ))
    ));
  }

}