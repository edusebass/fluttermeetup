import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';
import 'src/authentication.dart';
import 'src/widgets.dart';
import 'gps_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Consumer<ApplicationState>(
              builder: (context, appState, _) {
                if (appState.loggedIn) {
                  return Column(
                    children: [
                      const Text(
                        'Bienvenid@',
                        style: TextStyle(fontSize: 24),
                      ),
                      Consumer<ApplicationState>(
                          builder: (context, appState, _) {
                        if (appState.loggedIn) {
                          return const GPSWidget();
                        } else {
                          return const Text('');
                        }
                      })
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      Image.asset('images/login.png', height: 250, width: 250),
                      const SizedBox(height: 8),
                      const Header("Firebase Login"),
                      const Paragraph(
                        'Presiona el botón para iniciar sesión con nosotros',
                      ),
                    ],
                  );
                }
              },
            ),
            const Divider(
              height: 8,
              thickness: 1,
              indent: 8,
              endIndent: 8,
              color: Colors.grey,
            ),
            const SizedBox(height: 10),
            Consumer<ApplicationState>(
              builder: (context, appState, _) => AuthFunc(
                loggedIn: appState.loggedIn,
                signOut: () {
                  FirebaseAuth.instance.signOut();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
