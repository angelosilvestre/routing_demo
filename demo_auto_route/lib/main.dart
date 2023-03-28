import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
part 'main.gr.dart';

void main() {
  runApp(MyApp());
}

@AutoRouterConfig(replaceInRouteName: 'Screen,Route')
class AppRouter extends _$AppRouter {
  @override
  final List<AutoRoute> routes = [
    RedirectRoute(path: '/', redirectTo: '/home'),
    AutoRoute(page: HomeRoute.page),
    AutoRoute(page: LoginRoute.page),
    AutoRoute(page: ProductDetailsRoute.page),
    AutoRoute(page: CartRoute.page),
    AutoRoute(page: CheckoutRoute.page),
    AutoRoute(page: OrderDetailsRoute.page),
    RedirectRoute(path: '/settings', redirectTo: '/settings/payment'),
    AutoRoute(page: SettingsRoute.page),
  ];
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final _appRouter = AppRouter();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Demo',
      routerConfig: _appRouter.config(),
    );
  }
}

@RoutePage()
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
                context.router.navigate(ProductDetailsRoute(id: '1234'));
              },
              child: const Text('Go to product details'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.router.navigate(SettingsRoute(selectedType: 'payment'));
              },
              child: const Text('Go to settings'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.router.navigate(const LoginRoute());
              },
              child: const Text('Go to login'),
            )
          ],
        ),
      ),
    );
  }
}

@RoutePage()
class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({
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
                context.router.navigate(const CartRoute());
              },
              child: const Text('Go to cart'),
            ),
          ],
        ),
      ),
    );
  }
}

@RoutePage()
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Auth.of(context).isSignedIn = true;
            context.router.navigate(const HomeRoute());
          },
          child: const Text('Click to login'),
        ),
      ),
    );
  }
}

@RoutePage()
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

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
                context.router.navigate(const CheckoutRoute());
              },
              child: const Text('Checkout'),
            )
          ],
        ),
      ),
    );
  }
}

@RoutePage()
class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

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
                context.router.navigate(OrderDetailsRoute(id: '1234'));
              },
              child: const Text('Place Order'),
            ),
          ],
        ),
      ),
    );
  }
}

@RoutePage()
class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({
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

@RoutePage()
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.selectedType});

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
        context.router.navigate(SettingsRoute(selectedType: type));
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
