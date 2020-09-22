import 'dart:ui';

import 'package:alias/game_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'Team.dart';
import 'alias_home.dart';


class GameFinishedPage extends StatelessWidget {
  GameFinishedPage({Key key, this.team}) : super(key: key);

  final Team team;

  final String illustrationName = 'assets/winner_team_illustration.svg';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Text(
              '${team.teamName} wins!',
              style: TextStyle(color: Colors.grey[800], fontSize: 51, fontWeight: FontWeight.w500)
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: SvgPicture.asset(
                  illustrationName,
                  semanticsLabel: 'Alias homepage illustration',
                ),
              ),
            ),
          ),
          Column(
            children: <Widget>[
              FloatingActionButton.extended(
                label: Text('Play again'),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => GamePage()
                      )
                  );
                },
              ),
              Container(
                margin: const EdgeInsets.only(top: 5),
                child: PlatformButton(
                  child: Text('Exit', style: TextStyle(color: Colors.black),),
                  materialFlat: (_, __)    => MaterialFlatButtonData(),
                  cupertino: (_, __) => CupertinoButtonData(),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AliasHomePage()
                        )
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
