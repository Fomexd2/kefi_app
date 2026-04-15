# Kefi App — Setup

## 1. Instalar Flutter (si no lo tienes)
https://docs.flutter.dev/get-started/install/windows/mobile

Agrega Flutter al PATH y verifica:
```
flutter doctor
```

## 2. Crear el proyecto base
Desde la terminal, en tu Desktop:
```
flutter create kefi_app --org com.tudominio --platforms ios
cd kefi_app
```

## 3. Reemplazar archivos
Copia los archivos de esta carpeta dentro del proyecto creado:
- Reemplaza `lib/` completo
- Reemplaza `pubspec.yaml`
- Reemplaza `ios/Runner/Info.plist`

## 4. Instalar dependencias
```
flutter pub get
```

## 5. Correr la app (simulador iOS o dispositivo)
```
flutter run
```

## Para construir para App Store
```
flutter build ios --release
```
Luego abre `ios/Runner.xcworkspace` en Xcode y archiva.

---

## Estructura del proyecto

```
lib/
├── main.dart                    — entrada de la app
├── router.dart                  — navegación
├── theme/kefi_theme.dart        — colores, glass, tipografía
├── models/
│   ├── kefir_batch.dart         — modelo + Hive adapter + enums
│   └── ferment_stage.dart       — etapas + colores + labels
├── services/
│   ├── ferment_calculator.dart  — motor de cálculo de tiempo
│   ├── storage_service.dart     — persistencia Hive
│   └── notification_service.dart— alertas push iOS
├── providers/
│   └── batch_provider.dart      — estado Riverpod
├── screens/
│   ├── home_screen.dart         — pantalla principal
│   ├── new_batch_screen.dart    — formulario nuevo lote (2 pasos)
│   └── history_screen.dart      — historial de lotes
└── widgets/
    ├── glass_card.dart          — contenedor glassmorphism
    ├── status_ring.dart         — anillo de progreso
    ├── ratio_indicator.dart     — barra ratio granos/leche
    ├── timer_display.dart       — reloj HH:MM:SS
    ├── temp_preset_selector.dart— chips de temperatura
    └── location_toggle.dart     — toggle ambiente/refri
```
