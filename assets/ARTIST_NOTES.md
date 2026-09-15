# Artist / integration notes

- The placeholder sprite sheets are 4 frames, arranged left-to-right. Each frame is 32x32 pixels.
- When replacing with real PNG sprite sheets, maintain the same layout (frames left-to-right) or update the Sprite/AnimatedSprite setup in Godot.
- For AnimatedSprite2D usage, create a SpriteFrames resource in Godot and define animations like 'idle' and 'attack'. The unit.gd script will try to play an 'attack' animation when present and will sync damage to attack_frame_index (default 2).

- Particle LOD heuristic: particles.amount is adjusted based on processor count. On low-end devices (<=2 core), particle amount is reduced to save CPU.

- Enemy texture selection: battle.gd will assign enemy variants from assets/enemy1.svg, enemy2.svg, enemy3.svg in round-robin.
