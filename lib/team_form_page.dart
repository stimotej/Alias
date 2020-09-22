import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'shared_prefs.dart';
import 'Team.dart';

class TeamFormPage extends StatefulWidget {
  TeamFormPage({Key key, this.team, this.editTeam}) : super(key: key);

  final Team team;
  final bool editTeam;

  @override
  _TeamFormPageState createState() => _TeamFormPageState();
}

class _TeamFormPageState extends State<TeamFormPage> {

  @override
  void initState() {
    super.initState();
    teamNameController.text = widget.team.teamName;
    playerOneController.text = widget.team.playerOne;
    playerTwoController.text = widget.team.playerTwo;
  }

  @override
  void dispose() {
    teamNameController.dispose();
    playerOneController.dispose();
    playerTwoController.dispose();
    super.dispose();
  }

  final newTeam = Team();

  SharedPref sharedPref = SharedPref();
  final _formKey = GlobalKey<FormState>();

  final teamNameController = TextEditingController();
  final playerOneController = TextEditingController();
  final playerTwoController = TextEditingController();

  Widget _teamFormList(BuildContext context) {
    return Hero(
      tag: 'team-' + widget.team.teamName,
      child: Material(
        borderRadius: const BorderRadius.only(
            topLeft: const Radius.circular(20.0),
            topRight: const Radius.circular(20.0)),
        elevation: 12.0,
        child: Form(
          key: _formKey,
          child: ListView(
            primary: false,
            padding: const EdgeInsets.all(27),
            children: <Widget>[
              TextFormField(
                controller: teamNameController,
                decoration: InputDecoration(
                  labelText: 'Team name',
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: playerOneController,
                decoration: InputDecoration(
                  labelText: 'Player one',
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
                decoration: InputDecoration(
                  labelText: 'Player two',
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
      ),
    );
  }

  Widget _deleteSave(BuildContext context) {
    return (widget.editTeam) ? Stack(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left:31),
            child:Align(
              alignment: Alignment.bottomLeft,
              child: FloatingActionButton(
                heroTag: null,
                backgroundColor: Colors.red,
                child: Icon(Icons.delete, color: Colors.white),
                onPressed: () => {
                  sharedPref.removeTeam(widget.team),
                  Navigator.pop(context)
                },
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton.extended(
              label: Text('Save'),
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  setState(() {
                    newTeam.teamName = teamNameController.text;
                    newTeam.playerOne = playerOneController.text;
                    newTeam.playerTwo = playerTwoController.text;
                  });
                  if(!widget.editTeam)
                    sharedPref.saveTeam(newTeam);
                  else
                    sharedPref.editTeam(widget.team, newTeam);
                  Navigator.pop(context);
                }
              },
            ),
          )
        ]
    ) :
    FloatingActionButton.extended(
      label: Text('Save'),
      onPressed: () {
        if (_formKey.currentState.validate()) {
          setState(() {
            newTeam.teamName = teamNameController.text;
            newTeam.playerOne = playerOneController.text;
            newTeam.playerTwo = playerTwoController.text;
          });
          if(!widget.editTeam)
            sharedPref.saveTeam(newTeam);
          else
            sharedPref.editTeam(widget.team, newTeam);
          Navigator.pop(context);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new PreferredSize(
        preferredSize: new AppBar().preferredSize,
        child: Hero(
          tag: 'appbar',
          child: AppBar(
            elevation: 0,
            title: Text(
              (widget.editTeam) ? 'Edit team' : 'Add team',
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ),
      ),
      body: _teamFormList(context),
      floatingActionButton: _deleteSave(context),
      );
    }
}
