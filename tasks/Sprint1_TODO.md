# Sprint1: placeholders generated and integrated

What's included in this commit:
- Updated overworld_manager.gd to display selectable destinations (UI buttons) and to use map.json connections
- Audio manager updated to use runtime synth ambient if no music.ogg present
- Added overworld ambient synth (scripts/overworld_ambient.gd)
- Added map SVG & node icon placeholders and audio README for overworld

Next tasks (Sprint1 remaining):
- Visualize nodes on the Overworld scene (draw icons from map.json)
- Persist current node via save_system.gd on travel
- Improve encounter composition (types/strength) and pass to battle manager

How to test:
1) Switch to feature/beta branch and open Godot 4.1+
2) Open scenes/overworld.tscn, run scene
3) Click Travel -> choose a destination -> travel timer -> may trigger encounter

Notes:
- Audio: if you want a real background OGG, add assets/audio/overworld_loop.ogg and scripts/audio_manager.gd will use it instead of synth.
