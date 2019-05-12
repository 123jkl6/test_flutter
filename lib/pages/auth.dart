import 'package:flutter/material.dart';

import 'package:scoped_model/scoped_model.dart';

import '../scoped_models/main.dart';

import '../models/auth.dart';

class AuthPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AuthPageState();
  }
}

class _AuthPageState extends State<AuthPage> {
  final Map<String, String> _userAuth = {'email': null, 'password': null};
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordTextController = TextEditingController();
  AuthMode _authMode = AuthMode.Login;
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
      keyboardType: TextInputType.emailAddress,
      validator: (String value) {
        if (value.isEmpty ||
            !RegExp(r'^\w+@[a-zA-Z_]+?\.[a-zA-Z]{2,3}$').hasMatch(value)) {
          return "Email is required and must be a valid email address. ";
        }
      },
      onSaved: (String value) {
        _userAuth['email'] = value;
      },
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      decoration: InputDecoration(
          labelText: 'Confirm Password', filled: true, fillColor: Colors.white),
      obscureText: true,
      validator: (String value) {
        if (_passwordTextController.text != value) {
          return "Passwords do not match. ";
        }
      },
      onSaved: (String value) {
        _userAuth['password'] = value;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      decoration: InputDecoration(
          labelText: 'Password', filled: true, fillColor: Colors.white),
      obscureText: true,
      controller: _passwordTextController,
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
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return model.isLoading
          ? Center(child: CircularProgressIndicator())
          : Center(
              child: RaisedButton(
                  child:
                      Text(_authMode == AuthMode.Login ? 'LOGIN' : 'SIGN UP'),
                  onPressed: () => login(model)));
    });
  }

  void login(MainModel model) async {
    print(_userAuth);
    if (!_formKey.currentState.validate()) {
      //if not valid, stop execution.
      return;
    }
    _formKey.currentState.save();
    final Map<String, dynamic> successInfo = await model.authenticate(
        _userAuth['email'], _userAuth['password'], _authMode);
    if (successInfo['success']) {
      print('success');
      if (_authMode == AuthMode.Login) {
        Navigator.pushReplacementNamed(context, '/products');
      } else {
        setState(() {
          _authMode = AuthMode.Login;
        });
      }
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('An Error Occured!'),
              content: Text(successInfo['message']),
              actions: <Widget>[
                FlatButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          });
    }
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
          key: _formKey,
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                width: targetWidth,
                child: Column(
                  children: <Widget>[
                    _buildUsernameField(),
                    SizedBox(height: 10.0),
                    _buildPasswordField(),
                    SizedBox(height: 10.0),
                    _authMode == AuthMode.Signup
                        ? _buildConfirmPasswordField()
                        : Container(),
                    SizedBox(height: 10.0),
                    FlatButton(
                        child: Text(
                            "${_authMode == AuthMode.Login ? 'Sign up' : 'Login'}"),
                        onPressed: () {
                          setState(() {
                            _authMode = _authMode == AuthMode.Login
                                ? AuthMode.Signup
                                : AuthMode.Login;
                          });
                        }),
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
