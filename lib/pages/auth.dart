import 'package:flutter/material.dart';

class AuthPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AuthPageState();
  }
}

class _AuthPageState extends State<AuthPage> {
  String _email = '';
  String _password = '';
  bool _acceptTerms = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Container(
        margin: EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              decoration: InputDecoration(labelText: 'Username'),
              onChanged: (String value) {
                _email = value;
              },
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
              onChanged: (String value) {
                _password = value;
              },
            ),
            SwitchListTile(
              title: Text('Accept Terms'),
              value: _acceptTerms,
              onChanged: (bool value) {
                print('Switch ' + value.toString());
                setState((){
                  _acceptTerms = value;
                });
              },
            ),
            Center(
                child: RaisedButton(
                    child: Text('LOGIN'),
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/');
                    }))
          ],
        ),
      ),
    );
  }
}
