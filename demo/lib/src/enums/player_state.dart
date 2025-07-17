enum PlayerState {
  walkUp('character-up', 4),
  walkDown('character-down', 4),
  walkLeft('character-left', 4),
  walkRight('character-right', 4);

  final String asset;
  final int frameCount;

  const PlayerState(this.asset, this.frameCount);
}
