import 'package:flutter/material.dart';
import 'package:linknotes/pages/dashboard.dart';
import 'package:linknotes/pages/notes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:linknotes/pages/signin.dart';
import 'package:linknotes/pages/folders.dart';

class OpenDrawerButton extends StatelessWidget {

  const OpenDrawerButton({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => Scaffold.of(context).openDrawer(),
      child: Icon(Icons.menu, color: Theme.of(context).primaryColor)
    );
  }
}

class LDrawer extends StatelessWidget {

  const LDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return NavigationDrawer(children: [
      'Dashboard',
      'Notes',
      'Folders',
      'Trash',
      'Settings',
      'Sign out'].map((element) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: TextButton.icon(
          onPressed: () {
            switch (element) {
              case 'Dashboard':
                Navigator.push(context, MaterialPageRoute(builder: (_) => const DashboardPage()));
                break;
              case 'Notes':
                Navigator.push(context, MaterialPageRoute(builder: (_) => const NotesPage()));
                break;
              case 'Folders':
                Navigator.push(context, MaterialPageRoute(builder: (_) => const FoldersPage(selectingFolder: false)));
                break;
              case 'Sign out':
                FirebaseAuth.instance.signOut();
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SignInPage()));
                break;
              default:
                break;
            }
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.only(left: 30.0),
            alignment: Alignment.centerLeft
          ),
          icon: (() {
            switch (element) {
              case 'Dashboard':
                return Icon(Icons.dashboard, color: Theme.of(context).primaryColor, size: 30.0);
              case 'Notes':
                return Icon(Icons.lightbulb, color: Theme.of(context).primaryColor, size: 30.0);
              case 'Folders':
                return Icon(Icons.folder, color: Theme.of(context).primaryColor, size: 30.0,);
              case 'Trash':
                return Icon(Icons.delete, color: Theme.of(context).primaryColor, size: 30.0);
              case 'Settings':
                return Icon(Icons.settings, color: Theme.of(context).primaryColor, size: 30.0);
              case 'Sign out':
                return Icon(Icons.logout, color: Theme.of(context).primaryColor, size: 30.0);
              default:
                return Container();
            }
          })(),
          label: Text(element, style: Theme.of(context).textTheme.displayMedium!)
        )
    )).toList());
  }

}