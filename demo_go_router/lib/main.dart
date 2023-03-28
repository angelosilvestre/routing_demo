import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return Auth(
      data: AuthData(),
      child: MaterialApp.router(
        title: 'Routing Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        routerConfig: _router,
      ),
    );
  }
}

String? authGuard(BuildContext context, GoRouterState state) {
  if (!Auth.of(context).isSignedIn) {
    return '/login';
  }

  // Don't redirect.
  return null;
}

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (BuildContext context, GoRouterState state) {
        return const NoTransitionPage(child: Home());
      },
    ),
    GoRoute(
      path: '/login',
      pageBuilder: (BuildContext context, GoRouterState state) {
        return const NoTransitionPage(child: Login());
      },
    ),
    GoRoute(
      path: '/products/:id',
      pageBuilder: (BuildContext context, GoRouterState state) {
        return NoTransitionPage(
          child: ProductDetails(
            id: state.params['id']!,
          ),
        );
      },
    ),
    GoRoute(
      path: '/cart',
      pageBuilder: (BuildContext context, GoRouterState state) {
        return const NoTransitionPage(child: Cart());
      },
    ),
    GoRoute(
      path: '/checkout',
      pageBuilder: (BuildContext context, GoRouterState state) {
        return const NoTransitionPage(child: Checkout());
      },
      redirect: authGuard,
    ),
    GoRoute(
      path: '/orders/:id',
      pageBuilder: (BuildContext context, GoRouterState state) {
        return NoTransitionPage(
          child: OrderDetails(
            id: state.params['id']!,
          ),
        );
      },
      redirect: authGuard,
    ),
    GoRoute(path: '/settings', redirect: (_, __) => '/settings/addresses'),
    GoRoute(
      path: '/settings/:type(addresses|payment)',
      pageBuilder: (BuildContext context, GoRouterState state) {
        return NoTransitionPage(
          child: Settings(
            selectedType: state.params['type']!,
          ),
        );
      },
      redirect: authGuard,
    ),
  ],
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
                context.go('/products/12345');
              },
              child: const Text('Go to product details'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.go('/settings');
              },
              child: const Text('Go to settings'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.go('/login');
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
                context.go('/cart');
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
                context.go('/checkout');
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
                context.go('/orders/1234');
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
            context.go('/');
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
        context.go('/settings/$type');
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
