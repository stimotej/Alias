import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'Team.dart';
import 'Words.dart';
import 'game_finished_page.dart';
import 'shared_prefs.dart';
import 'game_setup_page.dart';
import 'alias_home.dart';

class GamePage extends StatefulWidget {

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> with TickerProviderStateMixin {

  @override
  void initState() {
    super.initState();
    // On init get score and time limit
    _getScoreAndTimeLimit();
    // On init set first team
    _setNextTeam();
    // Get first word
    _nextWord();
  }

  @override
  void dispose() {
    // Cancel timer when dispose
    _timer?.cancel();
    super.dispose();
  }

  // Get shared prefs
  SharedPref sharedPref = SharedPref();

  // Get Words class and create word variable
  Words words = Words();
  String word = '';

  // List of answers in one round
  List<Map> wordsAnswered = [];

  // Timer variable
  Timer _timer;

  // All teams
  List<Map> _teams = [];

  // Current team that is playing
  Team teamPlaying = Team();

  Map winner = {'team': Team(), 'score': 0};

  // Loop through teams
  int teamIndex = 0;
  bool reverse = false;

  // Current time
  int currentTime;

  // Game score and time limit from game setup
  int _scoreLimit;
  int _timeLimit;

  // Answer variables
  int correct = 0;
  int skipped = 0;

  bool gameFinished = false;

  // Game states
  String state = 'start';
  // start -> Start game title, before game state
  // game -> Game is running, timer started
  // pause -> Game is paused on pause button or back clicked
  // ended -> Timer finished, show given answers
  // preview -> See all teams and their scores

  // Count number of correct and skipped answers from wordsAnswered list
  _countCorrect() async {
    int _correct = wordsAnswered.where((answer) => answer['correct'] == true).length;
    int _skipped = wordsAnswered.length - _correct;
    setState(() {
      correct = _correct;
      skipped = _skipped;
    });
  }

  // Get next word from Words class
  _nextWord() async {
    try {
      String wordLoaded = await words.nextWord();
      await _countCorrect();
      setState(() {
        word = wordLoaded;
      });
    } catch (Exception) {
      print(Exception);
    }
  }

  // Change answer
  _setCorrect(int index, bool _correct) async {
    setState(() {
      wordsAnswered[index]['correct'] = _correct;
    });

    await _countCorrect();
  }

  // Get score and time limit from shared prefs
  _getScoreAndTimeLimit() async {
    try {
      int scoreLoaded = await sharedPref.readScore();
      int timeLimitLoaded = await sharedPref.readTimeLimit();
      setState(() {
        _scoreLimit = scoreLoaded;
        _timeLimit = timeLimitLoaded;
        currentTime = timeLimitLoaded;
      });
    } catch (Exception) {
      print(Exception);
    }
  }

  // Get all teams from shared prefs
  _getTeams() async {
    try {
      List<Team> teamsLoaded = await sharedPref.readTeams();
      setState(() {
        teamsLoaded.forEach((team) => {
          _teams.add({'team': team, 'score': 0})
        });
      });
    } catch (Exception) {
      print(Exception);
    }
  }

  // Set next team to play
  _setNextTeam() async {
    if(_teams.isEmpty) await _getTeams();
    setState(() {
      if (teamIndex > (_teams.length-1)) {
        teamIndex = 0;
        reverse = !reverse;
      }
      teamPlaying = _teams[teamIndex]['team'];

      // Clear answers for next player
      wordsAnswered.clear();

      correct = 0;
      skipped = 0;
    });
  }

  checkWinner() async {
    if (teamIndex >= (_teams.length-1)) {
      _teams.forEach((team) => {
        team['score'] > winner['score'] ? winner = team : winner = winner
      });
      if (winner['score'] >= _scoreLimit) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => GameFinishedPage(team: winner['team'],)
            )
        );
      }
    }
  }

  // Control timer
  startTimer() async {
    _timer = new Timer.periodic(
      const Duration(seconds: 1),
        (Timer timer) => {
          setState(() {
            if (currentTime < 1) {

              // Cancel timer
              timer.cancel();

              // Reset timer
              currentTime = _timeLimit;

              checkWinner();

              // Set game state to ended
              state = 'ended';
            } else
              currentTime -= 1;
          },
        ),
      }
    );
  }

  // On play fab click - change game state
  _playButton () {
    switch (state) {
      case 'start': {
        startTimer();
        setState(() {
          state = 'game';
        });
      } break;

      case 'game': {
        _timer.cancel();
        setState(() {
          state = 'pause';
        });
      } break;

      case 'pause': {
        startTimer();
        setState(() {
          state = 'game';
        });
      } break;

      case 'ended': {
        setState(() {
          state = 'preview';
        });
      } break;

      case 'preview': {
        setState(() {
          state = 'start';

          setState(() { teamIndex++; });
          _setNextTeam();
          _nextWord();
          _getScoreAndTimeLimit();
        });
      } break;
    }
  }

  // End game dialog when back or end game button clicked
  Future<bool> _endGame() {
    return state == 'game' ?
    {_timer.cancel(), setState(() {state = 'pause';}), false} :
    showPlatformDialog(
      context: context,
      builder: (context) => new PlatformAlertDialog(
        cupertino: (_, __) => CupertinoAlertDialogData(),
        material: (_, __)  => MaterialAlertDialogData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        title: new Text('Are you sure?'),
        content: new Text('Do you want to end game'),
        actions: <Widget>[
          new FlatButton(
            child: Text("NO"),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          new FlatButton(
            child: Text("YES"),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => AliasHomePage()),
              );
            },
          ),
        ],
      ),
    ) ?? false;
  }

  // Set screen to body based on state
  Widget _setScreen() {
    if (state == 'start')
      return _gameStart();
    else if (state == 'game')
      return _gameActive();
    else if (state == 'ended')
      return _gameEnded();
    else if (state == 'preview')
      return _gamePreview();
    else
      return _gamePaused();
  }

  // Start game screen
  Widget _gameStart() {
    return ListView(
      primary: false,
      padding: const EdgeInsets.all(8),
      children: <Widget>[
        Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: ListTile(
              title: Text('Start round'),
              trailing: Chip(
                backgroundColor: Colors.blueAccent[700],
                label: Text(
                  '${currentTime.toString()}s',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            )
        ),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: Text('Team playing:'),
              ),
              ListTile(
                  leading: Icon(context.platformIcons.group),
                  title: Text(teamPlaying.teamName ?? ''),
                  trailing: Chip(
                    backgroundColor: Colors.blueAccent[700],
                    label: Text(
                      _teams.isNotEmpty ? _teams[teamIndex]['score'].toString() : '0',
                      style: TextStyle(color: Colors.white),
                    ),
                  )
              ),
              Divider(),
              ListTile(
                leading: Icon(context.platformIcons.person),
                title: Text(reverse ?
                teamPlaying.playerTwo ?? '' :
                teamPlaying.playerOne ?? ''
                ),
                trailing: Text('Explaining'),
              ),
              ListTile(
                leading: Icon(context.platformIcons.person),
                title: Text(reverse ?
                teamPlaying.playerOne ?? '' :
                teamPlaying.playerTwo ?? ''
                ),
                trailing: Text('Guessing'),
              ),
            ],
          ),
        ),
      ]
    );
  }

  // Screen for game active state
  Widget _gameActive() {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  title: Text('This round:'),
                ),
                ListTile(
                  leading: Icon(context.platformIcons.done, color: Colors.green,),
                  title: Text('Correct'),
                  trailing: Chip(
                    label: Text(correct.toString()),
                  )
                ),
                ListTile(
                  leading: Icon(context.platformIcons.clearThick, color: Colors.red,),
                  title: Text('Skipped'),
                  trailing: Chip(
                    label: Text(skipped.toString()),
                  )
                ),
              ],
            )
          ),
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(word ?? '', style: TextStyle(fontSize: 42, fontWeight: FontWeight.w400),),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 21),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8),
                child: IconButton(
                  icon: Icon(
                    context.platformIcons.clearThick,
                    size: 30,
                  ),
                  onPressed: () {
                    setState(() {
                      _nextWord();
                      wordsAnswered.add({'word': word, 'correct': false});
                      _teams[teamIndex]['score'] -= 1;
                    });
                  },
                ),
              ),
              Stack(
                alignment: AlignmentDirectional.center,
                children: <Widget>[
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: CircularProgressIndicator(
                      value: (currentTime / _timeLimit.toDouble()),
                      strokeWidth: 6.0,
                      valueColor: (currentTime / _timeLimit.toDouble()) > 0.15 ?
                      new AlwaysStoppedAnimation<Color>(Colors.green) :
                      new AlwaysStoppedAnimation<Color>(Colors.red),
                    ),
                    ),
                  Text('${currentTime}s', style: TextStyle(fontSize: 20),),
                ]
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: IconButton(
                  icon: Icon(
                    context.platformIcons.done,
                    size: 30,
                  ),
                  onPressed: () {
                    setState(() {
                      _nextWord();
                      wordsAnswered.add({'word': word, 'correct': true});
                      _teams[teamIndex]['score'] += 1;
                    });
                  },
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  // Game paused screen
  Widget _gamePaused() {
    return ListView(
      primary: false,
      padding: const EdgeInsets.all(8),
      children: <Widget>[
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: ListTile(
            title: Text('Paused'),
            trailing: Chip(
              backgroundColor: Colors.blueAccent[700],
              label: Text(
                '${currentTime.toString()}s',
                style: TextStyle(color: Colors.white)
              ),
            ),
          )
        ),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: Text('Team playing:'),
              ),
              ListTile(
                leading: Icon(context.platformIcons.group),
                title: Text(teamPlaying.teamName ?? ''),
                trailing: Chip(
                  backgroundColor: Colors.blueAccent[700],
                  label: Text(
                    _teams[teamIndex]['score'].toString(),
                    style: TextStyle(color: Colors.white)
                  ),
                )
              ),
              Divider(),
              ListTile(
                leading: Icon(context.platformIcons.person),
                title: Text(reverse ?
                  teamPlaying.playerTwo ?? '' :
                  teamPlaying.playerOne ?? ''
                ),
                trailing: Text('Explaining'),
              ),
              ListTile(
                leading: Icon(context.platformIcons.person),
                title: Text(reverse ?
                  teamPlaying.playerOne ?? '' :
                  teamPlaying.playerTwo ?? ''
                ),
                trailing: Text('Guessing'),
              ),
            ],
          ),
        ),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: Text('This round:'),
              ),
              ListTile(
                leading: Icon(context.platformIcons.done, color: Colors.green,),
                title: Text('Correct'),
                trailing: Chip(
                  label: Text(correct.toString()),
                )
              ),
              ListTile(
                leading: Icon(context.platformIcons.clearThick, color: Colors.red,),
                title: Text('Skipped'),
                trailing: Chip(
                  label: Text(skipped.toString()),
                )
              ),
            ],
          )
        ),
      ]
    );
  }

  // Game ended screen
  Widget _gameEnded() {
    return ListView(
      primary: false,
        padding: const EdgeInsets.all(8),
        children: <Widget>[
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child:
            Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  title: Text('This round:'),
                ),
                ListTile(
                    leading: Icon(context.platformIcons.done, color: Colors.green,),
                    title: Text('Correct'),
                    trailing: Chip(
                      label: Text(correct.toString()),
                    )
                ),
                ListTile(
                    leading: Icon(context.platformIcons.clearThick, color: Colors.red),
                    title: Text('Skipped'),
                    trailing: Chip(
                      label: Text(skipped.toString()),
                    )
                ),
              ],
            )
          ),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: wordsAnswered.length + 1,
              itemBuilder: (context, index) {
                return index == 0 ?
                ListTile(
                  title: Text('Answers:'),
                ) : wordsAnswered.isEmpty ?
                ListTile(
                  title: Text('No answers'),
                ) :
                ListTile(
                  title: Text(wordsAnswered[index-1]['word'] ?? ''),
                  trailing: Switch(
                    value: wordsAnswered[index-1]['correct'],
                    onChanged: (value) {
                        _setCorrect(index-1, value);
                        setState(() {
                          value ? _teams[teamIndex]['score'] += 2 :
                            _teams[teamIndex]['score'] -= 2;
                        });
                    },
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) => index > 0 ? const Divider() : Container(),
            ),
          )
      ]
    );
  }

  // Teams score preview screen
  Widget _gamePreview() {
    return ListView(
      primary: false,
      padding: const EdgeInsets.all(8),
      children: <Widget>[
        Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  title: Text('This round:'),
                  trailing: IconButton(
                    icon: Icon(context.platformIcons.pen),
                    onPressed: () {
                      setState(() { state = 'ended'; });
                    },
                  ),
                ),
                ListTile(
                    leading: Icon(context.platformIcons.done, color: Colors.green),
                    title: Text('Correct'),
                    trailing: Chip(
                      label: Text(correct.toString()),
                    )
                ),
                ListTile(
                    leading: Icon(context.platformIcons.clearThick, color: Colors.red),
                    title: Text('Skipped'),
                    trailing: Chip(
                      label: Text(skipped.toString()),
                    )
                ),
              ],
            )
        ),
        Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: _teams.length + 1,
              itemBuilder: (context, index) {
                return index == 0 ?
                ListTile(
                  title: Text('Teams:'),
                ) :
                ListTile(
                  selected: index-1 == teamIndex,
                  title: Row(
                    children: <Widget>[
                      Text(_teams[index-1]['team'].teamName),
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        child: index-1 == ((teamIndex+1 > (_teams.length-1)) ? 0 : teamIndex+1) ?
                          Chip(label: Text('Next')) :
                          new Container(),
                      ),
                    ],
                  ),
                  subtitle: Text(_teams[index-1]['team'].playerOne + " - " + _teams[index-1]['team'].playerTwo),
                  leading: Icon(context.platformIcons.group),
                  trailing: Chip(
                    label: Text(_teams[index-1]['score'].toString()),
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) => index > 0 ? const Divider() : Container(),
            ),
          )
      ]
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _endGame,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          title: Text(
            'Game',
          ),
        ),
        body: _setScreen(),
        floatingActionButton: FloatingActionButton(
          child: state == 'game' ?
            Icon(context.platformIcons.pause) : state == 'ended' ?
            Icon(context.platformIcons.done) : state == 'preview' ?
            Icon(context.platformIcons.forward) :
            Icon(context.platformIcons.playArrowSolid),
          onPressed: _playButton,
        ),
        floatingActionButtonLocation: state == 'game' ?
            FloatingActionButtonLocation.endTop :
            FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: state == 'game' ?
          null :
          ClipRRect(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(20),
              topLeft: Radius.circular(20),
            ),
            child: BottomAppBar(
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: PlatformButton(
                      child: Text('End game'),
                      materialFlat: (_, __)    => MaterialFlatButtonData(),
                      cupertino: (_, __) => CupertinoButtonData(),
                      onPressed: _endGame,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: PlatformButton(
                      child: Text('Game setup'),
                      materialFlat: (_, __)    => MaterialFlatButtonData(),
                      cupertino: (_, __) => CupertinoButtonData(),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => GameSetupPage()),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          )
        )
    );
  }
}
