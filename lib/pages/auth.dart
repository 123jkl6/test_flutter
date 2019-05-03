import 'package:flutter/material.dart';

class AuthPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AuthPageState();
  }
}

class _AuthPageState extends State<AuthPage> {
  final Map<String, String> _userAuth = {'email': null, 'password': null};
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _acceptTerms = false;

  DecorationImage _buildBackgroundImage() {
    return DecorationImage(
        colorFilter:
            ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.dstATop),
        fit: BoxFit.cover,
        image: AssetImage('assets/background.jpg'));
  }

  Widget _buildUsernameField() {
    return TextFormField(
      decoration: InputDecoration(
          labelText: 'Username', filled: true, fillColor: Colors.white),
      validator: (String value) {
        if (value.isEmpty || !RegExp(r'^\w+@[a-zA-Z_]+?\.[a-zA-Z]{2,3}$').hasMatch(value)) {
          return "Email is required and must be a valid email address. ";
        }
      },
      onSaved: (String value) {
        _userAuth['email'] = value;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      decoration: InputDecoration(
          labelText: 'Password', filled: true, fillColor: Colors.white),
      obscureText: true,
      validator: (String value) {
        if (value.isEmpty || value.length < 6) {
          return "Password is required is of 6+ characters. ";
        }
      },
      onSaved: (String value) {
        _userAuth['password'] = value;
      },
    );
  }

  Widget _buildSwitchListTile() {
    return SwitchListTile(
      title: Text('Accept Terms'),
      value: _acceptTerms,
      onChanged: (bool value) {
        print('Switch ' + value.toString());
        setState(() {
          _acceptTerms = value;
        });
      },
    );
  }

  Widget _buildLoginButton() {
    return Center(child: RaisedButton(child: Text('LOGIN'), onPressed: login));
  }

  void login() {
    print(_userAuth);
    if (!_formKey.currentState.validate()){
      //if not valid, stop execution. 
      return;
    }
    _formKey.currentState.save();
    //allow only one user and pass
    if (_userAuth['email']!='nicholasngchuxu@gmail.com' || _userAuth['password']!='admin123'){
      print('Not Authorized. ');
      return;
    }
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 550.0 ? 500.0 : deviceWidth * 0.95;

    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Container(
        decoration: BoxDecoration(image: _buildBackgroundImage()),
        padding: EdgeInsets.all(10.0),
        child: Form(
          key:_formKey,
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                width: targetWidth,
                child: Column(
                  children: <Widget>[
                    _buildUsernameField(),
                    _buildPasswordField(),
                    _buildSwitchListTile(),
                    _buildLoginButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
