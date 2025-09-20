param(
  [switch]$ForceBackup = $false,
  [switch]$SkipAnalyze = $false
)

$ErrorActionPreference = "Stop"
$ROOT = Get-Location

function Say($msg, $color="Green") { Write-Host $msg -ForegroundColor $color }
function Ok($m){ Say "  [OK]  $m" "Green" }
function Fail($m){ Say "  [FAIL] $m" "Red" }
function Info($m){ Say "  [INFO] $m" "Cyan" }

function New-Dir($path){
  if (!(Test-Path $path)){ New-Item -ItemType Directory -Path $path -Force | Out-Null; Ok "Directorio creado: $path" }
  else { Info "Directorio existe: $path" }
}

function Backup-File($path){
  if (Test-Path $path){
    $ts = (Get-Date).ToString("yyyyMMdd_HHmmss")
    $bak = "$path.bak.$ts"
    Copy-Item $path $bak -Force
    Info "Backup: $bak"
  }
}

function Write-IfMissing($path, $content){
  if (!(Test-Path $path)){
    $content | Out-File -FilePath $path -Encoding UTF8 -Force
    Ok "Archivo creado: $path"
  } else {
    Info "Archivo existe: $path"
  }
}

# ============== 0) Pre-chequeos ==============
if (!(Test-Path "$ROOT/pubspec.yaml")) {
  Fail "No se encontró pubspec.yaml en $ROOT. Corre el script desde la raíz del proyecto."
  exit 1
}

# ============== 1) Directorios ==============
$dirs = @(
  "lib/app",
  "lib/shared/widgets",
  "lib/shared/utils",
  "lib/shared/services",
  "lib/features/auth/data",
  "lib/features/auth/domain",
  "lib/features/auth/presentation",
  "lib/features/projects/data",
  "lib/features/projects/domain",
  "lib/features/projects/presentation",
  "lib/features/tasks/data",
  "lib/features/tasks/domain",
  "lib/features/tasks/presentation",
  "lib/features/pomodoro/data",
  "lib/features/pomodoro/domain",
  "lib/features/pomodoro/presentation"
)
$dirs | ForEach-Object { New-Dir $_ }

# .gitkeep para carpetas vacías
$dirs | ForEach-Object {
  $gitkeep = Join-Path $_ ".gitkeep"
  if (!(Test-Path $gitkeep)) { New-Item -ItemType File $gitkeep | Out-Null }
}

# ============== 2) Archivos base/stubs ==============
# (BACKUP si ForceBackup)
if ($ForceBackup) {
  @(
    "lib/app/app.dart","lib/app/router.dart","lib/app/theme.dart","lib/app/di.dart",
    "lib/main.dart",
    "lib/shared/services/supabase_service.dart",
    "lib/shared/services/sentry_service.dart"
  ) | ForEach-Object { if (Test-Path $_) { Backup-File $_ } }
}

# app/
Write-IfMissing "lib/app/app.dart" @"
import 'package:flutter/material.dart';
import 'router.dart';
import 'theme.dart';

class TimmrApp extends StatelessWidget {
  const TimmrApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Timmr',
      routerConfig: router,
      theme: buildTheme(),
    );
  }
}
"@

Write-IfMissing "lib/app/router.dart" @"
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
"@

Write-IfMissing "lib/app/theme.dart" @"
import 'package:flutter/material.dart';
ThemeData buildTheme() => ThemeData(
  colorSchemeSeed: const Color(0xFF3B82F6),
  useMaterial3: true,
);
"@

Write-IfMissing "lib/app/di.dart" @"
// Placeholder de inyección de dependencias.
// Aquí puedes registrar singletons, providers, etc.
class DI { DI._(); }
"@

# main.dart
Write-IfMissing "lib/main.dart" @"
import 'package:flutter/material.dart';
import 'shared/services/supabase_service.dart';
import 'shared/services/sentry_service.dart';
import 'shared/services/analytics_service.dart';
import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SentryService.init();     // --dart-define=SENTRY_DSN opcional
  await SupabaseService.init();   // --dart-define=SUPABASE_URL, SUPABASE_ANON_KEY
  await AnalyticsService.init();  // --dart-define=AMPLITUDE_API_KEY opcional
  runApp(const TimmrApp());
}
"@

# shared/services
Write-IfMissing "lib/shared/services/supabase_service.dart" @"
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> init() async {
    await Supabase.initialize(
      url: const String.fromEnvironment('SUPABASE_URL'),
      anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
      authOptions: const FlutterAuthClientOptions(authFlowType: AuthFlowType.pkce),
    );
  }
}
"@

Write-IfMissing "lib/shared/services/sentry_service.dart" @"
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:flutter/foundation.dart';

class SentryService {
  static Future<void> init() async {
    final dsn = const String.fromEnvironment('SENTRY_DSN', defaultValue: '');
    if (dsn.isEmpty) return;
    await SentryFlutter.init((o) {
      o.dsn = dsn;
      o.tracesSampleRate = kDebugMode ? 0.0 : 0.2;
    });
  }
}
"@

if (!(Test-Path "lib/shared/services/analytics_service.dart")) {
  Write-IfMissing "lib/shared/services/analytics_service.dart" @"
class AnalyticsService {
  static Future<void> init() async {}
  static Future<void> setUserId(String? id) async {}
  static Future<void> setUserProperties(Map<String, dynamic> p) async {}
  static Future<void> logEvent(String name, [Map<String, dynamic>? props]) async {}
  static Future<void> logScreen(String screen, [Map<String, dynamic>? extra]) async {}
  static Future<void> flush() async {}
  static Future<void> reset() async {}
}
"@
}

# features/auth
Write-IfMissing "lib/features/auth/data/auth_repository.dart" @"
class AuthRepository {
  Future<void> signIn(String email, String password) async {}
  Future<void> signOut() async {}
}
"@
Write-IfMissing "lib/features/auth/domain/entities.dart" @"
class UserProfile {
  final String id; final String? displayName;
  UserProfile(this.id, {this.displayName});
}
"@
Write-IfMissing "lib/features/auth/domain/usecases.dart" @"
// SignIn, SignOut, GetCurrentUser...
"@
Write-IfMissing "lib/features/auth/presentation/login_page.dart" @"
import 'package:flutter/material.dart';
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Login'))); 
}
"@
Write-IfMissing "lib/features/auth/presentation/signup_page.dart" @"
import 'package:flutter/material.dart';
class SignupPage extends StatelessWidget {
  const SignupPage({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Signup'))); 
}
"@
Write-IfMissing "lib/features/auth/presentation/profile_page.dart" @"
import 'package:flutter/material.dart';
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Profile'))); 
}
"@
Write-IfMissing "lib/features/auth/presentation/controllers.dart" @"
// Providers/Controllers (Riverpod) aquí...
"@

# features/projects
Write-IfMissing "lib/features/projects/data/projects_repository.dart" @"
class ProjectsRepository {
  Future<void> create(String name) async {}
  Future<List<Map<String, dynamic>>> list() async => [];
}
"@
Write-IfMissing "lib/features/projects/domain/entities.dart" @"
class Project {
  final String id; final String name;
  Project(this.id, this.name);
}
"@
Write-IfMissing "lib/features/projects/domain/usecases.dart" @"
// CreateProject, ListProjects...
"@
Write-IfMissing "lib/features/projects/presentation/projects_page.dart" @"
import 'package:flutter/material.dart';
class ProjectsPage extends StatelessWidget {
  const ProjectsPage({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Projects'))); 
}
"@
Write-IfMissing "lib/features/projects/presentation/project_form.dart" @"
import 'package:flutter/material.dart';
class ProjectForm extends StatelessWidget {
  const ProjectForm({super.key});
  @override
  Widget build(BuildContext context) => const Placeholder();
}
"@

# features/tasks
Write-IfMissing "lib/features/tasks/data/tasks_repository.dart" @"
class TasksRepository {
  Future<void> create(Map<String, dynamic> task) async {}
  Future<List<Map<String, dynamic>>> list(String projectId) async => [];
}
"@
Write-IfMissing "lib/features/tasks/domain/entities.dart" @"
class TaskItem {
  final String id; final String projectId; final String title;
  TaskItem(this.id, this.projectId, this.title);
}
"@
Write-IfMissing "lib/features/tasks/domain/usecases.dart" @"
// CreateTask, ListTasks, ToggleDone...
"@
Write-IfMissing "lib/features/tasks/presentation/tasks_page.dart" @"
import 'package:flutter/material.dart';
class TasksPage extends StatelessWidget {
  const TasksPage({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Tasks'))); 
}
"@
Write-IfMissing "lib/features/tasks/presentation/task_form.dart" @"
import 'package:flutter/material.dart';
class TaskForm extends StatelessWidget {
  const TaskForm({super.key});
  @override
  Widget build(BuildContext context) => const Placeholder();
}
"@
Write-IfMissing "lib/features/tasks/presentation/timeline_page.dart" @"
import 'package:flutter/material.dart';
class TimelinePage extends StatelessWidget {
  const TimelinePage({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Timeline'))); 
}
"@

# features/pomodoro
Write-IfMissing "lib/features/pomodoro/data/sessions_repository.dart" @"
class SessionsRepository {
  Future<void> addSession(Map<String, dynamic> s) async {}
  Future<List<Map<String, dynamic>>> listByTask(String taskId) async => [];
}
"@
Write-IfMissing "lib/features/pomodoro/domain/entities.dart" @"
class PomodoroSession {
  final String id; final int minutes; final String type;
  PomodoroSession(this.id, this.minutes, this.type);
}
"@
Write-IfMissing "lib/features/pomodoro/domain/usecases.dart" @"
// StartSession, EndSession...
"@
Write-IfMissing "lib/features/pomodoro/presentation/pomodoro_page.dart" @"
import 'package:flutter/material.dart';
class PomodoroPage extends StatelessWidget {
  const PomodoroPage({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Pomodoro'))); 
}
"@

# ============== 3) Lints mínimos (si no existe) ==============
if (!(Test-Path "analysis_options.yaml")) {
@"
include: package:flutter_lints/flutter.yaml

analyzer:
  exclude:
    - build/**
    - "**/*.g.dart"

linter:
  rules:
    always_declare_return_types: true
    prefer_final_locals: true
    avoid_print: true
    directives_ordering: true
"@ | Out-File -FilePath "analysis_options.yaml" -Encoding UTF8 -Force
  Ok "analysis_options.yaml creado"
} else { Info "analysis_options.yaml existe" }

# ============== 4) Checklist automática ==============
Say "`n=== CHECKLIST AUTOMÁTICA ===" "Yellow"

$checksOk = $true

# 4.1 Carpetas clave
$mustDirs = @("lib/app","lib/shared/services","lib/features/auth","lib/features/projects","lib/features/tasks","lib/features/pomodoro")
foreach($d in $mustDirs){
  if(Test-Path $d){ Ok "Existe carpeta: $d" } else { Fail "Falta carpeta: $d"; $checksOk=$false }
}

# 4.2 Archivos clave
$mustFiles = @(
  "lib/main.dart",
  "lib/app/app.dart","lib/app/router.dart","lib/app/theme.dart",
  "lib/shared/services/supabase_service.dart",
  "lib/shared/services/sentry_service.dart",
  "lib/shared/services/analytics_service.dart",
  "lib/features/projects/presentation/projects_page.dart",
  "lib/features/auth/presentation/login_page.dart"
)
foreach($f in $mustFiles){
  if(Test-Path $f){ Ok "Existe archivo: $f" } else { Fail "Falta archivo: $f"; $checksOk=$false }
}

# 4.3 Conteo de archivos
$filesCount = (Get-ChildItem lib -Recurse -File).Count
if($filesCount -ge 30){ Ok "Conteo de archivos en lib/ >= 30 ($filesCount)" } else { Fail "Pocos archivos en lib/ ($filesCount < 30)"; $checksOk=$false }

# 4.4 Flutter analyze (opcional)
if(-not $SkipAnalyze){
  Info "Ejecutando: flutter analyze (esto puede tardar)"
  $analyze = & flutter analyze 2>&1
  $exit = $LASTEXITCODE
  if($exit -eq 0){ Ok "flutter analyze sin errores" } else { Fail "flutter analyze reporta problemas (exit=$exit)"; Write-Host $analyze -ForegroundColor DarkYellow; $checksOk=$false }
} else {
  Info "Omitido flutter analyze por --SkipAnalyze"
}

# 4.5 Árbol final
Say "`nÁrbol de lib/:" "Cyan"
cmd /c "tree lib /F"

if($checksOk){ Say "`n✅ TODO OK: estructura creada y verificada." "Green" }
else { Say "`n❌ Hay pendientes. Revisa los [FAIL] arriba." "Red" }
