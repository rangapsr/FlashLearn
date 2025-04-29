import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lite_rolling_switch/lite_rolling_switch.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:math';
import 'dart:async';
import 'package:number_inc_dec/number_inc_dec.dart';
import 'package:flutter_tts/flutter_tts.dart';

List<String> items = [];
int timerInterval = 3;
bool timerRunning = false;
bool savePressed = false;
bool endOfList = false;
bool hintShown = false;
int timerTemp = 0;
List<String> englishLetters = [];
List<String> englishLevel1 = [];
List<String> englishLevel2 = [];
List<String> englishAdvance = [];
List<String> mathsTables = [];
List<String> tamilLetters = [];
List<String> hindiLetters = [];

int selectedOption = 0;
Timer? _timer;
var index = 0;
List<String> cachedList = [];

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  loadTextFiles();
  runApp(const MyApp());
}

Future<void> loadAsset() async {
  String temp;

  temp = await rootBundle.loadString('assets/english_letters.txt');
  englishLetters = temp.toString().split('\n');

  temp = await rootBundle.loadString('assets/english_basics_1.txt');
  englishLevel1 = temp.toString().split('\n');

  temp = await rootBundle.loadString('assets/english_basics_2.txt');
  englishLevel2 = temp.toString().split('\n');

  temp = await rootBundle.loadString('assets/english_advance.txt');
  englishAdvance = temp.toString().split('\n');

  temp = await rootBundle.loadString('assets/tamil_letters.txt');
  tamilLetters = temp.toString().split('\n');

  temp = await rootBundle.loadString('assets/maths_tables.txt');
  mathsTables = temp.toString().split('\n');

  temp = await rootBundle.loadString('assets/hindi_letters.txt');
  hindiLetters = temp.toString().split('\n');
}

void loadTextFiles() {
  loadAsset();
}

initVariables() {
  index = 0;
  timerTemp = timerInterval;
  items = [];
  _stopTimer();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    initVariables();
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Flash It Learn It',
        initialRoute: '/homePage',
        routes: {
          '/homePage': (context) => MyHomePage(),
          '/cardPage': (context) => CardScreen(),
          '/settingsPage': (context) => SettingsPage(),
          '/aboutPage': (context) => AboutScreen(),
          '/privacyPage': (context) => PrivacyScreen(),
        },
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0x00000000),
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
          elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  fixedSize: const Size(250, 70),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  textStyle: const TextStyle(
                      fontSize: 30, fontWeight: FontWeight.bold),
                  foregroundColor: Colors.white)),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

void _stopTimer() {
  timerRunning = false;
  // Disable the button after it has been presse
  if (_timer != null) {
    // Log out the user if they're logged in, then cancel the timer.
    _timer!.cancel();
    _timer = null;
  }
}

class MyAppState extends ChangeNotifier {
  static var current = items[index];
  static var language = 1;

  void _startTimer(BuildContext context) {
    timerRunning = true;
    final Duration minDuration = Duration(seconds: timerInterval);
    // Disable the button after it has been presse
    _timer = Timer.periodic(minDuration, (_) {
      getNext(context);
      reDraw();
    });
  }

  // ↓ Add this.
  void reDraw() {
    notifyListeners();
  }

  void getNext(BuildContext context) {
    //  current = WordPair.random();
    final random = Random();
    if (items.length > 1) {
      items.remove(items[index]);
      index = random.nextInt(items.length);
    } else {
      showDialog(
          context: context,
          builder: (context) {
            _stopTimer();
            return AlertDialog(
              title: const Text('Completed!'),
              content:
                  const Text('You have completed all the words. Well done !'),
              actions: <Widget>[
                TextButton(
                  style: TextButton.styleFrom(
                    textStyle: Theme.of(context).textTheme.labelLarge,
                  ),
                  child: const Text('Ok'),
                  onPressed: () {
                    initVariables();
                    _navigateToHomeScreen(context);
                  },
                ),
              ],
            );
          });
    }
    current = items[index];
    notifyListeners();
  }

  void _navigateToHomeScreen(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/homePage',
      (Route<dynamic> route) => false,
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.teal, Colors.green])),
      child: Scaffold(
        drawer: const MyDrawer(),
        appBar: AppBar(
            title: const Text('Welcome'),
            flexibleSpace: const Image(
              image: AssetImage('assets/appbar_background_3.jpg'),
              fit: BoxFit.cover,
            ),
            backgroundColor: Colors.transparent),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                child: const Text(
                  'Alphabets',
                  style: TextStyle(fontSize: 18.0),
                ),
                onPressed: () {
                  initVariables();
                  items = List.from(englishLetters);
                  cachedList = List.from(englishLetters);
                  MyAppState.current = items[index];
                  MyAppState.language = 1;
                  _navigateToNextScreen(context);
                },
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                child: const Text(
                  'English Level 1',
                  style: TextStyle(fontSize: 18.0),
                ),
                onPressed: () {
                  initVariables();
                  items = List.from(englishLevel1);
                  cachedList = List.from(englishLevel1);
                  MyAppState.current = items[index];
                  MyAppState.language = 1;
                  _navigateToNextScreen(context);
                },
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                child: const Text(
                  'English Level 2',
                  style: TextStyle(fontSize: 18.0),
                ),
                onPressed: () {
                  initVariables();
                  items = List.from(englishLevel2);
                  cachedList = List.from(englishLevel2);
                  MyAppState.current = items[index];
                  MyAppState.language = 1;
                  _navigateToNextScreen(context);
                },
              ),

              const SizedBox(height: 15),
              ElevatedButton(
                child: const Text(
                  'Advanced',
                  style: TextStyle(fontSize: 18.0),
                ),
                onPressed: () {
                  initVariables();
                  items = List.from(englishAdvance);
                  cachedList = List.from(englishAdvance);
                  MyAppState.current = items[index];
                  MyAppState.language = 1;
                  _navigateToNextScreen(context);
                },
              ),              
              const SizedBox(height: 15),
              ElevatedButton(
                child: const Text(
                  'Tamil Letters',
                  style: TextStyle(fontSize: 18.0),
                ),
                onPressed: () {
                  initVariables();
                  items = List.from(tamilLetters);
                  cachedList = List.from(tamilLetters);
                  MyAppState.current = items[index];
                  MyAppState.language = 2;
                  _navigateToNextScreen(context);
                },
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                child: const Text(
                  'Maths Tables',
                  style: TextStyle(fontSize: 18.0),
                ),
                onPressed: () {
                  initVariables();
                  items = List.from(mathsTables);
                  cachedList = List.from(mathsTables);
                  MyAppState.current = items[index];
                  MyAppState.language = 0;
                  _navigateToNextScreen(context);
                },
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                child: const Text(
                  'Hindi Letters',
                  style: TextStyle(fontSize: 18.0),
                ),
                onPressed: () {
                  initVariables();
                  items = List.from(hindiLetters);
                  cachedList = List.from(hindiLetters);
                  MyAppState.current = items[index];
                  MyAppState.language = 3;
                  _navigateToNextScreen(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToNextScreen(BuildContext context) {
    Navigator.pushNamed(context, '/cardPage');
  }
}

class MyDrawer extends StatelessWidget {
  const MyDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.deepOrangeAccent,
      elevation: 6,
      child: Column(children: [
        const SizedBox(height: 100),
        ListTile(
          onTap: () {
            _navigateToHomeScreen(context);
          },
          leading: const Icon(Icons.home),
          title: const Text(
            'Home',
            style: TextStyle(
                fontSize: 20,
                color: Colors.black87,
                fontWeight: FontWeight.bold),
          ),
        ),
        ListTile(
          onTap: () {
            _navigateToSettingsScreen(context);
          },
          leading: const Icon(Icons.settings_rounded),
          title: const Text(
            'Settings',
            style: TextStyle(
                fontSize: 20,
                color: Colors.black87,
                fontWeight: FontWeight.bold),
          ),
        ),
        ListTile(
          onTap: () {
            _navigateToAboutScreen(context);
          },
          leading: const Icon(Icons.contact_page_rounded),
          title: const Text(
            'Contact',
            style: TextStyle(
                fontSize: 20,
                color: Colors.black87,
                fontWeight: FontWeight.bold),
          ),
        ),
        ListTile(
          onTap: () {
            _navigateToPrivacyScreen(context);
          },
          leading: const Icon(Icons.privacy_tip_rounded),
          title: const Text(
            'Privacy',
            style: TextStyle(
                fontSize: 20,
                color: Colors.black87,
                fontWeight: FontWeight.bold),
          ),
        ),
      ]),
    );
  }

  void _navigateToHomeScreen(BuildContext context) {
//    Navigator.of(context).pop(true);
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/homePage',
      (Route<dynamic> route) => false,
    );
    //
    // Navigator.pushNamed(context, '/homePage');
    // Navigator.of(context).push(MaterialPageRoute(
    //     maintainState: false, builder: (context) => MyHomePage()));
  }

  void _navigateToSettingsScreen(BuildContext context) {
    //Navigator.of(context).pop(true);
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/settingsPage',
      (Route<dynamic> route) => route.isFirst,
    );
    // Navigator.of(context).pop(true);
    // Navigator.pushNamed(context, '/homePage');
    // Navigator.of(context).push(MaterialPageRoute(
    //     maintainState: false, builder: (context) => SettingsPage()));
  }

  void _navigateToAboutScreen(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/aboutPage',
      (Route<dynamic> route) => route.isFirst,
    );
  }

  void _navigateToPrivacyScreen(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/privacyPage',
      (Route<dynamic> route) => route.isFirst,
    );
  }
}

class CardScreen extends StatelessWidget {
  @override
  FlutterTts ftts = FlutterTts();
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    //var output = appState.current; // ← Add this
    var output = MyAppState.current;
    Provider.of<MyAppState>(context, listen: false);
    return Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.blue, Colors.cyanAccent])),
        child: Scaffold(
          drawer: const MyDrawer(),
          appBar: AppBar(
              title: const Text('FlashIt LearnIt'),
              flexibleSpace: const Image(
                image: AssetImage('assets/appbar_background_3.jpg'),
                fit: BoxFit.cover,
              ),
              backgroundColor: Colors.transparent),
          backgroundColor: Colors.transparent,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                BigCard(output: output),
                const SizedBox(height: 70),
                IntrinsicWidth(
                    child: Row(children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        //your custom configuration
                        if (MyAppState.language == 1) {
                          await ftts.setLanguage("en-IN");
                          await ftts.setVolume(1.0);
                        } else if (MyAppState.language == 2) {
                          await ftts.setLanguage("ta-IN");
                          await ftts.setVolume(1.0);
                        } else if (MyAppState.language == 3) {
                          await ftts.setLanguage("hi-IN");
                          await ftts.setVolume(1.0);
                        } else {
                          await ftts.setLanguage("en-IN");
                          await ftts.setVolume(0.0);
                        }

                        await ftts.setSpeechRate(0.4); //speed of speech
                        //await ftts.setVolume(100.0); //volume of speech
                        //await ftts.setPitch(1); //pitc of sound

                        //play text to sp
                        var result = await ftts.speak(MyAppState.current);
                        if (result == 1) {
                          //speaking
                        } else {
                          //not speaking
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown,
                          fixedSize: Size(70, 50),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 5),
                          foregroundColor: Colors.lightBlueAccent),
                      icon: Icon(Icons.music_note_rounded,
                          size: 45, color: Colors.white),
                      label: Text(''),
                    ),
                  ),
                ])),
                const SizedBox(height: 30),
                IntrinsicWidth(
                  child: Row(
                    children: [
                      LiteRollingSwitch(
                        //initial value
                        value: false,
                        textOn: 'Next',
                        textOff: 'Next',
                        colorOn: const Color.fromARGB(255, 105, 218, 161),
                        colorOff: const Color.fromARGB(255, 105, 218, 161),
                        iconOn: Icons.skip_previous_rounded,
                        iconOff: Icons.skip_next_rounded,
                        textSize: 16.0,
                        onChanged: (bool state) {
                          appState
                              .getNext(context); // ← This instead of print().
                        },
                        onDoubleTap: () {},
                        onSwipe: () {},
                        onTap: () {},
                      ),
                      const SizedBox(width: 10),
                      LiteRollingSwitch(
                        //initial value
                        value: false,
                        textOn: 'On',
                        textOff: 'Off',
                        colorOn: Colors.greenAccent,
                        colorOff: Colors.redAccent,
                        iconOn: Icons.alarm_on,
                        iconOff: Icons.alarm_off,
                        textSize: 16.0,
                        onChanged: (bool state) {
                          if (state == false) {
                            timerRunning = false;
                            appState.reDraw();
                            _stopTimer();
                          } else {
                            timerRunning = true;
                            appState.reDraw();
                            appState._startTimer(context);
                          }
                          //Use it to manage the different states
                        },
                        onDoubleTap: () {},
                        onSwipe: () {},
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                const Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.all(5.0),
                    child: Text(
                        "Hint : Enable timer button to move to next words "
                        "automatically. In \"Settings\" page you can change the timer "
                        "interval.",
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ),
                )
              ],
            ),
          ),
          extendBody: true,
        ));
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.output,
  });

  final output;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
// ↓ Add this.
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
      fontSize: 70,
    );
    return Card(
      color: theme.colorScheme.primary, // ← And also this.
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Text(output.toString().trim(), style: style),
//        child: Text(items[_random.nextInt(items.length)], style: style),
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.red, Colors.pink])),
        child: Scaffold(
          drawer: const MyDrawer(),
          appBar: AppBar(
              title: const Text('Settings'),
              flexibleSpace: const Image(
                image: AssetImage('assets/appbar_background_3.jpg'),
                fit: BoxFit.cover,
              ),
              backgroundColor: Colors.transparent),
          backgroundColor: Colors.transparent,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                        style: TextStyle(
                            fontSize: 20.0,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                        "Timer interval (secs):"),
                    const SizedBox(
                      width: 20,
                    ),
                    SizedBox(
                      width: 80.0,
                      child: NumberInputWithIncrementDecrement(
                        controller: TextEditingController(),
                        isInt: true,
                        autovalidateMode: AutovalidateMode.always,
                        initialValue: timerInterval,
                        numberFieldDecoration:
                            const InputDecoration(fillColor: Colors.white),
                        decIconDecoration: const BoxDecoration(
                            shape: BoxShape.rectangle, color: Colors.white),
                        incIconDecoration: const BoxDecoration(
                            shape: BoxShape.rectangle, color: Colors.white),
                        min: 1,
                        max: 100,
                        onIncrement: (num value) {
                          timerTemp = value.toInt();
                        },
                        onDecrement: (num value) {
                          timerTemp = value.toInt();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    timerInterval = timerTemp;
                    timerTemp = timerInterval;
                    final snackBar = const SnackBar(
                      content: Text('Saved!'),
                    );
                    // Find the ScaffoldMessenger in the widget tree
                    // and use it to show a SnackBar.
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 20),
                      textStyle: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  icon: const Icon(Icons.save_as_sharp, size: 18),
                  label: const Text('Save'),
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  savePressed
                      ? 'Hello World'
                      : '', // When true, "Hello World" is shown, otherwhise nothing
                ),
              ],
            ),
          ),
        ));
  }
}

class AboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.red, Colors.pink])),
        // decoration: BoxDecoration(
        //     image: DecorationImage(
        //   image: AssetImage("assets/back_3.jpg"),
        //   fit: BoxFit.cover,
        // )),
        child: Scaffold(
            drawer: const MyDrawer(),
            appBar: AppBar(
                title: const Text('About'),
                flexibleSpace: const Image(
                  image: AssetImage('assets/appbar_background_3.jpg'),
                  fit: BoxFit.cover,
                ),
                backgroundColor: Colors.transparent),
            backgroundColor: Colors.transparent,
            body: Container(
              color: const Color.fromARGB(100, 22, 44, 33),
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  const LimitedBox(
                    maxHeight: 500,
                    maxWidth: 400,
                    child: Text(
                        style: TextStyle(
                          fontSize: 20.0,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        "Thank you so much for downloading our app! We created this app to provide parents with a free and easy-to-use tool that allows them to teach their kids new words using digital flashcards."),
                  ),
                  const SizedBox(height: 10),
                  const LimitedBox(
                    maxHeight: 500,
                    maxWidth: 400,
                    child: Text(
                        style: TextStyle(
                          fontSize: 20.0,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        "Our app is unique in that it has no ads, no in-app purchases, and requires no special permissions."),
                  ),
                  const SizedBox(height: 5),
                  const LimitedBox(
                    maxHeight: 500,
                    maxWidth: 400,
                    child: Text(
                        style: TextStyle(
                          fontSize: 20.0,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        "If you have any suggestions on how we can improve our app, please feel free to email us at akinavi.tech@gmail.com."),
                  ),
                ],
              ),
            )));
  }
}

class PrivacyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.red, Colors.pink])),
        child: Scaffold(
            drawer: const MyDrawer(),
            appBar: AppBar(
                title: const Text('Privacy'),
                flexibleSpace: const Image(
                  image: AssetImage('assets/appbar_background_3.jpg'),
                  fit: BoxFit.cover,
                ),
                backgroundColor: Colors.transparent),
            backgroundColor: Colors.transparent,
            body: Container(
              color: const Color.fromARGB(100, 22, 44, 33),
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(10),
              child: const Column(
                children: [
                  LimitedBox(
                    maxHeight: 400,
                    maxWidth: 400,
                    child: Text(
                        style: TextStyle(
                          fontSize: 18.0,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        "We do not collect any personal information from our users. Our app is an offline learning app, that doesn't require any account, and stores only field state on the user's device. We don't have any server and don't transfer the data anywhere, so it's fully offline."),
                  ),
                  SizedBox(height: 10),
                  LimitedBox(
                    maxHeight: 320,
                    maxWidth: 400,
                    child: Text(
                        style: TextStyle(
                          fontSize: 18.0,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        "If you have any questions or concerns about our privacy policy, please contact us at akinavi.tech@gmail.com. Our privacy policy can also be found at https://akinavitech.blogspot.com/2023/06/privacy-policy.html"),
                  ),
                ],
              ),
            )));
  }
}
