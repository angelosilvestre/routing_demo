import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final routerDelegate = BeamerDelegate(
    guards: [authGuard],
    transitionDelegate: const NoAnimationTransitionDelegate(),
    locationBuilder: RoutesLocationBuilder(
      routes: {
        '/': (context, state, data) => const Home(),
        '/login': (context, state, data) => const Login(),
        '/products/:id': (context, state, data) => ProductDetails(
              id: state.pathParameters['id']!,
            ),
        '/cart': (context, state, data) => const Cart(),
        '/checkout': (context, state, data) => const Checkout(),
        '/orders/:id': (context, state, data) => OrderDetails(
              id: state.pathParameters['id']!,
            ),
        '/settings/payment': (context, state, data) => const Settings(selectedType: 'payment'),
        '/settings/addresses': (context, state, data) => const Settings(selectedType: 'addresses'),
      },
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Auth(
      data: AuthData(),
      child: MaterialApp.router(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        routeInformationParser: BeamerParser(),
        routerDelegate: routerDelegate,
      ),
    );
  }
}

final authGuard = BeamGuard(
  pathPatterns: [
    '/login',
    '/products/*',
    '/cart',
    '/',
  ],
  guardNonMatching: true,
  check: (context, location) => Auth.of(context).isSignedIn,
  beamToNamed: (origin, target) => '/login',
);

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
                context.beamToNamed('/products/12345');
              },
              child: const Text('Go to product details'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.beamToNamed('/settings/payment');
              },
              child: const Text('Go to settings'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.beamToNamed('/login');
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
                context.beamToNamed('/cart');
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
                context.beamToNamed('/checkout');
              },
              child: const Text('Checkout'),
            )
          ],
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
                context.beamToReplacementNamed('/orders/1234');
              },
              child: const Text('Place Order'),
            ),
          ],
        ),
      ),
    );
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
            context.beamToNamed('/');
          },
          child: const Text('Click to login'),
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
        context.beamToNamed('/settings/$type');
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
