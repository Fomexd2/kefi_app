# 🥛 Kefi — Control Inteligente de Kefir

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter" />
  <img src="https://img.shields.io/badge/Dart-3.x-blue?logo=dart" />
  <img src="https://img.shields.io/badge/Platform-iOS%20%7C%20Web%20%7C%20Windows-lightgrey" />
  <img src="https://img.shields.io/badge/Estado-En%20desarrollo-orange" />
</p>

> App móvil para fermentadores de kefir que quieren hacer un seguimiento preciso de sus lotes: tiempo estimado basado en ratio granos/leche y temperatura, alertas push cuando está listo, e historial completo.

---

## ✨ Funcionalidades

| Función | Descripción |
|---|---|
| ⏱ **Timer en tiempo real** | Cuenta el tiempo transcurrido y el estimado de fermentación |
| 🧮 **Cálculo científico** | Estima horas según ratio granos/leche y temperatura ambiente |
| 🌡 **Presets de temperatura** | Frío, Ideal, Cálido, Caliente, Refrigerador — con multiplicadores calibrados |
| 🫧 **Etapas de fermentación** | Iniciando → Fermentando → Casi listo → ¡Listo! → Sobre-fermentado |
| 🔔 **Notificaciones push** | Alertas al 85%, 100% y 115% del tiempo estimado |
| 🧊 **Modo refrigerador** | Soporte para fermentación lenta en frío (días) |
| 📋 **Historial** | Registro de todos los lotes anteriores con métricas |
| 💾 **Persistencia local** | Sin internet requerido — todo se guarda en el dispositivo |

---

## 📱 Pantallas

| Home | Nuevo Lote | Historial |
|---|---|---|
| Lotes activos con anillo de progreso y timer | Formulario en 2 pasos con cálculo en tiempo real | Todos los lotes completados con filtros |

---

## 🧮 Motor de Cálculo

El tiempo de fermentación se calcula con:

```
base_hours = 28 - (ratio - 2) × 1.875   → clamp [8h, 40h]
multiplier = preset.multiplier           → o 22 / tempC para temperatura custom
estimated  = base_hours × multiplier     → clamp [6h, 200h]
```

**Presets de temperatura:**

| Preset | Rango | Multiplicador |
|---|---|---|
| ❄️ Frío | < 18 °C | × 1.6 |
| ✅ Ideal | 18–22 °C | × 1.0 |
| ☀️ Cálido | 23–26 °C | × 0.75 |
| 🔥 Caliente | 27–30 °C | × 0.60 |
| 🧊 Refrigerador | 4–8 °C | × 5.5 |

---

## 🏗 Arquitectura

```
lib/
├── main.dart                     — entrada, inicialización, MaterialApp
├── router.dart                   — rutas con GoRouter
├── theme/
│   └── kefi_theme.dart           — colores, glassmorphism, tipografía Nunito
├── models/
│   ├── kefir_batch.dart          — modelo KefirBatch + Hive adapter + enums
│   └── ferment_stage.dart        — etapas de fermentación + colores + labels
├── services/
│   ├── ferment_calculator.dart   — motor de cálculo de tiempo
│   ├── storage_service.dart      — persistencia Hive
│   └── notification_service.dart — notificaciones push iOS
├── providers/
│   └── batch_provider.dart       — estado global con Riverpod
├── screens/
│   ├── home_screen.dart          — pantalla principal con lotes activos
│   ├── new_batch_screen.dart     — formulario nuevo lote (2 pasos)
│   └── history_screen.dart       — historial de lotes completados
└── widgets/
    ├── glass_card.dart           — contenedor glassmorphism reutilizable
    ├── status_ring.dart          — anillo de progreso animado
    ├── ratio_indicator.dart      — barra visual ratio granos/leche
    ├── timer_display.dart        — reloj HH:MM:SS en tiempo real
    ├── temp_preset_selector.dart — chips de selección de temperatura
    └── location_toggle.dart      — toggle ambiente / refrigerador
```

---

## 🛠 Stack Tecnológico

| Paquete | Uso |
|---|---|
| `flutter_riverpod` | Estado global reactivo |
| `hive_flutter` | Base de datos local sin SQL |
| `go_router` | Navegación declarativa |
| `flutter_local_notifications` | Notificaciones push locales |
| `google_fonts` | Tipografía Nunito |
| `intl` | Formateo de fechas en español |
| `timezone` | Zonas horarias para notificaciones |
| `uuid` | IDs únicos para cada lote |

---

## 🚀 Instalación

### Requisitos
- Flutter 3.x (`flutter --version`)
- Dart 3.x
- Para iOS: macOS con Xcode 15+
- Para Android: Android Studio con SDK 21+

### Pasos

```bash
# 1. Clonar el repositorio
git clone https://github.com/TU_USUARIO/kefi_app.git
cd kefi_app

# 2. Instalar dependencias
flutter pub get

# 3. Correr en el dispositivo conectado
flutter run

# 4. Correr en Chrome (desarrollo web)
flutter run -d chrome

# 5. Correr en Windows Desktop
# Primero activa Modo Desarrollador en Configuración → Sistema → Para desarrolladores
flutter run -d windows
```

### Build para producción

```bash
# iOS (requiere macOS + Xcode)
flutter build ios --release
# Luego abre ios/Runner.xcworkspace en Xcode y archiva

# Android
flutter build apk --release

# Web
flutter build web --release
```

---

## 📋 Pendientes (Roadmap)

### 🔴 Alta prioridad
- [ ] **Soporte Android** — agregar configuración nativa Android (`flutter create --platforms=android .`)
- [ ] **Notificaciones Android** — el `NotificationService` actual solo tiene configuración iOS/Darwin
- [ ] **Pantalla de detalle de lote** — tap en un lote activo debería abrir vista detallada con toda la info
- [ ] **Adaptador Hive con `build_runner`** — migrar de adaptador manual a generado con `@HiveType`/`@HiveField`

### 🟡 Media prioridad
- [ ] **Editar lote activo** — cambiar temperatura o ubicación de un lote en curso
- [ ] **Múltiples lotes simultáneos** — soporte para fermentar varios lotes al mismo tiempo
- [ ] **Estadísticas** — dashboard con lotes totales, ratio promedio, temperatura más usada
- [ ] **Exportar historial** — CSV o PDF con todos los lotes
- [ ] **Tema oscuro** — dark mode respetando el glassmorphism azul/morado
- [ ] **Modo tablet / iPad** — layouts adaptativos para pantallas grandes

### 🟢 Mejoras técnicas
- [ ] **Reemplazar `withOpacity()`** — migrar a `.withValues()` (deprecado en Flutter 3.27+)
- [ ] **Tests unitarios** — cubrir `FermentCalculator` y `KefirBatch`
- [ ] **Tests de widget** — smoke tests para las 3 pantallas principales
- [ ] **CI/CD con Codemagic** — build automático iOS en cada push a `main`
- [ ] **Flavor prod/dev** — separar entornos de desarrollo y producción

---

## 🎨 Diseño

La app usa **glassmorphism** con paleta azul-morado:

| Color | Hex | Uso |
|---|---|---|
| Kefi Blue | `#4B4FC4` | Color primario, gradiente |
| Kefi Purple | `#6B4FC4` | Gradiente secundario |
| Starting | `#9E9EBD` | Estado inicial |
| Fermenting | `#FFCA28` | Fermentando activo |
| Almost | `#FF9800` | Casi listo |
| Ready | `#66BB6A` | ¡Listo! |
| Over | `#EF5350` | Sobre-fermentado |

Fuente: **Nunito** (Google Fonts) — amigable y redonda, ideal para apps de bienestar.

---

## 📄 Licencia

MIT — úsalo, modifícalo, compártelo.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
