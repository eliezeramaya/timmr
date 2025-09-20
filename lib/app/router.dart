import 'package:go_router/go_router.dart';
import '../features/projects/presentation/projects_page.dart';
import '../features/auth/presentation/login_page.dart';

final router = GoRouter(
  initialLocation: '/projects',
  routes: [
    GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
    GoRoute(path: '/projects', builder: (_, __) => const ProjectsPage()),
  ],
);
