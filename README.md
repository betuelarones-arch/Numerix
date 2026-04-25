# demo06

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
# Numerix
# 📱 Casio fx-991LA Plus Clone - Flutter

## 📝 Descripción del Proyecto (Entrega de Laboratorio)

El presente proyecto es una aplicación móvil desarrollada en **Flutter** que clona de manera visual y funcional la calculadora científica Casio fx-991LA Plus. El objetivo principal de este laboratorio es aplicar conceptos avanzados de desarrollo móvil, incluyendo el manejo de estado reactivo mediante la arquitectura `ChangeNotifier`, la creación de interfaces de usuario totalmente adaptables (Responsive UI) y la implementación de un analizador sintáctico (Parser) para la evaluación matemática estricta respetando la jerarquía de operaciones.

Se logró desacoplar por completo la capa de presentación (UI) de la capa lógica, garantizando un código modular, escalable y aplicando buenas prácticas de Ingeniería de Software.

---

## 🛠️ Parte 1: Funcionalidades de la Interfaz (UI/UX)

La vista de la aplicación fue construida utilizando un sistema de proporciones dinámicas, lo que asegura que la calculadora mantenga su integridad visual en cualquier dispositivo.

* **Diseño 100% Responsive:** Implementación de `Expanded`, `Flexible` y `FittedBox` para que los botones y la pantalla LCD se adapten automáticamente a diferentes tamaños de pantalla sin generar errores de desbordamiento (*Overflow*).
* **Soporte Multitema:** Botón integrado para alternar dinámicamente entre **Modo Claro** y **Modo Oscuro**, modificando la paleta de colores nativa mediante `ThemeData`.
* **Pantalla Científica Dual:** Display que muestra simultáneamente la expresión matemática completa en la parte superior y el resultado en la parte inferior, simulando el LCD real de Casio.
* **Soporte para Teclado Físico:** Uso de `KeyboardListener` y `FocusNode` para permitir el ingreso de operaciones matemáticas mediante teclados físicos (ideal para pruebas en emuladores de PC, Web o Tablets).

---

## 🧠 Parte 2: Lógica Matemática y Analizador Sintáctico

Toda la inteligencia de la calculadora reside en la clase `CalculatorState`, la cual procesa la entrada del usuario antes de evaluarla matemáticamente.

* **Traducción de Símbolos Visuales:** Uso de Expresiones Regulares (RegExp) para convertir caracteres visuales (como `×`, `÷`, `√`) a operadores que el motor matemático entiende (`*`, `/`, `sqrt`).
* **Multiplicación Implícita:** Capacidad de entender operaciones sin el signo de multiplicar, por ejemplo, convirtiendo `2(3)` en `2*(3)`.
* **Modo DEG / RAD:** Soporte completo para funciones trigonométricas (seno, coseno, tangente) con un conversor dinámico en tiempo real que inyecta un factor de `(pi/180)` cuando el usuario opera en grados (DEG).
* **Autocorrección de Sintaxis:** Cierre automático de paréntesis faltantes al final de la expresión matemática para evitar errores de evaluación por descuidos del usuario.
* **Precisión Flotante:** Limpieza de resultados decimales innecesarios (ej. mostrando `5` en lugar de `5.0`) y redondeo controlado a 8 decimales para mitigar la imprecisión inherente a la coma flotante en la computación.

---

## 🚀 Parte 3: Instalación y Ejecución

Para ejecutar este proyecto de manera local, asegúrate de tener el SDK de Flutter instalado en tu equipo y seguir estos pasos:

1. **Clonar/Abrir el repositorio:**
   Abre una terminal y posiciónate en la carpeta raíz del proyecto.

2. **Limpiar el entorno:**
   Es una buena práctica limpiar la caché de Flutter antes de compilar por primera vez.
   ```bash
   flutter clean
