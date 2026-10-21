enum GameModeType { classic, zenRelax, daily }

class GameMode {
  final GameModeType type;
  final String title;
  final String description;
  final bool hasTimer;

  const GameMode({
    required this.type,
    required this.title,
    required this.description,
    this.hasTimer = true,
  });

  static const GameMode classic = GameMode(
    type: GameModeType.classic,
    title: 'CLASSIC STAGES',
    description: 'Progress through handcrafted architectural Mahjong puzzles.',
    hasTimer: true,
  );

  static const GameMode zenRelax = GameMode(
    type: GameModeType.zenRelax,
    title: 'ZEN RELAX',
    description: 'Untimed mindful play with soothing ambient relaxation.',
    hasTimer: false,
  );

  static const GameMode daily = GameMode(
    type: GameModeType.daily,
    title: 'DAILY SEED',
    description: 'Daily competitive puzzle seeded identically for all players.',
    hasTimer: true,
  );
}
