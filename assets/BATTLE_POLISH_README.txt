Polish updates:

Added features per request: 1) animated sprite hooks, 2) hit VFX and screen shake, 5) multi-enemy formation fights, 7) prefer real OGG audio with fallback.

Files added/updated:
- scenes/battle.tscn: added Camera2D, CPUParticles2D and spawn template
- scripts/battle.gd: multi-enemy spawn, hit VFX, screen shake, updated UI
- scripts/audio_manager.gd: uses OGG assets when available, otherwise falls back to synth
- assets/character_sheet.svg: placeholder atlas (4 frames)
- assets/audio/README-audio.md: where to place OGG files

Notes for artists & export:
- Replace assets/character_sheet.svg with a PNG sprite sheet (frames left-to-right). Frame size chosen by me: 32x32 per frame in this placeholder. If you prefer different per-frame size (48x48), replace textures and update SpriteFrames accordingly in Godot.
- For best mobile results, provide stripped-down 2-3 frame attack animations and keep atlases compressed.

How to test:
1) Open scenes/battle.tscn in Godot 4.1+ and run.
2) It will spawn multiple enemy copies; use Attack or Special buttons to fight.
3) To use real audio, add OGG files under assets/audio/ as named above and restart the scene.
