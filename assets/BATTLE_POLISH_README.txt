Polish notes for battle improvements added:

What's improved:
- Improved unit.gd: attack timing, delayed damage application, signals for damaged/died/attacked.
- battle.gd: mobile-friendly Attack and Special buttons, damage popups, labels update, audio SFX via runtime generator.
- audio_sfx.gd: runtime synthesized short hit/special sounds (no external audio files required).

How to test:
1) Open scenes/battle.tscn and ensure the root scene name is 'Battle' (this project expects /root/Battle path for some lookups).
2) Run the scene. Use the on-screen Attack button or click the enemy to damage. Enemy will approach and attack.
3) Observe damage popups and HP label updates.

Future polish suggestions:
- Add AnimatedSprite2D or SpriteFrames for attack/death animations.
- Add particle effects when hit using CPUParticles2D or GPUParticles2D.
- Replace SVG placeholders with pixel PNGs and use sprite atlases.
- Improve AI: flanking, retreat, group behaviors.
