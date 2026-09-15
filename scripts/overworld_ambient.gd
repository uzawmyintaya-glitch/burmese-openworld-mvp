extends Node

# Simple ambient music synth for overworld (looped pad)
# Uses AudioStreamGenerator to synthesize a slow evolving pad

const SAMPLE_RATE = 22050
const BUFFER_SECONDS = 2.0

var generator: AudioStreamGenerator
var player: AudioStreamPlayer

func _ready():
    generator = AudioStreamGenerator.new()
    generator.mix_rate = SAMPLE_RATE
    generator.buffer_length = BUFFER_SECONDS
    player = AudioStreamPlayer.new()
    player.stream = generator
    add_child(player)

func play_music():
    # generate a short loop buffer of ambient pad
    var frames = int(BUFFER_SECONDS * SAMPLE_RATE)
    var a = PoolVector2Array()
    a.resize(frames)
    for i in range(frames):
        var t = float(i) / SAMPLE_RATE
        var freq = 220.0 + 40.0 * sin(t * 0.5)
        var sample = 0.0
        sample += 0.4 * sin(2.0 * PI * freq * t)
        sample += 0.2 * sin(2.0 * PI * (freq * 1.5) * t)
        sample *= 0.2 * (1.0 - 0.5 * sin(t * 0.25))
        a[i] = Vector2(sample, sample)
    var playback = player.get_stream_playback()
    if not playback:
        return
    var idx = 0
    while idx < frames:
        var chunk = min(1024, frames - idx)
        var b = PoolVector2Array()
        b.resize(chunk)
        for j in range(chunk):
            b[j] = a[idx + j]
        playback.push_frame(b)
        idx += chunk
    player.play()

func stop_music():
    if player:
        player.stop()
