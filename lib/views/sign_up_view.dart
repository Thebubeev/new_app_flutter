import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:new_app/services/auth_service.dart';
import 'package:new_app/views/widgets/provider_widget.dart';

final primaryColor = const Color(0xFF75A2EA);
enum AuthFormType { signIn, signUp, reset }

class SignUpView extends StatefulWidget {
  final AuthFormType authFormType;

  SignUpView({Key key, @required this.authFormType}) : super(key: key);

  @override
  _SignUpViewState createState() =>
      _SignUpViewState(authFormType: this.authFormType);
}

class _SignUpViewState extends State<SignUpView> {
  AuthFormType authFormType;
  final formKey = GlobalKey<FormState>();
  String _email, _password, _name, _warning;

  void switchFormState(String state) {
    formKey.currentState.reset();
    if (state == 'signUp') {
      setState(() {
        authFormType = AuthFormType.signUp;
      });
    } else {
      setState(() {
        authFormType = AuthFormType.signIn;
      });
    }
  }

  _SignUpViewState({this.authFormType});

  bool validate() {
    final form = formKey.currentState;
    form.save();
    if (form.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }

  void submit() async {
    if (validate()) {
      final auth = Provider.of(context).auth;
      try {
        if (authFormType == AuthFormType.signIn) {
          String uid = await auth.signInWithEmailAndPassword(_email, _password);
          print('Signed in with ID $uid');
          Navigator.of(context).pushReplacementNamed('/home');
        } else if (authFormType == AuthFormType.reset) {
          print('Password reset email sent');
          await auth.sendPasswordResetEmail(_email);
          _warning = 'A password reset link has been sent to $_email';
          setState(() {
            authFormType = AuthFormType.signIn;
          });
        } else {
          String uid = await auth.createUserWithEmailAndPassword(
              _email, _password, _name);
          print('Signed up with New ID $uid');
          Navigator.of(context).pushReplacementNamed('/home');
        }
      } catch (e) {
        setState(() {
          _warning = e.message;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        width: _width,
        height: _height,
        color: primaryColor,
        child: SafeArea(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: _height * 0.025,
              ),
              showAlert(),
              SizedBox(
                height: _height * 0.025,
              ),
              buildHeaderText(),
              SizedBox(
                height: _height * 0.05,
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: formKey,
                  child: Column(
                    children: buildInputs() + buildButtons(),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget showAlert() {
    if (_warning != null) {
      return Container(
        color: Colors.amberAccent,
        width: double.infinity,
        padding: EdgeInsets.all(8),
        child: Row(
          children: <Widget>[
            Icon(Icons.error_outline),
            Expanded(
              child: AutoSizeText(
                _warning,
                maxLines: 3,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 8),
              child: IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _warning = null;
                  });
                },
              ),
            )
          ],
        ),
      );
    }
    return SizedBox(height: 0);
  }

  AutoSizeText buildHeaderText() {
    String _headerText;
    if (authFormType == AuthFormType.signUp) {
      _headerText = 'Create New Account';
    } else if (authFormType == AuthFormType.reset) {
      _headerText = 'Reset Password';
    } else {
      _headerText = 'Sign In';
    }
    return AutoSizeText(
      _headerText,
      maxLines: 1,
      textAlign: TextAlign.center,
      style: TextStyle(color: Colors.white, fontSize: 35.0),
    );
  }

  List<Widget> buildInputs() {
    List<Widget> textFields = [];

    if (authFormType == AuthFormType.reset) {
      textFields.add(
        TextFormField(
          validator: NameValidator.validate,
          style: TextStyle(fontSize: 22),
          decoration: buildSignUpInputDecoration('Email'),
          onSaved: (value) => _email = value,
        ),
      );
      textFields.add(SizedBox(
        height: 20,
      ));
      return textFields;
    }

    if (authFormType == AuthFormType.signUp) {
      textFields.add(
        TextFormField(
          validator: NameValidator.validate,
          style: TextStyle(fontSize: 22),
          decoration: buildSignUpInputDecoration('Name'),
          onSaved: (value) => _name = value,
        ),
      );
      textFields.add(SizedBox(
        height: 20,
      ));
    }

    textFields.add(
      TextFormField(
        validator: EmailValidator.validate,
        style: TextStyle(fontSize: 22),
        decoration: buildSignUpInputDecoration('Email'),
        onSaved: (value) => _email = value,
      ),
    );
    textFields.add(SizedBox(
      height: 20,
    ));
    textFields.add(
      TextFormField(
        validator: PasswordValidator.validate,
        style: TextStyle(fontSize: 22),
        decoration: buildSignUpInputDecoration('Password'),
        onSaved: (value) => _password = value,
        obscureText: true,
      ),
    );
    textFields.add(SizedBox(
      height: 20,
    ));
    return textFields;
  }

  InputDecoration buildSignUpInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      fillColor: Colors.white,
      filled: true,
      focusColor: Colors.white,
      enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white, width: 0)),
      contentPadding: EdgeInsets.only(left: 14, top: 10, bottom: 10),
    );
  }

  List<Widget> buildButtons() {
    String _switchButton, _newFormState, _submitButtonText;
    bool _showForgotPassword = false;

    if (authFormType == AuthFormType.signIn) {
      _switchButton = 'Create New Account';
      _newFormState = 'signUp';
      _submitButtonText = 'Sign In';
      _showForgotPassword = true;
    } else if (authFormType == AuthFormType.reset) {
      _switchButton = 'Return to Sign In';
      _newFormState = 'signIn';
      _submitButtonText = 'Submit';
    } else {
      _switchButton = 'Have an Account? Sign In!';
      _newFormState = 'signIn';
      _submitButtonText = 'Sign Up';
    }
    return [
      Container(
        width: MediaQuery.of(context).size.height * 0.7,
        child: RaisedButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          color: Colors.white,
          textColor: primaryColor,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _submitButtonText,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300),
            ),
          ),
          onPressed: submit,
        ),
      ),
      showForgotPassword(_showForgotPassword),
      FlatButton(
        child: Text(
          _switchButton,
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () {
          switchFormState(_newFormState);
        },
      )
    ];
  }

  Widget showForgotPassword(bool visible) {
    return Visibility(
      child: FlatButton(
        child: Text(
          'Forgot Password?',
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () {
          setState(() {
            authFormType = AuthFormType.reset;
          });
        },
      ),
      visible: visible,
    );
  }
}
