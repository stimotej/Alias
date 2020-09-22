class Team {
  String teamName;
  String playerOne;
  String playerTwo;

  Team();

  Team.fromJson(Map<String, dynamic> json) :
    teamName = json['teamName'],
    playerOne = json['playerOne'],
    playerTwo = json['playerTwo'];

  Map<String, dynamic> toJson() => {
    'teamName': teamName,
    'playerOne': playerOne,
    'playerTwo': playerTwo,
  };
}