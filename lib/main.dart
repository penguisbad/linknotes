import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:linknotes/firebase_options.dart';
import 'package:linknotes/pages/signin.dart';


const backgroundColor = Color.fromRGBO(40, 40, 60, 1);
const primaryColor = Color.fromRGBO(180, 180, 190, 1);
const secondaryColor = Color.fromRGBO(70, 70, 100, 1); 


final inputBorder = OutlineInputBorder(
  borderRadius: BorderRadius.circular(20.0),
  borderSide: const BorderSide(
    color: secondaryColor,
    width: 3.0
  )
);

final theme = ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: secondaryColor),
  primaryColor: primaryColor,
  hintColor: secondaryColor,
  scaffoldBackgroundColor: backgroundColor,
  textTheme: const TextTheme(
    displayMedium: TextStyle(
      fontSize: 24.0,
      fontWeight: FontWeight.w400,
      color: primaryColor,
      overflow: TextOverflow.ellipsis
    ),
    displaySmall: TextStyle(
      fontSize: 18.0,
      fontWeight: FontWeight.w400,
      color: primaryColor,
      overflow: TextOverflow.ellipsis
    ),
    labelSmall: TextStyle(
      fontSize: 18.0,
      fontWeight: FontWeight.w400,
      color: secondaryColor,
      overflow: TextOverflow.ellipsis
    ),
    labelMedium: TextStyle(
      fontSize: 24.0,
      fontWeight: FontWeight.w400,
      color: secondaryColor,
      overflow: TextOverflow.ellipsis
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0.0,
      padding: const EdgeInsets.symmetric(
        horizontal: 10.0,
        vertical: 15.0
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0)
      ),
      disabledBackgroundColor: secondaryColor,
      backgroundColor: secondaryColor
    )
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: backgroundColor,
      splashFactory: NoSplash.splashFactory
    )
  ),
  appBarTheme: const AppBarTheme(
    toolbarHeight: 80.0,
    backgroundColor: secondaryColor,
    scrolledUnderElevation: 0.0
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: inputBorder,
    enabledBorder: inputBorder,
    focusedBorder: inputBorder,
    contentPadding: const EdgeInsets.all(20.0)
  ),
  iconButtonTheme: IconButtonThemeData(
    style: IconButton.styleFrom(
      iconSize: 30.0,
      foregroundColor: primaryColor
    )
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: secondaryColor,
    iconSize: 30.0,
  ),
  radioTheme: const RadioThemeData(
    fillColor: MaterialStatePropertyAll(secondaryColor)
  ),
  checkboxTheme: CheckboxThemeData(
    checkColor: const MaterialStatePropertyAll(primaryColor),
    fillColor: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.selected)) {
        return secondaryColor;
      }
      return Colors.transparent;
    }),
    side: const BorderSide(
      color: secondaryColor,
      width: 3.0
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(5.0),
    )
  ),
  dividerTheme: const DividerThemeData(
    color: secondaryColor,
    thickness: 1.0
  ),
  dropdownMenuTheme: DropdownMenuThemeData(
    inputDecorationTheme: InputDecorationTheme(
      border: inputBorder,
      enabledBorder: inputBorder,
      focusedBorder: inputBorder,
      contentPadding: const EdgeInsets.all(20.0)
    ),
    menuStyle: const MenuStyle(
      
      backgroundColor: MaterialStatePropertyAll(secondaryColor),
    ),
    textStyle: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.w400, color: primaryColor)
  ),
  switchTheme: SwitchThemeData(
    thumbColor: MaterialStateProperty.resolveWith((states) {
      if (!states.contains(MaterialState.selected)) {
        return secondaryColor;
      }
      return primaryColor;
    }),
    trackColor: const MaterialStatePropertyAll(secondaryColor)
  ),
  drawerTheme: const DrawerThemeData(
    backgroundColor: backgroundColor
  ),
  dialogTheme: DialogTheme(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20.0)
    ),
    actionsPadding: const EdgeInsets.only(bottom: 20.0, right: 20.0),
    backgroundColor: backgroundColor
  ),
  snackBarTheme: SnackBarThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20.0)
    ),
    behavior: SnackBarBehavior.floating,
    backgroundColor: backgroundColor,
    actionBackgroundColor: secondaryColor
  ),
  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: secondaryColor
  ),
  cupertinoOverrideTheme: const NoDefaultCupertinoThemeData(
    textTheme: CupertinoTextThemeData(
      dateTimePickerTextStyle: TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.w400,
        color: primaryColor,
        overflow: TextOverflow.ellipsis
    )
    )
  )
);
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    if (user == null) {
      return;
    }
    final ref = FirebaseDatabase.instance.ref('userIds/${user.uid}');
    ref.set(user.uid);
  });
  runApp(MaterialApp(
    home: const SignInPage(),
    theme: theme,
  ));
}