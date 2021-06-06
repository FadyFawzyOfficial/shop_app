import 'package:flutter/material.dart';

// This for single routes on the fly creation.
class CustomRoute<T> extends MaterialPageRoute<T> {
  CustomRoute({WidgetBuilder builder, RouteSettings settings})
      : super(builder: builder, settings: settings);

  // The useful thing comes now.
  // You can add a buildTransitions method, it's part of MaterialPageRoute and
  // this controls how the page transition is animated and by overriding this,
  // we can set up our own animation.
  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    // Here insterad of returning super buildTransitions which would wrap
    // the default method provided by the parent class, we can first of all
    // check if settings is initail route which means this is the first route
    // that loads in the app, then I just want to return child which is the
    // page we're navigating to because I don't want to animate that first
    // page that's loading in. If it's not the initial route, so if we're
    // already in the app and we're jsut moving to a different screen, then
    // we can for example return a fade transition.
    if (settings.name == '/') return child;

    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
}

// This for a general theme which affects all route transitions.
class CustomPageTransitionBuilder extends PageTransitionsBuilder {
  @override
  Widget buildTransitions<T>(
      PageRoute<T> route,
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child) {
    if (route.settings.name == '/') return child;

    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
}
