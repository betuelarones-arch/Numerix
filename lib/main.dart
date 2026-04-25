import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:math_expressions/math_expressions.dart';
import 'dart:math' as math;

void main() {
  runApp(const CasioApp());
}

class CalculatorState extends ChangeNotifier {
  String expression = '';
  String result = '';
  List<String> history = [];
  bool isDegree = true;
  bool isDarkMode = true;

  void toggleTheme() {
    isDarkMode = !isDarkMode;
    notifyListeners();
  }

  void toggleMode() {
    isDegree = !isDegree;
    notifyListeners();
  }

  void onInput(String text) {
    if (result == 'Error' || result == 'Infinity') {
      result = '';
    }
    expression += text;
    notifyListeners();
  }

  void delete() {
    if (expression.isNotEmpty) {
      expression = expression.substring(0, expression.length - 1);
      notifyListeners();
    }
  }

  void clear() {
    expression = '';
    result = '';
    notifyListeners();
  }

  void evaluate() {
    if (expression.trim().isEmpty) return;

    try {
      String evalExpr = expression
          .replaceAll('×', '*')
          .replaceAll('÷', '/')
          .replaceAll('π', math.pi.toString())
          .replaceAll('e', math.e.toString())
          .replaceAll('Ans', result.isNotEmpty ? result : '0');

      evalExpr = evalExpr.replaceAll('²', '^2');
      evalExpr = evalExpr.replaceAll('x⁻¹', '^(-1)');
      evalExpr = evalExpr.replaceAll('√', 'sqrt');

      evalExpr = evalExpr.replaceAllMapped(
        RegExp(r'(\d)\('),
        (m) => '${m[1]}*(',
      );
      evalExpr = evalExpr.replaceAllMapped(
        RegExp(r'\)(\d)'),
        (m) => ')*${m[1]}',
      );

      if (isDegree) {
        final radFactor = '*(pi/180)';
        evalExpr = evalExpr.replaceAllMapped(
          RegExp(r'sin\(([^)]+)\)'),
          (m) => 'sin((${m[1]})$radFactor)',
        );
        evalExpr = evalExpr.replaceAllMapped(
          RegExp(r'cos\(([^)]+)\)'),
          (m) => 'cos((${m[1]})$radFactor)',
        );
        evalExpr = evalExpr.replaceAllMapped(
          RegExp(r'tan\(([^)]+)\)'),
          (m) => 'tan((${m[1]})$radFactor)',
        );
      }

      int openP = evalExpr.split('(').length - 1;
      int closeP = evalExpr.split(')').length - 1;
      evalExpr += ')' * (openP - closeP);

      Parser p = Parser();
      Expression exp = p.parse(evalExpr);
      ContextModel cm = ContextModel();
      double evalResult = exp.evaluate(EvaluationType.REAL, cm);

      result = _formatResult(evalResult);
      history.add('$expression = $result');
      expression = '';
    } catch (e) {
      result = 'Error';
    }
    notifyListeners();
  }

  String _formatResult(double num) {
    if (num == num.roundToDouble()) {
      return num.toInt().toString();
    }
    return num.toStringAsFixed(
      8,
    ).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }
}

// ==========================================
// 2. ROOT APP Y THEME
// ==========================================
class CasioApp extends StatefulWidget {
  const CasioApp({super.key});

  @override
  State<CasioApp> createState() => _CasioAppState();
}

class _CasioAppState extends State<CasioApp> {
  final CalculatorState _state = CalculatorState();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _state,
      builder: (context, _) {
        return MaterialApp(
          title: 'Casio fx-991LA Pro',
          debugShowCheckedModeBanner: false,
          themeMode: _state.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          darkTheme: ThemeData.dark().copyWith(
            scaffoldBackgroundColor: const Color(0xFF1E1E1E),
            colorScheme: const ColorScheme.dark(
              surface: Color(0xFF1E1E1E),
              primary: Colors.white,
            ),
          ),
          theme: ThemeData.light().copyWith(
            scaffoldBackgroundColor: const Color(0xFFD4D4D4),
            colorScheme: const ColorScheme.light(
              surface: Color(0xFFD4D4D4),
              primary: Colors.black,
            ),
          ),
          home: CalculatorScreen(state: _state),
        );
      },
    );
  }
}

// ==========================================
// 3. PANTALLA PRINCIPAL (UI RESPONSIVE)
// ==========================================
class CalculatorScreen extends StatelessWidget {
  final CalculatorState state;
  final FocusNode _focusNode = FocusNode();

  CalculatorScreen({super.key, required this.state});

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      final key = event.logicalKey.keyLabel;
      if (RegExp(r'^[0-9\+\-\.\(\)]$').hasMatch(key)) state.onInput(key);
      if (key == '*') state.onInput('×');
      if (key == '/') state.onInput('÷');
      if (event.logicalKey == LogicalKeyboardKey.enter ||
          event.logicalKey == LogicalKeyboardKey.numpadEnter)
        state.evaluate();
      if (event.logicalKey == LogicalKeyboardKey.backspace) state.delete();
      if (event.logicalKey == LogicalKeyboardKey.escape) state.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    FocusScope.of(context).requestFocus(_focusNode);

    return KeyboardListener(
      focusNode: _focusNode,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 8.0,
            ),
            child: Column(
              children: [
                HeaderSection(state: state),
                const SizedBox(height: 10),
                // Asignamos proporciones (flex) para que se adapte a cualquier alto
                Expanded(flex: 3, child: DisplaySection(state: state)),
                const SizedBox(height: 15),
                TopControlsSection(state: state),
                const SizedBox(height: 10),
                Expanded(flex: 4, child: ScientificPad(state: state)),
                const SizedBox(height: 5),
                Expanded(flex: 6, child: NumericPad(state: state)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 4. WIDGETS MODULARES
// ==========================================

class HeaderSection extends StatelessWidget {
  final CalculatorState state;
  const HeaderSection({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.primary;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CASIO',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: textColor,
                ),
              ),
              Text(
                'fx-991LA PLUS',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: 10,
                  color: textColor.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: Icon(
                state.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                size: 20,
                color: textColor,
              ),
              onPressed: state.toggleTheme,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 10),
            Container(
              width: 70,
              height: 20,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF333333), Color(0xFF111111)],
                ),
                border: Border.all(color: Colors.black, width: 2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class DisplaySection extends StatelessWidget {
  final CalculatorState state;
  const DisplaySection({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFC4D6C6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black87, width: 3),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                state.isDegree ? 'D' : 'R',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.black,
                ),
              ),
              const Text(
                'Math ▲',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          // Expresión alineada a la izquierda y escalable
          Expanded(
            child: Align(
              alignment: Alignment.topLeft,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.topLeft,
                child: Text(
                  state.expression,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 24,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ),
          // Resultado escalable con FittedBox
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.bottomRight,
            child: Text(
              state.result,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TopControlsSection extends StatelessWidget {
  final CalculatorState state;
  const TopControlsSection({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildMiniBtn(
          'SHIFT',
          const Color(0xFFC7A94B),
          () => state.onInput('('),
        ),
        _buildMiniBtn(
          'ALPHA',
          const Color(0xFFC95B6A),
          () => state.onInput(')'),
        ),

        // Cruceta flexible
        Flexible(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 70, maxHeight: 40),
            decoration: BoxDecoration(
              color: const Color(0xFF333333),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.black54),
            ),
            child: const Center(
              child: Icon(
                Icons.control_camera,
                color: Colors.white54,
                size: 18,
              ),
            ),
          ),
        ),

        _buildMiniBtn(
          state.isDegree ? 'DEG' : 'RAD',
          Colors.grey,
          state.toggleMode,
        ),
        _buildMiniBtn('ON', Colors.grey, state.clear),
      ],
    );
  }

  Widget _buildMiniBtn(String label, Color color, VoidCallback onTap) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 30,
            height: 15,
            decoration: BoxDecoration(
              color: const Color(0xFF3B3B3B),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }
}

class ScientificPad extends StatelessWidget {
  final CalculatorState state;
  const ScientificPad({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final isDark = state.isDarkMode;
    final bgColor = isDark ? const Color(0xFF222222) : const Color(0xFF4A4A4A);
    final textColor = Colors.white;

    final buttons = [
      ['x⁻¹', '√(', 'x²', '^('],
      ['log(', 'ln(', 'sin(', 'cos('],
      ['tan(', 'π', 'e', 'E'],
    ];

    return Column(
      children: buttons.map((row) {
        return Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: row.map((btn) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: bgColor,
                      foregroundColor: textColor,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      elevation: 3,
                    ),
                    onPressed: () =>
                        btn == 'E' ? state.onInput('*10^') : state.onInput(btn),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        btn,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}

class NumericPad extends StatelessWidget {
  final CalculatorState state;
  const NumericPad({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final buttons = [
      ['7', '8', '9', 'DEL', 'AC'],
      ['4', '5', '6', '×', '÷'],
      ['1', '2', '3', '+', '-'],
      ['0', '.', 'Ans', '=', ''],
    ];

    return Column(
      children: buttons.map((row) {
        return Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: row.map((btnText) {
              if (btnText.isEmpty) return const Expanded(child: SizedBox());

              Color bgColor = _getBgColor(btnText, state.isDarkMode);
              Color fgColor = _getFgColor(btnText, state.isDarkMode);

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: bgColor,
                      foregroundColor: fgColor,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 4,
                    ),
                    onPressed: () {
                      if (btnText == 'AC')
                        state.clear();
                      else if (btnText == 'DEL')
                        state.delete();
                      else if (btnText == '=')
                        state.evaluate();
                      else
                        state.onInput(btnText);
                    },
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        btnText,
                        style: TextStyle(
                          fontSize: btnText == 'Ans' ? 16 : 22,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }

  Color _getBgColor(String text, bool isDark) {
    if (text == 'DEL' || text == 'AC') return const Color(0xFF88A944);
    if (['×', '÷', '+', '-', '='].contains(text))
      return isDark ? const Color(0xFF3A3A3A) : const Color(0xFFB0B3B8);
    return isDark ? const Color(0xFF4D4D4D) : const Color(0xFFEBEBEB);
  }

  Color _getFgColor(String text, bool isDark) {
    if (text == 'DEL' || text == 'AC') return Colors.white;
    return isDark ? Colors.white : Colors.black87;
  }
}
