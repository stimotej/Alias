import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'shared_prefs.dart';

class GameSetupPage extends StatefulWidget {

  @override
  _GameSetupPageState createState() => _GameSetupPageState();
}

List<String> languages = ['english', 'croatian'];

class _GameSetupPageState extends State<GameSetupPage> {

  @override
  void initState() {
    super.initState();
    _getGameSetup();
  }

  @override
  void dispose() {
    scoreController.dispose();
    timeLimitController.dispose();
    super.dispose();
  }

  var _score;
  var _timeLimit;
  var _language;

  SharedPref sharedPref = SharedPref();
  final _formKey = GlobalKey<FormState>();

  final scoreController = TextEditingController();
  final timeLimitController = TextEditingController();

  _getGameSetup() async {
    try {
      int scoreLoaded = await sharedPref.readScore();
      int timeLimitLoaded = await sharedPref.readTimeLimit();
      var languageLoaded = await sharedPref.readLanguage();
      setState(() {
        _score = scoreLoaded;
        _timeLimit = timeLimitLoaded;
        _language = languageLoaded;
        scoreController.text = scoreLoaded.toString();
        timeLimitController.text = timeLimitLoaded.toString();
      });
    } catch (Exception) {
      print(Exception);
    }
  }

  Widget _gameSetupList(BuildContext context) {
    return Material(
      borderRadius: const BorderRadius.only(
          topLeft: const Radius.circular(20.0),
          topRight: const Radius.circular(20.0)),
      elevation: 1.0,
      animationDuration: Duration(seconds: 1),
      child: Form(
        key: _formKey,
        child: ListView(
          primary: false,
          padding: const EdgeInsets.all(27),
          children: <Widget>[
            TextFormField(
              controller: scoreController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Score',
                helperText: '60-1000',
              ),
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter score';
                } else if (int.parse(value) < 60 || int.parse(value) > 1000) {
                  return 'Score must be between 60 and 1000';
                }
                return null;
              },
            ),
            TextFormField(
              controller: timeLimitController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  labelText: 'Time limit',
                  helperText: '20-180'
              ),
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter time limit';
                } else if (int.parse(value) < 20 || int.parse(value) > 180) {
                  return 'Time limit must be between 20 and 180';
                }
                return null;
              },
            ),
            Container(
              margin: const EdgeInsets.only(top: 22),
              child: ListTile(
                title: Text('Words language:'),
              ),
            ),
            ListTile(
              title: const Text('English'),
              leading: Radio(
                value: 'english',
                groupValue: _language,
                onChanged: (value) {
                  setState(() { _language = value; });
                },
                activeColor: Theme.of(context).accentColor,
              ),
            ),
            ListTile(
              title: const Text('Croatian'),
              leading: Radio(
                value: 'croatian',
                groupValue: _language,
                onChanged: (value) {
                  setState(() { _language = value; });
                },
                activeColor: Theme.of(context).accentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'Game setup',
        ),
      ),
      body: _gameSetupList(context),
      floatingActionButton: FloatingActionButton.extended(
        label: Text('Save'),
        onPressed: () {
          if (_formKey.currentState.validate()) {
            sharedPref.saveScore(int.parse(scoreController.text));
            sharedPref.saveTimeLimit(int.parse(timeLimitController.text));
            sharedPref.saveLanguage(_language);
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}
