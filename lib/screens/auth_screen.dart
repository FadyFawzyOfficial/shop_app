import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/models/http_exception.dart';
import 'package:shop_app/providers/auth.dart';

enum AuthMode { Signup, Login }

class AuthScreen extends StatelessWidget {
  static const routeName = '/auth';

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    // final transformConfig = Matrix4.rotationZ(-8 * pi / 180);
    // transformConfig.translate(-10.0);
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(215, 117, 255, 1).withOpacity(0.5),
                  Color.fromRGBO(255, 188, 117, 1).withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0, 1],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              width: deviceSize.width,
              height: deviceSize.height,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Container(
                      margin: EdgeInsets.only(bottom: 20),
                      padding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 94),
                      transform: Matrix4.rotationZ(-8 * pi / 100)
                        ..translate(-10.0), // must be double value
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.deepOrange.shade900,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 8,
                            color: Colors.black26,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        'MyShop',
                        style: TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.normal,
                          fontFamily: 'Anton',
                          color:
                              Theme.of(context).accentTextTheme.headline6.color,
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: deviceSize.width > 600 ? 2 : 1,
                    child: AuthCard(),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  @override
  _AuthCardState createState() => _AuthCardState();
}

// And for this (Animation) to work, I just need to add a mixin, so we add the with
// keyword after extening the State and what I import here is the
// SingleTickerProviderStateMixin: it's simply adds a couple of methods and
// properties which is then implicitly used by vsync or by the animation
// controller to find out whether it's currently visible and so on.
// It also lets our widget know when a frame update is due -
// animations need that information to play smoothly.
class _AuthCardState extends State<AuthCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;
  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };
  var _isLoading = false;
  final _passwordController = TextEditingController();

  // For using AnimatedContainer we don't need the animation controller which
  // setup hare and we don't need the height animation.
  // Just leave them here because we will need them later,
  // But for AnimatedContainer, we don't need it.
  AnimationController _animationController;
  Animation<Size> _heightAnimation;

  @override
  void initState() {
    super.initState();
    // vsync basically is an argument where we give the animation controller
    // a pointer at the object, the widget in the end which it should watch
    // and only when that widget is really wisible on the screen, the animation
    // should play. So, this otpimizes performance because it ensures that we
    // really only animate what's visible to the user.
    // So I want to point at these widgets or at this state object which belongs
    // to a widget of course which has a build method.
    _animationController = AnimationController(
      vsync: this,
      // Duration for animations. You don't want to make this too long of course,
      // users shouldn't wait for that to finish.
      // It just should be long enough to show the user what happened without
      // blocking user input.
      duration: Duration(milliseconds: 500),
    );

    // Fot the animation itself, for the height animation is setup by the Tween class.
    // The Tween class gives you an object which in the end knows how to animate
    // between two values.
    // Tween itself doesn't give us an animation though, it just has information
    // on how to animate between 2 values to create an animated object based on
    // this you have to call animate() method, and now pass in an animation
    // object which will basiclly wrap itself around this information on what to
    // animate and the animation object describes how to animate it.
    _heightAnimation = Tween<Size>(
      begin: Size(double.infinity, 260),
      end: Size(double.infinity, 320),
    ).animate(
      // CurvedAnimation now also needs to be configured, you need to inform this
      // CurvedAnimation what its parent is and that simply is the controller
      // by which it should be controlled
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.linear,
      ),
    );

    // We also have to go to the place where we define the height animation,
    // so in the initState and there, we also now need to add a listener to call
    // setState() whenever this updates and it should update whenever it redraws
    // the screen. So here in the end, we just have an anonymous function in which
    // we call setState to set state, we can pass an empty update function because
    // there isn't really something I want to update, I just want to rerun the
    // build method to redraw the screen.
    // _heightAnimation.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    // We should call controller dispose to make sure that we clean the listener
    // ans so on.
    _animationController.dispose();
    super.dispose();
  }

  void _showErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('An Error Occurred!'),
        content: Text(errorMessage),
        actions: [
          FlatButton(
            child: Text('Okay'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState.validate())
      // Invalid!
      return;

    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });

    try {
      if (_authMode == AuthMode.Login)
        // Log user in
        await Provider.of<Auth>(context, listen: false).logIn(
          _authData['email'],
          _authData['password'],
        );
      else
        // Sign user up
        await Provider.of<Auth>(context, listen: false).signUp(
          _authData['email'],
          _authData['password'],
        );
    }
    // Filtering mechanism for different exceptions and showing different message
    // based on which error occurred.
    on HttpException catch (error) {
      String errorString = error.toString();
      var errorMessage = 'Authentication faild!';

      if (errorString.contains('EMAIL_EXISTS'))
        errorMessage = 'This email address is already in use!';
      else if (errorString.contains('EMAIL_NOT_FOUND'))
        errorMessage = 'Could not find a user with taht email.';
      else if (errorString.contains('INVALID_PASSWORD'))
        errorMessage = 'Invalid password!';
      else if (errorString.contains('INVALID_EMAIL'))
        errorMessage = 'This is not a valid email address.';
      else if (errorString.contains('WEAK_PASSWORD'))
        errorMessage = 'This password is too weak.';

      _showErrorDialog(errorMessage);
    } catch (error) {
      const errorMessage =
          'Could not authenticate you. Please try again later!';

      _showErrorDialog(errorMessage);
    }

    setState(() {
      _isLoading = false;
    });
  }

  // But of course we now need to kick off this animation and we do that in
  // switchAuthMode(). Instead of just switching the auth mode here, we want to
  // make user that when do go to the sign up mode, we increase the height and
  // therefore we should use our controller here and call forward,
  // forward starts the animation.
  // Now and once you're done, you want out play that back, so controller.reverse.
  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() => _authMode = AuthMode.Signup);
      _animationController.forward();
    } else {
      setState(() => _authMode = AuthMode.Login);
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 8,
      // For common things like changing the container,dimensions or chaning a
      // container look, in general Flutter has an even better built-in widget
      // ant that the AnimatedContainer.
      // How does animated container work? AnimatedContainer has all the heavy
      //lifting built-in, so efficiently running an animation and it automatically
      // transitions between changes in its configration.
      // Since the AnimdatedContainer controls the entire animation, you don't
      // even need your own controller there because it kicks off the animation
      // and reverses it on its own, basically whenever these values changes and
      // you just need to tell it over which duration it should animate.
      child: AnimatedContainer(
        duration: Duration(milliseconds: 500),
        curve: Curves.easeIn,
        // Go back to old height setup here where we actually switch this when
        // the auth mode changes.
        // When we go back to that, AnimatedContainer will not do the same normal
        // container does and make a hard switch between these values but instread,
        // it will automatically detect that that value changed and will smoothly
        // animate between the values and that does not just work fot height or
        // width but for things like padding and so on as well.
        height: _authMode == AuthMode.Signup ? 320 : 260,
        width: deviceSize.width * 0.75,
        constraints:
            BoxConstraints(minHeight: _authMode == AuthMode.Signup ? 320 : 260),
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'E-Mail'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value.isEmpty || !value.contains('@'))
                      return 'Invalid email!';
                    return null;
                  },
                  onSaved: (value) => _authData['email'] = value,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  controller: _passwordController,
                  validator: (value) {
                    if (value.isEmpty || value.length < 5)
                      return 'Password is too short!';
                    return null;
                  },
                  onSaved: (value) => _authData['password'] = value,
                ),
                if (_authMode == AuthMode.Signup)
                  TextFormField(
                    enabled: _authMode == AuthMode.Signup,
                    decoration: InputDecoration(labelText: 'Confirm Password'),
                    obscureText: true,
                    validator: _authMode == AuthMode.Signup
                        ? (value) {
                            return value != _passwordController.text
                                ? 'Passwords do not match!'
                                : null;
                          }
                        : null,
                  ),
                SizedBox(height: 20),
                _isLoading
                    ? CircularProgressIndicator()
                    : RaisedButton(
                        child: Text(
                            _authMode == AuthMode.Login ? 'LOGIN' : 'SIGN UP'),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        padding:
                            EdgeInsets.symmetric(horizontal: 30, vertical: 8),
                        color: Theme.of(context).primaryColor,
                        textColor:
                            Theme.of(context).primaryTextTheme.button.color,
                        onPressed: _submit,
                      ),
                FlatButton(
                  child: Text(
                      '${_authMode == AuthMode.Login ? 'SIGN UP' : 'LOGIN'} INSTEAD'),
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 4),
                  textColor: Theme.of(context).primaryColor,
                  // Basically just shrick the button a little bit.
                  // You could say, reduce the amount of surface you can hit with
                  // your finger to trigger that button, it will still be large
                  // enough but it simply makes it a bit smaller and look nicer.
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  onPressed: _switchAuthMode,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
