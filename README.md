Kalleh_Operation - Prototype

What I implemented in this commit (feature/initial-prototype):

- Added a minimal Godot 4 prototype with a Player (CharacterBody3D) that automatically moves forward and can switch between three lanes using left/right input (ui_left/ui_right).
- Implemented a Main scene that spawns obstacles and collectibles ahead of the player at intervals.
- Obstacles are Areas that trigger a scene restart on collision (prototype game-over behavior).
- Collectibles are Areas that increment the player's score and disappear on pickup.
- Included simple visual placeholder meshes (BoxMesh / SphereMesh / PlaneMesh) so the scene is immediately playable without external assets.

How to test locally:

1. Open the project in Godot 4.7.1 (or compatible 4.x).
2. Open the scene scenes/main.tscn and run it.
3. Use left/right (A/D or arrow keys) to change lanes. The player moves forward automatically. Avoid obstacles and collect pickups.

Files added:
- project.godot
- scenes/main.tscn
- scenes/main.gd
- scenes/player.tscn
- scenes/player.gd
- scenes/obstacle.tscn
- scenes/obstacle.gd
- scenes/collectible.tscn
- scenes/collectible.gd
- README.md

Next steps:
- Add UI (score, lives, restart) and polish player collisions (invulnerability frames, animations).
- Replace placeholder meshes with the penguin art and create animated Sprite3D or Mesh + animations.
- Implement level streaming / object pooling for performance.
- Add sound effects and music.

