# 🕒 timmr

**timmr** es una aplicación multiplataforma (Android, iOS, Web) enfocada en **gestión del tiempo y productividad**, desarrollada en **Flutter** con arquitectura **feature-first**.  
Incluye integración con **Supabase** (backend), **Sentry** (monitoreo de errores), **Amplitude** (analítica) y flujos de CI/CD en la nube con **Codemagic**.

---

## 🚀 Tecnologías principales

- **Flutter (Dart)** → App multiplataforma (Android, iOS, Web, Desktop).  
- **Arquitectura feature-first** → `data / domain / presentation`.  
- **Supabase** → Autenticación, PostgreSQL, Realtime.  
- **Sentry** → Monitoreo de errores y rendimiento.  
- **Amplitude** → Métricas y analítica de usuarios.  
- **GitHub + Codemagic** → Control de versiones + CI/CD en la nube.  

---

## 🗂️ Estructura del proyecto

```
lib/
  app/              # router, theme, configuración global
  features/
    auth/           # autenticación (data/domain/presentation)
    home/           # pantallas principales
  shared/
    services/       # supabase, analytics, error service
    widgets/        # componentes reutilizables
    utils/          # helpers y utilidades
    state/          # providers / riverpod (estado global)
  env.dart          # lee variables con --dart-define
  main.dart         # punto de entrada de la app
```

---

## 🔧 Requisitos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) `3.x`
- [Android Studio](https://developer.android.com/studio) (SDK + AVD)
- VS Code con extensiones:
  - Flutter
  - Dart
  - GitLens
  - ChatGPT / Codex (opcional)

---

## ▶️ Cómo correr la app

**Web:**
```bash
flutter pub get
flutter run -d chrome
```

**Android (emulador):**
```bash
flutter devices        # listar dispositivos
flutter run -d <ID>    # ejemplo: emulator-5554
```

**Hot reload / restart dentro de flutter run:**
- `r` → hot reload
- `R` → hot restart
- `q` → salir

---

## 🌍 Variables de entorno

El proyecto utiliza `--dart-define` para inyectar claves de servicios externos:

- `SUPABASE_URL`
- `SUPABASE_ANON`
- `SENTRY_DSN`
- `AMPLITUDE_KEY`

Ejemplo de ejecución:
```bash
flutter run -d chrome   --dart-define=SUPABASE_URL=https://xxxx.supabase.co   --dart-define=SUPABASE_ANON=eyJ...   --dart-define=SENTRY_DSN=https://...   --dart-define=AMPLITUDE_KEY=xxx
```

---

## 📐 Arquitectura del stack

```
[Usuario: Android, iOS, Web]
         │
 Flutter App (Dart, VS Code)
 ┌─────────────┬─────────────┐
 │             │             │
 Presentation  Domain        Data
 (UI)          (Casos uso)   (Repos/APIs)
                               │
                               ▼
                        Supabase (BaaS)
                        - Auth
                        - PostgreSQL
                        - Realtime
                               │
        ┌───────────────┬──────┴───────────────┐
        ▼               ▼                      ▼
     Sentry         Amplitude            Codemagic (CI/CD)
 (errores/logs)   (analítica)         - Android / iOS / Web
```

---

## 📌 Estándares de desarrollo

- **Commits** → [Conventional Commits](https://www.conventionalcommits.org/):  
  - `feat:`, `fix:`, `chore:`, `docs:`, `refactor:`, `test:`  
  - Ejemplo: `feat(auth): login con magic link`

- **Branches**:  
  - `main` → estable  
  - `feature/*` → nuevas funcionalidades  
  - `fix/*` → correcciones  

- **Naming**:  
  - Archivos → `snake_case.dart` (`login_page.dart`)  
  - Clases → `PascalCase` (`LoginPage`)  
  - Variables → `camelCase` (`userName`)  

---

## 📈 Roadmap

- [x] Setup base en Flutter (Android/Web).  
- [x] Repo en GitHub conectado.  
- [ ] Integrar Supabase (auth + db).  
- [ ] Añadir Sentry para monitoreo.  
- [ ] Añadir Amplitude para analítica.  
- [ ] Configurar Codemagic (CI/CD Android/Web → iOS más adelante).  

---

## 📝 Licencia

Este proyecto es privado en fase inicial. La licencia se definirá antes del lanzamiento público.