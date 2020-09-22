import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'start_page.dart';
import 'game_setup_page.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AliasHomePage extends StatelessWidget {
  AliasHomePage({Key key, this.title}) : super(key: key);

  final String title;

  final String illustrationName = 'assets/alias_home_illustration.svg';

  Future<bool> _endGame(BuildContext context) {
    return showPlatformDialog(
      context: context,
      builder: (context) => new PlatformAlertDialog(
        cupertino: (_, __) => CupertinoAlertDialogData(),
        material: (_, __)  => MaterialAlertDialogData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        title: new Text('Are you sure?'),
        content: new Text('Do you want to exit Alias'),
        actions: <Widget>[
          new FlatButton(
            child: Text("NO"),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          new FlatButton(
            child: Text("YES"),
            onPressed: () => SystemNavigator.pop()
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return WillPopScope(
      onWillPop: () => _endGame(context),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: Text(
                    'ALIAS',
                    style: TextStyle(
                        fontSize: 81,
                        fontWeight: FontWeight.w500
                    )
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      child: SvgPicture.asset(
                        illustrationName,
                        semanticsLabel: 'Alias homepage illustration',
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: <Widget>[
                  FloatingActionButton.extended(
                    label: Text('Play'),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => StartPage()
                          )
                      );
                    },
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 5, bottom: 10),
                    child: PlatformButton(
                      child: Text('Game setup'),
                      materialFlat: (_, __)    => MaterialFlatButtonData(),
                      cupertino: (_, __) => CupertinoButtonData(),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => GameSetupPage()
                            )
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
