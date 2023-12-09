import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calculator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Calculator'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> calculationHistory = [];
  String expression = '0';
  String display = '0';
  void buttonPressed(String buttonText) {
    setState(() {
      if (expression.length == 30) {
        return;
      }
      buttonText = buttonText.replaceAll('xʸ', '^');
      String input = buttonText
          .replaceAll('÷', '/')
          .replaceAll('×', '*')
          .replaceAll(',', '.');
      if (expression == '-' && '+*/^'.contains(input)){
        expression = "0$input";
        display = "0$buttonText";
        return;
      }
      if (expression == '0' && input == '-') {
        expression = input;
        display = buttonText;
        return;
      }
      if('*/^'.contains(expression[expression.length - 1]) && input == '-') {
        expression += input;
        display += input;
        return;
      }

      if (expression.endsWith(input) && input == '.') {
        return;
      }

      if (expression == '0' && input == '.') {
        expression += input;
        display += buttonText;
        return;
      }

      if ('+-*/^'.contains(expression[expression.length - 1]) && input == '.') {
        expression += '0';
        display += '0';
      }

      if (('+-*/^'.contains(expression[expression.length - 1]) ||
              expression[expression.length - 1].contains('.')) &&
          '+-*/^'.contains(input)) {
        expression = expression.substring(0, expression.length - 1);
        display = display.substring(0, display.length - 1);
        if('+-*/^'.contains(expression[expression.length - 1])){
          expression = expression.substring(0, expression.length - 1);
          display = display.substring(0, display.length - 1);
        }
        if (expression == '') {
          expression = '0';
          display = '0';
        }
      }

      if (buttonText == '0' && (expression == '0' || expression == '-0')) {
        return;
      } else if ((expression == '0' || expression == '-0') && !'+-*/^'.contains(input)) {
        expression = input;
        display = '';
      } else {
        expression += input;
      }

      display += buttonText;
    });
  }
  void clearDisplay() {
    setState(() {
      expression = '0';
      display = '0';
    });
  }
  void calculate() {
    Parser p = Parser();
    try {
      Expression exp = p.parse(expression);
      ContextModel cm = ContextModel();
      double result = exp.evaluate(EvaluationType.REAL, cm);
      String resultString = result.toString();
      if (resultString.endsWith('.0')) {
        resultString = resultString.substring(0, resultString.length - 2);
      }
      if (calculationHistory.length == 8) {
        calculationHistory.removeAt(0);
      }
      if (result.isNaN || result.isInfinite) {
        throw Exception();
      } else {
        String res = resultString.replaceAll('.', ',');
        calculationHistory.add("$display=$res");
        expression = resultString;
        display = res;
      }
    } catch (e) {
      calculationHistory.add("$display=ОШИБКА");
      expression = '0';
      display = '0';
    }
    setState(() {});
  }
  void deleteCharacter() {
    setState(() {
      if (expression.isNotEmpty) {
        expression = expression.substring(0, expression.length - 1);
        if (expression == '') {
          expression = '0';
          display = '0';
        }
        else {
          display = display.substring(0, display.length - 1);
        }
      }
    });
  }
  void clearHistory() {
    setState(() {
      calculationHistory.clear();
    });
  }
  Widget buildButton(String buttonText, bool isOperator) {
    Color textColor = isOperator ? Colors.white : Colors.black;
    Color backgroundColor = !isOperator ? const Color.fromARGB(255, 207, 207, 207) : Colors.blue;
    return SizedBox(
      child: ElevatedButton(
        onPressed: () {
          if (buttonText == 'C') {
            clearDisplay();
          } else if (buttonText == '⌫') {
            deleteCharacter();
          } else if (buttonText == 'AC') {
            clearHistory();
          } else if (buttonText == '=') {
            calculate();
          } else {
            buttonPressed(buttonText);
          }
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 21.0),
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                10.0),
          ),
        ),
        child: Center(
          child: Text(
            buttonText,
            style: const TextStyle(
              fontSize: 28.0,
              overflow: TextOverflow.clip,
            ).copyWith(color: textColor),
          ),
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Row(
          children: [
            const SizedBox(width: 8),
            Text(
              widget.title,
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey,
                  width: 2.0,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 65,
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: ListView.builder(
                itemExtent: 30.0,
                reverse: true,
                itemCount: calculationHistory.length,
                itemBuilder: (BuildContext context, int index) {
                  final item = calculationHistory.reversed.toList()[index];
                  return ListTile(
                    title: Text(
                      item,
                      style: const TextStyle(color: Color.fromARGB(86, 0, 0, 0)),
                      textAlign: TextAlign.right,
                    ),
                  );
                },
              ),
            ),
          ),
          Expanded(
            flex: 35,
            child: Container(
              padding: const EdgeInsets.all(20.0),
              alignment: Alignment.bottomRight,
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey,
                    width: 2.0,
                  ),
                ),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  display,
                  style: const TextStyle(fontSize: 40.0),
                ),
              ),
            ),
          ),
          Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: buildButton('C', true),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: buildButton('⌫', true),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: buildButton('xʸ', true),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: buildButton('÷', true),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: buildButton('7', false),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: buildButton('8', false),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: buildButton('9', false),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: buildButton('×', true),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    top: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: buildButton('4', false),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: buildButton('5', false),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: buildButton('6', false),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: buildButton('-', true),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    top: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: buildButton('1', false),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: buildButton('2', false),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: buildButton('3', false),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: buildButton('+', true),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    top: 16.0, bottom: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: buildButton('AC', true),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: buildButton('0', false),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: buildButton(',', false),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: buildButton('=', true),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}