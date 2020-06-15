import 'package:flutter/material.dart';

class LoginButton extends StatelessWidget {
  final VoidCallback _onPressed;

  const LoginButton({Key key, VoidCallback onPressed})
      : _onPressed = onPressed,
        super(key: key);
  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      color: Theme.of(context).appBarTheme.color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
      onPressed: _onPressed,
      child: Text(
        'Login',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
