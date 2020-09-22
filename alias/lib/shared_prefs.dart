import 'package:alias/Team.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'Team.dart';

class SharedPref {

  //--------------------------------------------------------------------------//
  //---- Teams Shared Preferences --------------------------------------------//
  //--------------------------------------------------------------------------//

  // Read all teams
  readTeams() async {
    final prefs = await SharedPreferences.getInstance();
    var _stringTeams = prefs.getStringList('teams');
    var teams = <Team>[];
    _stringTeams?.forEach((stringTeam) => {
      teams.add(Team.fromJson(json.decode(stringTeam)))
    });
    return teams;
  }

  // Save one team
  saveTeam(_team) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> _stringTeams = prefs.getStringList('teams') ?? [];
    if(!_stringTeams.contains(json.encode(_team)))
      _stringTeams.add(json.encode(_team));
    prefs.setStringList('teams', _stringTeams);
  }

  // Edit one team
  editTeam(_team, _newTeam) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> _stringTeams = prefs.getStringList('teams') ?? [];
    var index = _stringTeams.indexWhere((team) => team == json.encode(_team));
    _stringTeams.replaceRange(index, index+1, [json.encode(_newTeam)]);
    prefs.setStringList('teams', _stringTeams);
  }

  // Remove one team
  removeTeam(_team) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> _stringTeams = prefs.getStringList('teams') ?? [];
    _stringTeams.remove(json.encode(_team));
    prefs.setStringList('teams', _stringTeams);
  }

  // Remove all teams
  removeTeams() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('teams');
  }


  //--------------------------------------------------------------------------//
  //---- Score And Time Limit Shared Preferences -----------------------------//
  //--------------------------------------------------------------------------//

  // Save score
  saveScore(score) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('score', score);
  }

  // Read score
  readScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('score') ?? 100;
  }

  // Save time limit
  saveTimeLimit(timeLimit) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('time_limit', timeLimit);
  }

  // Read time limit
  readTimeLimit() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('time_limit') ?? 60;
  }


  //--------------------------------------------------------------------------//
  //---- Language Shared Preferences -----------------------------------------//
  //--------------------------------------------------------------------------//

  // Save language
  saveLanguage(language) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('language', language);
  }

  // Read language
  readLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('language') ?? "english";
  }
}