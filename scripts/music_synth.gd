# Music synthesizer (runtime) for Godot
# This script creates an AudioStreamGenerator and fills it with a short looped melody.
# Attach to a Node (e.g., Main node) and call `start_music()` to play.

extends Node

const SAMPLE_RATE = 44100
const CHANNELS = 1
const LOOP_SECONDS = 4.0

var generator: AudioStreamGenerator
var player: AudioStreamPlayer

func _ready():
    generator = AudioStreamGenerator.new()
    generator.mix_rate = SAMPLE_RATE
    generator.buffer_length = LOOP_SECONDS

    player = AudioStreamPlayer.new()
    player.stream = generator
    add_child(player)

func start_music():
    # Fill buffer with simple pentatonic melody
    var frames = int(LOOP_SECONDS * SAMPLE_RATE)
    var buf = PoolVector2Array()
    buf.resize(frames)

    var scale = [0, 2, 4, 7, 9] # pentatonic intervals (semitones)
    var base_freq = 220.0 # A3

    for i in range(frames):
        var t = float(i) / SAMPLE_RATE
        var beat = int((t * 2.0)) % 8 # 2 beats per second, 8-beat pattern
        var note_idx = scale[beat % scale.size()]
        var freq = base_freq * pow(2.0, note_idx / 12.0)
        # simple plucked-ish sound (decaying sine with harmonic)
        var env = pow(0.0001 + abs(sin(PI * (t % 0.5) * 2.0)), 0.6)
        var sample = 0.0
        sample += 0.6 * sin(2.0 * PI * freq * t) * env
        sample += 0.2 * sin(2.0 * PI * freq * 2.0 * t) * env * 0.5
        buf[i] = Vector2(sample, sample)

    # Push frames into generator in chunks
    var write = generator.get_bus() # Not used directly in Godot 4; push using AudioStreamGeneratorPlayback
    player.play()
    var playback = player.get_stream_playback()
    if playback:
        var idx = 0
        while idx < frames:
            var chunk = min(1024, frames - idx)
            playback.push_frame(buf.slice(idx, idx + chunk))
            idx += chunk
    else:
        push_warning("No playback available for generator")

func stop_music():
    if player:
        player.stop()
