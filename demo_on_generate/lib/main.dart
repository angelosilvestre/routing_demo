import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Auth(
      data: AuthData(),
      child: Builder(builder: (context) {
        final routing = RouteGenerator(
          handlers: [
            // Public routes.
            PageHandler(
              pattern: '/',
              builder: (context, info) => const Home(),
            ),
            PageHandler(
              pattern: '/login',
              builder: (context, info) => const Login(),
            ),
            // TODO: templates for parameter extraction.
            PageHandler(
              pattern: '/products/1234',
              builder: (context, info) => const ProductDetails(id: '1234'),
            ),
            PageHandler(
              pattern: '/cart',
              builder: (context, info) => const Cart(),
            ),

            AuthGuard(),

            // Protected routes.
            PageHandler(
              pattern: '/checkout',
              builder: (context, info) => const Checkout(),
            ),

            // TODO: templates for parameter extraction.
            PageHandler(
              pattern: '/orders/1234',
              builder: (context, info) => const OrderDetails(id: '1234'),
            ),

            RedirectHandler(
              pattern: '/settings',
              destination: '/settings/payment',
            ),

            PageHandler(
              pattern: '/settings/payment',
              builder: (context, info) => const Settings(selectedType: 'payment'),
            ),

            PageHandler(
              pattern: '/settings/addresses',
              builder: (context, info) => const Settings(selectedType: 'addresses'),
            ),
          ],
        );
        return MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          onGenerateRoute: (settings) {
            return routing.generateRoute(context, settings);
          },
        );
      }),
    );
  }
}

/// This is for demonstrations only. NOT a complete solution.
class RouteGenerator {
  RouteGenerator({
    required this.handlers,
  });

  final List<RouteHandler> handlers;

  Route<dynamic> generateRoute(BuildContext context, RouteSettings settings) {
    final uri = settings.name != null //
        ? Uri.parse(settings.name!)
        : Uri.parse('/');

    RouteInfo info = RouteInfo(uri: uri);

    for (int i = 0; i < handlers.length; i++) {
      final result = handlers[i].handle(context, info);

      if (result is RedirectAction) {
        final newUri = Uri.parse(result.path);
        info = RouteInfo(uri: newUri);
        // Run the loop again.
        i = 0;
        continue;
      }

      if (result is PageAction) {
        return result.buildPage(info);
      }

      if (result is ContinueAction) {
        continue;
      }
    }
    // TODO: page not found
    return null!;
  }
}

class RouteInfo {
  RouteInfo({
    required this.uri,
  });
  final Uri uri;
}

class RouteAction {
  const RouteAction();
}

class ContinueAction extends RouteAction {
  const ContinueAction();
}

class RedirectAction extends RouteAction {
  const RedirectAction({
    required this.path,
  });
  final String path;
}

class PageAction extends RouteAction {
  PageAction({
    required this.builder,
  });

  final Widget Function(BuildContext context, RouteInfo info) builder;

  MaterialPageRoute buildPage(RouteInfo info) {
    return MaterialPageRoute(
      builder: (context) => builder(context, info),
      settings: RouteSettings(name: info.uri.path),
    );
  }
}

abstract class RouteHandler {
  RouteAction? handle(BuildContext context, RouteInfo info);
}

class AuthGuard extends RouteHandler {
  @override
  RouteAction? handle(BuildContext context, RouteInfo info) {
    if (!Auth.of(context).isSignedIn) {
      return const RedirectAction(path: '/login');
    }

    return null;
  }
}

class PageHandler extends RouteHandler {
  PageHandler({
    required this.pattern,
    required this.builder,
  });

  final String pattern;
  final Widget Function(BuildContext context, RouteInfo info) builder;

  @override
  RouteAction? handle(BuildContext context, RouteInfo info) {
    // TODO: handle pattern.
    if (info.uri.path == pattern) {
      return PageAction(builder: builder);
    }

    return null;
  }
}

class RedirectHandler extends RouteHandler {
  RedirectHandler({
    required this.pattern,
    required this.destination,
  });
  final String pattern;
  final String destination;

  @override
  RouteAction? handle(BuildContext context, RouteInfo info) {
    // TODO: handle pattern.
    if (info.uri.path == pattern) {
      return RedirectAction(path: destination);
    }

    return null;
  }
}

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Auth.of(context).isSignedIn = true;
            Navigator.of(context).pushNamed('/');
          },
          child: const Text('Click to login'),
        ),
      ),
    );
  }
}

class Checkout extends StatelessWidget {
  const Checkout({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Review your order'),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/orders/1234');
              },
              child: const Text('Place Order'),
            ),
          ],
        ),
      ),
    );
  }
}

class OrderDetails extends StatelessWidget {
  const OrderDetails({
    super.key,
    required this.id,
  });

  final String id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Details for Order #$id'),
      ),
    );
  }
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Home'),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/products/1234');
              },
              child: const Text('Go to product details'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/settings');
              },
              child: const Text('Go to settings'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/login');
              },
              child: const Text('Go to login'),
            )
          ],
        ),
      ),
    );
  }
}

class ProductDetails extends StatelessWidget {
  const ProductDetails({
    super.key,
    required this.id,
  });

  final String id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Details for product #$id'),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/cart');
              },
              child: const Text('Go to cart'),
            ),
          ],
        ),
      ),
    );
  }
}

class Cart extends StatelessWidget {
  const Cart({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('This is the shopping cart'),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/checkout');
              },
              child: const Text('Checkout'),
            )
          ],
        ),
      ),
    );
  }
}

class Settings extends StatelessWidget {
  const Settings({super.key, required this.selectedType});

  final String selectedType;

  Color _getTextColor(String title) {
    if (title == selectedType) {
      return Colors.blue;
    }

    return Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTextButton(
                context,
                text: 'Addresses',
                type: 'addresses',
              ),
              const SizedBox(height: 30),
              _buildTextButton(
                context,
                text: 'Payment',
                type: 'payment',
              ),
            ],
          ),
          Expanded(
            child: Center(child: _buildSubPage()),
          ),
        ],
      ),
    );
  }

  Widget _buildSubPage() {
    switch (selectedType) {
      case "addresses":
        return const SettingsChild(text: 'addresses');
      case "payment":
        return const SettingsChild(text: 'payment');
      default:
        return const Placeholder();
    }
  }

  Widget _buildTextButton(BuildContext context, {required String text, required String type}) {
    return TextButton(
      onPressed: () {
        Navigator.of(context).pushNamed('/settings/$type');
      },
      child: Text(
        text,
        style: TextStyle(
          color: _getTextColor(type),
        ),
      ),
    );
  }
}

class SettingsChild extends StatelessWidget {
  const SettingsChild({
    super.key,
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Current page: $text'),
        ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return const AlertDialog(
                  content: Text('This is a dialog'),
                );
              },
            );
          },
          child: const Text('Show Dialog'),
        )
      ],
    );
  }
}

class Auth extends InheritedWidget {
  const Auth({
    super.key,
    required this.data,
    required super.child,
  });

  static AuthData of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<Auth>()!.data;
  }

  final AuthData data;

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    // For simplicity.
    return true;
  }
}

class AuthData {
  AuthData({
    this.isSignedIn = false,
  });

  bool isSignedIn;
}
