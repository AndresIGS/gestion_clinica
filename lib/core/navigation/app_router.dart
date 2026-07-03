import 'package:flutter/material.dart';

/// Helpers para transiciones de navegación consistentes en toda la app.
class AppRouter {
  AppRouter._();

  /// Navega a [pantalla] con una transición de deslizamiento desde la derecha.
  static Route<T> slide<T>(Widget pantalla) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => pantalla,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1, 0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        final tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  /// Navega a [pantalla] con un fade suave.
  static Route<T> fade<T>(Widget pantalla) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => pantalla,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  /// Reemplaza la pila de navegación actual por [pantalla] usando slide.
  static void replace(BuildContext context, Widget pantalla) {
    Navigator.pushReplacement(context, slide(pantalla));
  }

  /// Navega a [pantalla] y elimina todas las rutas anteriores.
  static void navigateAndRemoveUntil(BuildContext context, Widget pantalla) {
    Navigator.pushAndRemoveUntil(
      context,
      slide(pantalla),
      (route) => false,
    );
  }
}
