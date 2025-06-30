import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/splash/pages/splash_page.dart';
import '../features/onboarding/pages/onboarding_page.dart';
import '../features/auth/pages/login_page.dart';
import '../features/auth/pages/register_page.dart';
import '../features/auth/pages/forgot_password_page.dart';
import '../features/auth/pages/verify_email_page.dart';
import '../features/dashboard/pages/dashboard_page.dart';
import '../features/ai_analysis/pages/camera_page.dart';
import '../features/ai_analysis/pages/upload_page.dart';
import '../features/ai_analysis/pages/result_page.dart';
import '../features/ai_analysis/pages/batch_analysis_page.dart';
import '../features/certificate/pages/certificate_list_page.dart';
import '../features/certificate/pages/apply_certificate_page.dart';
import '../features/certificate/pages/certificate_detail_page.dart';
import '../features/tracking/pages/tracking_page.dart';
import '../features/tracking/pages/qr_scanner_page.dart';
import '../features/tracking/pages/timeline_page.dart';
import '../features/profile/pages/profile_page.dart';
import '../features/profile/pages/edit_profile_page.dart';
import '../features/settings/pages/settings_page.dart';
import '../features/settings/pages/language_settings_page.dart';
import '../features/settings/pages/notification_settings_page.dart';
import '../features/settings/pages/privacy_settings_page.dart';
import '../features/herbs/pages/herb_encyclopedia_page.dart';
import '../features/herbs/pages/herb_detail_page.dart';
import '../features/support/pages/help_page.dart';
import '../features/support/pages/contact_page.dart';
import '../core/providers/auth_provider.dart';
import '../core/providers/onboarding_provider.dart';
import '../shared/widgets/main_scaffold.dart';
import '../shared/widgets/error_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final hasSeenOnboarding = ref.watch(onboardingProvider);

  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final location = state.location;
      final isAuthenticated = authState.maybeWhen(
        authenticated: (_) => true,
        orElse: () => false,
      );
      final isLoading = authState.maybeWhen(
        loading: () => true,
        orElse: () => false,
      );
      if (isLoading && location == '/splash') return null;
      if (!hasSeenOnboarding && !location.startsWith('/onboarding') && location != '/splash') {
        return '/onboarding';
      }
      final isOnAuthPage = _isAuthPage(location);
      final isOnPublicPage = _isPublicPage(location);
      if (!isAuthenticated && !isOnAuthPage && !isOnPublicPage) {
        return '/auth/login';
      }
      if (isAuthenticated && isOnAuthPage) {
        return '/dashboard';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: '/auth/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/auth/register',
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/auth/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/auth/verify-email',
        name: 'verify-email',
        builder: (context, state) {
          final email = state.queryParams['email'] ?? '';
          return VerifyEmailPage(email: email);
        },
      ),
      ShellRoute(
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            name: 'dashboard',
            pageBuilder: (context, state) => _buildPageWithTransition(
              child: const DashboardPage(),
              state: state,
            ),
          ),
          GoRoute(
            path: '/analysis',
            name: 'analysis',
            redirect: (context, state) => '/analysis/camera',
          ),
          GoRoute(
            path: '/analysis/camera',
            name: 'camera',
            pageBuilder: (context, state) => _buildPageWithTransition(
              child: const CameraPage(),
              state: state,
            ),
          ),
          GoRoute(
            path: '/analysis/upload',
            name: 'upload',
            pageBuilder: (context, state) => _buildPageWithTransition(
              child: const UploadPage(),
              state: state,
            ),
          ),
          GoRoute(
            path: '/analysis/batch',
            name: 'batch-analysis',
            pageBuilder: (context, state) => _buildPageWithTransition(
              child: const BatchAnalysisPage(),
              state: state,
            ),
          ),
          GoRoute(
            path: '/certificates',
            name: 'certificates',
            pageBuilder: (context, state) => _buildPageWithTransition(
              child: const CertificateListPage(),
              state: state,
            ),
          ),
          GoRoute(
            path: '/tracking',
            name: 'tracking',
            pageBuilder: (context, state) => _buildPageWithTransition(
              child: const TrackingPage(),
              state: state,
            ),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            pageBuilder: (context, state) => _buildPageWithTransition(
              child: const ProfilePage(),
              state: state,
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/analysis/result',
        name: 'analysis-result',
        builder: (context, state) {
          final analysisData = state.extra as Map<String, dynamic>?;
          return AnalysisResultPage(data: analysisData);
        },
      ),
      GoRoute(
        path: '/certificates/apply',
        name: 'apply-certificate',
        builder: (context, state) => const ApplyCertificatePage(),
      ),
      GoRoute(
        path: '/certificates/:id',
        name: 'certificate-detail',
        builder: (context, state) {
          final certificateId = state.pathParameters['id']!;
          return CertificateDetailPage(certificateId: certificateId);
        },
      ),
      GoRoute(
        path: '/tracking/scanner',
        name: 'qr-scanner',
        builder: (context, state) => const QRScannerPage(),
      ),
      GoRoute(
        path: '/tracking/timeline/:code',
        name: 'tracking-timeline',
        builder: (context, state) {
          final trackingCode = state.pathParameters['code']!;
          return TimelinePage(trackingCode: trackingCode);
        },
      ),
      GoRoute(
        path: '/profile/edit',
        name: 'edit-profile',
        builder: (context, state) => const EditProfilePage(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsPage(),
        routes: [
          GoRoute(
            path: 'language',
            name: 'language-settings',
            builder: (context, state) => const LanguageSettingsPage(),
          ),
          GoRoute(
            path: 'notifications',
            name: 'notification-settings',
            builder: (context, state) => const NotificationSettingsPage(),
          ),
          GoRoute(
            path: 'privacy',
            name: 'privacy-settings',
            builder: (context, state) => const PrivacySettingsPage(),
          ),
        ],
      ),
      GoRoute(
        path: '/herbs',
        name: 'herb-encyclopedia',
        builder: (context, state) => const HerbEncyclopediaPage(),
      ),
      GoRoute(
        path: '/herbs/:id',
        name: 'herb-detail',
        builder: (context, state) {
          final herbId = state.pathParameters['id']!;
          return HerbDetailPage(herbId: herbId);
        },
      ),
      GoRoute(
        path: '/help',
        name: 'help',
        builder: (context, state) => const HelpPage(),
      ),
      GoRoute(
        path: '/contact',
        name: 'contact',
        builder: (context, state) => const ContactPage(),
      ),
    ],
    errorBuilder: (context, state) => ErrorPage(
      error: state.error.toString(),
      onRetry: () => context.go('/dashboard'),
    ),
  );
});

bool _isAuthPage(String location) => location.startsWith('/auth/');
bool _isPublicPage(String location) => ['/splash', '/onboarding', '/help'].contains(location);

Page<dynamic> _buildPageWithTransition({
  required Widget child,
  required GoRouterState state,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 200),
  );
}