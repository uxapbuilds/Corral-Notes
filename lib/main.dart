import 'package:corralnotes/cubit/authentication_cubit/authentication_cubit.dart';
import 'package:corralnotes/cubit/home_cubit/home_cubit.dart';
import 'package:corralnotes/ui/auth_page/auth_page.dart';
import 'package:corralnotes/ui/home_page/home.dart';
import 'package:corralnotes/widgets/error_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:oktoast/oktoast.dart';

import 'constants/strings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthenticationCubit>(
            create: ((context) => AuthenticationCubit())),
        BlocProvider<HomeCubit>(create: ((context) => HomeCubit()))
      ],
      child: OKToast(
        child: MaterialApp(
          title: 'corralnotes',
          theme: ThemeData(
            fontFamily: 'Hellix',
            primarySwatch: MaterialColor(0xFFFFFFFF, color),
            textSelectionTheme: const TextSelectionThemeData(
              cursorColor: Colors.black,
              selectionColor: Colors.grey,
              selectionHandleColor: Colors.grey,
            ),
          ),
          home: const CorralNavTo(),
        ),
      ),
    );
  }
}

class CorralNavTo extends StatelessWidget {
  const CorralNavTo({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const ErrorPage();
          } else if (snapshot.hasData) {
            return const HomePage();
          } else if (snapshot.hasError) {
            return const ErrorPage(
              hasError: true,
              errorText: 'Something went wrong',
            );
          }
          return const AuthPage();
        });
  }
}
