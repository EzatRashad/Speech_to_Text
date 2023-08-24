import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

void main() => runApp(const SpeechToTextApp());

class SpeechToTextApp extends StatelessWidget {
  const SpeechToTextApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SpeechToTextPage(),
    );
  }
}

class SpeechToTextPage extends StatefulWidget {
  const SpeechToTextPage({super.key});

  @override
  _SpeechToTextPageState createState() => _SpeechToTextPageState();
}

class _SpeechToTextPageState extends State<SpeechToTextPage> {
  late stt.SpeechToText _speechToText;
  bool _isListening = false;
  String _text = 'Press the button and start speaking';
  List<Color> colorizeColors = [
    const Color(0xffD68438),
    const Color(0xff36846B),
    const Color(0xff4BB39A),
    const Color(0xffF1B24B),
    const Color(0xff36846B),
    const Color(0xff4BB39A),
  ];

  TextStyle colorizeTextStyle = const TextStyle(
    fontSize: 40.0,
    fontFamily: 'Caprasimo',
  );

  @override
  void initState() {
    super.initState();
    _speechToText = stt.SpeechToText();
  }

  void _startListening() async {
    if (!_isListening) {
      bool available = await _speechToText.initialize(
        onStatus: (status) {
          if (status == 'listening') {
            setState(() {
              _isListening = true;
            });
          } else if (status == 'notListening') {
            setState(() {
              _isListening = false;
            });
          }
        },
        onError: (error) {
          print('Error: $error');
          setState(() {
            _isListening = false;
          });
        },
      );

      if (available) {
        _speechToText.listen(
          onResult: (result) {
            setState(() {
              _text = result.recognizedWords;
            });
          },
        );
      }
    }
  }

  void _stopListening() {
    if (_isListening) {
      _speechToText.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              AnimatedTextKit(
                animatedTexts: [
                  ColorizeAnimatedText(
                    'Speech to Text',
                    textStyle: colorizeTextStyle,
                    colors: colorizeColors,
                  ),
                ],
                totalRepeatCount: 100,
                isRepeatingAnimation: true,
                displayFullTextOnTap: true,
                stopPauseOnTap: true,
              ),
              const SizedBox(height: 250.0),
              GestureDetector(
                onLongPress: () {
                  const snackBar = SnackBar(
                    content: Text('Text copied to clipboard'),
                  );
                  Clipboard.setData(ClipboardData(text: _text));
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                },
                child: Text(
                  _text,
                  style: const TextStyle(fontSize: 20, fontFamily: 'Poppins'),
                ),
              ),
              const SizedBox(height: 50.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffD68438),
                  textStyle:
                      const TextStyle(fontSize: 25, color: Color(0xff36846B)),
                  shape: const BeveledRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                ),
                onPressed: _isListening ? _stopListening : _startListening,
                child: Text(
                  _isListening ? 'Stop' : 'Start',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
