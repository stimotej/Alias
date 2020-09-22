import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'alias_home.dart';
import 'shared_prefs.dart';
import 'Team.dart';
import 'team_form_page.dart';
import 'game_page.dart';





// Save last game in progress
// Tooltip on all buttons
// Disable start game button when less than two teams
// Delete team while game is running
// Phone horizontal orientation fix game screen
// Add animation to timer circle
// When changing language inside game do nextWord




class StartPage extends StatefulWidget {
  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {

  @override
  void initState() {
    super.initState();
    _getTeams();
  }

  @override
  void dispose() {
    teamNameController.dispose();
    playerOneController.dispose();
    playerTwoController.dispose();
    super.dispose();
  }

  SharedPref sharedPref = SharedPref();
  List<Team> _teams = [];

  final newTeam = Team();

  final _formKey = GlobalKey<FormState>();

  final teamNameController = TextEditingController();
  final playerOneController = TextEditingController();
  final playerTwoController = TextEditingController();

  Team selectedTeam = Team();
  bool addTeam = false;

  PersistentBottomSheetController bottomSheetController;

  _getTeams() async {
    try {
      List<Team> teamsLoaded = await sharedPref.readTeams();
      setState(() {
        _teams = teamsLoaded;
      });
    } catch (Exception) {
      print(Exception);
    }
  }

  Widget teamForm(Team _team) {
    return Column(
      children: <Widget>[
        Container(
          alignment: AlignmentDirectional.centerStart,
          margin: const EdgeInsets.only(bottom: 20),
          child: Text(
              addTeam ? 'Add team' : 'Edit team',
              style: TextStyle(fontWeight: FontWeight.w500)
          ),
        ),
        Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: teamNameController,
                maxLength: 20,
                decoration: InputDecoration(
                  labelText: 'Team name',
                  counterText: ''
                ),
                validator: (value) {
                  if (value.isEmpty)
                    return 'Please enter some text';
                  return null;
                },
              ),
              TextFormField(
                controller: playerOneController,
                maxLength: 20,
                decoration: InputDecoration(
                  labelText: 'Player one',
                  counterText: ''
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: playerTwoController,
                maxLength: 20,
                decoration: InputDecoration(
                  labelText: 'Player two',
                  counterText: ''
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        Container(
          alignment: AlignmentDirectional.centerEnd,
          margin: const EdgeInsets.only(top: 20),
          child: addTeam ?
          PlatformButton(
            child: Text('Cancel'),
            materialFlat: (_, __)    => MaterialFlatButtonData(),
            cupertino: (_, __) => CupertinoButtonData(),
            onPressed: () {
              setState(() {
                bottomSheetController.close();
                selectedTeam = Team();
              });
            },
          ) :
          PlatformButton(
            child: Text('Delete team'),
            materialFlat: (_, __)    => MaterialFlatButtonData(textColor: Colors.red,),
            cupertino: (_, __) => CupertinoButtonData(
                child: Text('Delete', style: TextStyle(color: Colors.red),)
            ),
            onPressed: () {
              sharedPref.removeTeam(_team);
              setState(() {
                bottomSheetController.close();
                selectedTeam = Team();
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _teamsList(BuildContext context) {
    return Material(
        borderRadius: const BorderRadius.only(
            topLeft: const Radius.circular(20.0),
            topRight: const Radius.circular(20.0)),
        child: ListView.separated(
          primary: false,
          padding: const EdgeInsets.all(8),
          itemCount: _teams.length + 1,
          itemBuilder: (context, index) {
            return (index == _teams.length) ?
            Row(
              children: <Widget>[
                PlatformButton(
                  child: Row(
                    children: [
                      Icon(context.platformIcons.add),
                      Container(width: 5,),
                      Text('Add team'),
                    ],
                  ),
                  materialFlat: (_, __)    => MaterialFlatButtonData(),
                  cupertino: (_, __) => CupertinoButtonData(),
                  onPressed: () {
                    bottomSheetController = showBottomSheet(
                        context: context,
                        builder: (context) => SingleChildScrollView(
                          physics: NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(30),
                          child: teamForm(Team()),
                        )
                    );
                    setState(() {
                      teamNameController.clear();
                      playerOneController.clear();
                      playerTwoController.clear();
                      selectedTeam = Team();
                      addTeam = true;
                    });
                    bottomSheetController.closed.then((_) {
                      setState(() {
                        selectedTeam = Team();
                        addTeam = false;
                      });
                    });
                  },
                )
              ],
            ) :
            Builder(
              builder: (context) => ListTile(
                selected: selectedTeam.teamName == _teams[index].teamName,
                title: Text(_teams[index].teamName, style: TextStyle(fontSize: 18),),
                subtitle: Text('${_teams[index].playerOne} - ${_teams[index].playerTwo}'),
                leading: Icon(context.platformIcons.group),
                onTap: () {
                  bottomSheetController = showBottomSheet(
                    context: context,
                    builder: (context) => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.all(30),
                          child: teamForm(_teams[index]),
                        ),
                      ],
                    )
                  );
                  setState(() {
                    teamNameController.text = _teams[index].teamName;
                    playerOneController.text = _teams[index].playerOne;
                    playerTwoController.text = _teams[index].playerTwo;
                    selectedTeam = _teams[index];
                    addTeam = false;
                  });
                  bottomSheetController.closed.then((_) {
                    setState(() {
                      teamNameController.clear();
                      playerOneController.clear();
                      playerTwoController.clear();
                      selectedTeam = Team();
                      addTeam = false;
                    });
                  });
                },
              ),
            );
          },
          separatorBuilder: (BuildContext context, int index) => const Divider(),
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    _getTeams();
    return Scaffold(
      appBar: new PreferredSize(
        preferredSize: new AppBar().preferredSize,
        child: Hero(
          tag: 'appbar',
          child: AppBar(
            elevation: 0,
            title: Text('Create teams'),
            leading: PlatformIconButton(
              materialIcon: Icon(Icons.arrow_back),
              cupertinoIcon: Icon(
                CupertinoIcons.back,
                size: 30.0,
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AliasHomePage()),
                );
              },
            ),
          ),
        ),
      ),
      body: _teamsList(context),
      floatingActionButton: selectedTeam.teamName != null || (selectedTeam.teamName == null && addTeam) ?
      FloatingActionButton.extended(
        label: addTeam ? Text('Create') : Text('Save'),
        onPressed: () {
          if (_formKey.currentState.validate()) {
            setState(() {
              newTeam.teamName = teamNameController.text;
              newTeam.playerOne = playerOneController.text;
              newTeam.playerTwo = playerTwoController.text;
            });
            addTeam ?
              sharedPref.saveTeam(newTeam) :
              sharedPref.editTeam(selectedTeam, newTeam);
            setState(() {
              bottomSheetController.close();
              selectedTeam = Team();
            });
          }
        }) :
      Builder(
        builder: (context) => FloatingActionButton.extended(
          tooltip: 'Start game',
          label: Text('Start game'),
          onPressed: _teams.length < 2 ? () {
            Scaffold.of(context).showSnackBar(SnackBar(
              content: Text('You must add at least 2 teams!', style: TextStyle(color: Colors.white),),
              backgroundColor: Colors.red,
              action: SnackBarAction(
                label: 'Add team',
                onPressed: () {
                  bottomSheetController = showBottomSheet(
                      context: context,
                      builder: (context) => Container(
                        padding: const EdgeInsets.all(30),
                        child: teamForm(Team()),
                      ),
                  );
                  setState(() {
                    teamNameController.clear();
                    playerOneController.clear();
                    playerTwoController.clear();
                    selectedTeam = Team();
                    addTeam = true;
                  });
                  bottomSheetController.closed.then((_) {
                    setState(() {
                      selectedTeam = Team();
                      addTeam = false;
                    });
                  });
                },
              ),
            ));
          }: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => GamePage()
                )
            );
          },
        ),
      )
    );
  }
}
