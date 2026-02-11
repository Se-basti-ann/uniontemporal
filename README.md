# 📱 Unión Temporal - Management System

<div align="center">

**Plataforma integral de gestión para Uniones Temporales de Empresas**

[![Flutter](https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Desktop-blue)]()
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

[Características](#-características) • [Instalación](#-instalación) • [Uso](#-uso) • [Documentación](#-documentación)

</div>

---

## 📋 Tabla de Contenidos

- [Sobre el Proyecto](#-sobre-el-proyecto)
- [Características](#-características)
- [Tech Stack](#-tech-stack)
- [Requisitos](#-requisitos)
- [Instalación](#-instalación)
- [Configuración](#-configuración)
- [Uso](#-uso)
- [Estructura del Proyecto](#-estructura-del-proyecto)
- [Plataformas Soportadas](#-plataformas-soportadas)
- [Testing](#-testing)
- [Deployment](#-deployment)
- [Roadmap](#-roadmap)
- [Contribuir](#-contribuir)
- [Licencia](#-licencia)
- [Contacto](#-contacto)

---

## 🎯 Sobre el Proyecto

**Unión Temporal** es una aplicación multiplataforma desarrollada en Flutter para la gestión integral de Uniones Temporales de Empresas (UTE). El sistema facilita la administración, seguimiento y control de proyectos colaborativos entre múltiples empresas asociadas.

### ¿Qué es una Unión Temporal de Empresas?

Una Unión Temporal de Empresas es un tipo de colaboración empresarial donde dos o más compañías se unen temporalmente para ejecutar un proyecto específico, compartiendo recursos, riesgos y beneficios.

### Problema que Resuelve

- 📊 **Gestión Descentralizada**: Centraliza la información de todas las empresas participantes
- 💰 **Control Financiero**: Seguimiento detallado de ingresos, gastos y distribución de utilidades
- 📄 **Documentación**: Almacenamiento y gestión de contratos, acuerdos y documentos legales
- 👥 **Colaboración**: Facilita la comunicación entre las empresas asociadas
- 📈 **Reportes**: Generación automática de informes financieros y de gestión
- ⏱️ **Trazabilidad**: Seguimiento de actividades, tareas y responsabilidades

---

## ✨ Características

### Gestión de Proyectos

- 🏗️ **Dashboard de Proyectos**: Visualización de todos los proyectos activos de la UT
- 📊 **Seguimiento de Avance**: Monitoreo del progreso de cada proyecto
- 📅 **Cronogramas**: Gestión de hitos, entregas y fechas importantes
- 📁 **Gestión Documental**: Almacenamiento centralizado de documentos
- 🔔 **Notificaciones**: Alertas de vencimientos y actualizaciones importantes

### Administración Financiera

- 💵 **Control de Ingresos**: Registro y seguimiento de pagos recibidos
- 💸 **Control de Gastos**: Gestión de egresos y costos operacionales
- 📊 **Distribución de Utilidades**: Cálculo automático según participación de cada empresa
- 🧾 **Facturación**: Generación y seguimiento de facturas
- 📈 **Reportes Financieros**: Estados financieros, flujo de caja, balances

### Gestión de Empresas Asociadas

- 🏢 **Directorio de Empresas**: Información de cada empresa participante
- 👤 **Contactos**: Base de datos de representantes legales y contactos clave
- 📊 **Porcentajes de Participación**: Gestión de la distribución de responsabilidades
- 📄 **Documentos Legales**: Contratos, acuerdos y documentación jurídica
- ✅ **Validaciones**: Verificación de requisitos legales y administrativos

### Módulo de Usuarios y Permisos

- 👥 **Gestión de Usuarios**: Administración de accesos por empresa
- 🔐 **Roles y Permisos**: Control granular de acceso a funcionalidades
- 📝 **Auditoría**: Registro de todas las acciones realizadas en el sistema
- 🔒 **Seguridad**: Autenticación y autorización robusta

### Reportes e Informes

- 📊 **Dashboard Ejecutivo**: KPIs y métricas principales
- 📈 **Reportes Personalizados**: Generación de informes según necesidades
- 📉 **Análisis Comparativo**: Comparación entre proyectos y períodos
- 📧 **Exportación**: Exportar reportes a PDF, Excel, CSV
- 📱 **Reportes en Tiempo Real**: Actualización automática de datos

---

## 🛠️ Tech Stack

### Framework y Lenguaje

- **Flutter**: Framework UI multiplataforma (v3.x)
- **Dart**: Lenguaje de programación (v3.x)

### Arquitectura

- **Clean Architecture**: Separación de capas (presentation, domain, data)
- **BLoC Pattern**: Gestión de estado reactiva
- **Dependency Injection**: GetIt para inyección de dependencias
- **Repository Pattern**: Abstracción de fuentes de datos

### Librerías Principales

```yaml
dependencies:
  flutter_bloc: ^8.1.0           # State management
  get_it: ^7.6.0                 # Dependency injection
  dio: ^5.3.0                    # HTTP client
  sqflite: ^2.3.0                # Local database
  shared_preferences: ^2.2.0     # Local storage
  flutter_secure_storage: ^9.0.0 # Secure storage
  freezed: ^2.4.0                # Code generation
  json_annotation: ^4.8.0        # JSON serialization
  pdf: ^3.10.0                   # PDF generation
  excel: ^4.0.0                  # Excel generation
  intl: ^0.18.0                  # Internationalization
```

### Plataformas

- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Windows
- ✅ macOS
- ✅ Linux

---

## 📋 Requisitos

### Herramientas Necesarias

- **Flutter SDK**: ≥ 3.0.0
- **Dart SDK**: ≥ 3.0.0
- **Android Studio** o **VS Code** con extensiones de Flutter
- **Xcode** (para desarrollo iOS/macOS)
- **Android SDK** (para desarrollo Android)

### Verificar Instalación

```bash
flutter doctor -v
```

---

## 📦 Instalación

### 1. Clonar el Repositorio

```bash
git clone https://github.com/Se-basti-ann/uniontemporal.git
cd uniontemporal
```

### 2. Instalar Dependencias

```bash
flutter pub get
```

### 3. Generar Código (si aplica)

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 4. Verificar Dispositivos Disponibles

```bash
flutter devices
```

### 5. Ejecutar la Aplicación

```bash
# En modo debug
flutter run

# En un dispositivo específico
flutter run -d <device_id>

# En modo release
flutter run --release
```

---

## ⚙️ Configuración

### Variables de Entorno

Crea un archivo `lib/config/env.dart`:

```dart
class Environment {
  static const String apiUrl = 'https://api.uniontemporal.com';
  static const String apiKey = 'your_api_key_here';
  static const String appName = 'Unión Temporal';
  static const String version = '1.0.0';
}
```

### Configuración de Base de Datos

```dart
// lib/config/database_config.dart
class DatabaseConfig {
  static const String databaseName = 'union_temporal.db';
  static const int databaseVersion = 1;
  
  // Tablas
  static const String tableProjects = 'projects';
  static const String tableCompanies = 'companies';
  static const String tableTransactions = 'transactions';
}
```

### Firebase (Opcional)

Si usas Firebase para notificaciones o analytics:

1. Descarga `google-services.json` (Android) y `GoogleService-Info.plist` (iOS)
2. Colócalos en las carpetas correspondientes
3. Configura Firebase en `lib/config/firebase_config.dart`

---

## 🚀 Uso

### Inicio de Sesión

```dart
// Ejemplo de autenticación
final authService = GetIt.instance<AuthService>();
await authService.login(
  email: 'usuario@empresa.com',
  password: 'contraseña'
);
```

### Crear Nuevo Proyecto

```dart
// Ejemplo de creación de proyecto
final projectService = GetIt.instance<ProjectService>();
await projectService.createProject(
  name: 'Proyecto ABC',
  description: 'Descripción del proyecto',
  companies: ['Empresa A', 'Empresa B'],
  startDate: DateTime.now(),
  endDate: DateTime.now().add(Duration(days: 365)),
);
```

### Generar Reporte

```dart
// Ejemplo de generación de reporte PDF
final reportService = GetIt.instance<ReportService>();
final pdfFile = await reportService.generateFinancialReport(
  projectId: 'project_123',
  startDate: DateTime(2024, 1, 1),
  endDate: DateTime(2024, 12, 31),
);
```

---

## 📁 Estructura del Proyecto

```
uniontemporal/
├── android/                 # Código específico Android
├── ios/                     # Código específico iOS
├── web/                     # Código específico Web
├── windows/                 # Código específico Windows
├── macos/                   # Código específico macOS
├── linux/                   # Código específico Linux
├── assets/                  # Recursos (imágenes, fuentes, etc.)
│   ├── images/
│   ├── fonts/
│   └── icons/
├── lib/
│   ├── config/             # Configuraciones de la app
│   ├── core/               # Utilidades y helpers core
│   │   ├── constants/
│   │   ├── errors/
│   │   ├── utils/
│   │   └── extensions/
│   ├── features/           # Módulos por funcionalidad
│   │   ├── auth/
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   ├── projects/
│   │   ├── finance/
│   │   ├── companies/
│   │   └── reports/
│   ├── shared/             # Widgets y componentes compartidos
│   │   ├── widgets/
│   │   ├── models/
│   │   └── services/
│   ├── routes/             # Configuración de rutas
│   ├── theme/              # Temas y estilos
│   └── main.dart           # Entry point
├── test/                   # Tests unitarios
├── integration_test/       # Tests de integración
├── .gitignore
├── pubspec.yaml           # Dependencias del proyecto
├── analysis_options.yaml  # Reglas de análisis estático
└── README.md
```

---

## 🖥️ Plataformas Soportadas

### Android

```bash
flutter build apk --release
flutter build appbundle --release
```

### iOS

```bash
flutter build ios --release
```

### Web

```bash
flutter build web --release
```

### Desktop

```bash
# Windows
flutter build windows --release

# macOS
flutter build macos --release

# Linux
flutter build linux --release
```

---

## 🧪 Testing

### Tests Unitarios

```bash
flutter test
```

### Tests con Cobertura

```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

### Tests de Integración

```bash
flutter test integration_test
```

---

## 📤 Deployment

### Android (Google Play)

1. Configurar firma de la app en `android/app/build.gradle`
2. Crear keystore: `keytool -genkey -v -keystore ~/key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias key`
3. Configurar `android/key.properties`
4. Build: `flutter build appbundle --release`
5. Subir a Google Play Console

### iOS (App Store)

1. Configurar certificados en Apple Developer
2. Configurar en Xcode (Signing & Capabilities)
3. Build: `flutter build ios --release`
4. Usar Xcode para subir a App Store Connect

### Web

```bash
flutter build web --release
# Deploy a Firebase Hosting, Vercel, Netlify, etc.
```

---

## 🗺️ Roadmap

### Versión 1.0 (Actual)

- [x] Sistema de autenticación
- [x] Gestión de proyectos básica
- [x] Control financiero
- [x] Reportes básicos
- [x] Multi-plataforma (Android, iOS, Web)

### Versión 2.0 (Próxima)

- [ ] Integración con sistemas contables
- [ ] Firma digital de documentos
- [ ] Chat en tiempo real entre empresas
- [ ] Dashboard predictivo con IA
- [ ] App móvil offline-first
- [ ] Integración con bancos (APIs bancarias)

### Versión 3.0 (Futuro)

- [ ] Blockchain para trazabilidad de transacciones
- [ ] OCR para digitalización de documentos
- [ ] Machine Learning para detección de fraudes
- [ ] API pública para integraciones
- [ ] Multi-idioma (ES, EN, PT)

---

## 🤝 Contribuir

¡Las contribuciones son bienvenidas!

### Proceso de Contribución

1. **Fork** el proyecto
2. **Crea una rama** para tu feature (`git checkout -b feature/AmazingFeature`)
3. **Commit** tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. **Push** a la rama (`git push origin feature/AmazingFeature`)
5. **Abre un Pull Request**

### Guías de Estilo

- Seguir las [Dart style guidelines](https://dart.dev/guides/language/effective-dart/style)
- Usar análisis estático: `flutter analyze`
- Formatear código: `dart format .`
- Escribir tests para nuevas funcionalidades
- Documentar funciones públicas

---

## 📝 Licencia

Distribuido bajo la Licencia MIT. Ver `LICENSE` para más información.

---

## 👤 Contacto

**Sebastian Rodriguez Poveda**

- 🐙 GitHub: [@Se-basti-ann](https://github.com/Se-basti-ann)
- 💼 LinkedIn: [Sebastian Rodriguez Poveda](https://www.linkedin.com/in/sebastian-rodriguez-poveda-64a202157)
- 📧 Email: contact@sebastianrodriguez.dev

---

## 🙏 Agradecimientos

- [Flutter](https://flutter.dev/) - Framework multiplataforma
- [Dart](https://dart.dev/) - Lenguaje de programación
- [BLoC Library](https://bloclibrary.dev/) - State management
- [Flutter Community](https://flutter.dev/community) - Comunidad y recursos

---

## 📚 Recursos Adicionales

### Documentación Flutter

- [Documentación Oficial](https://docs.flutter.dev/)
- [Cookbook Flutter](https://docs.flutter.dev/cookbook)
- [Widget Catalog](https://docs.flutter.dev/development/ui/widgets)

### Tutoriales Recomendados

- [Flutter Codelabs](https://docs.flutter.dev/codelabs)
- [Flutter YouTube Channel](https://www.youtube.com/flutterdev)
- [Flutter Community Medium](https://medium.com/flutter-community)

---

<div align="center">

**⭐ Si este proyecto te resulta útil, considera darle una estrella!**

Desarrollado con ❤️ por [Sebastian Rodriguez](https://github.com/Se-basti-ann)

</div>
