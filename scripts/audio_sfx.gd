extends Node

# Simple runtime SFX generator using AudioStreamGenerator (short blips for hits/special)

const SAMPLE_RATE = 44100

var player: AudioStreamPlayer
var gen: AudioStreamGenerator

func _init():
    gen = AudioStreamGenerator.new()
    gen.mix_rate = SAMPLE_RATE
    gen.buffer_length = 0.25
    player = AudioStreamPlayer.new()
    player.stream = gen
    add_child(player)

func _play_tone(freq: float, duration: float = 0.12, volume: float = 0.5):
    # fill buffer with short decaying sine
    var frames = int(duration * SAMPLE_RATE)
    var buf = PackedFloat32Array()
    buf.resize(frames)
    for i in range(frames):
        var t = float(i) / SAMPLE_RATE
        var env = pow(1.0 - t / duration, 2.0)
        buf[i] = sin(2.0 * PI * freq * t) * env * volume
    var playback = player.get_stream_playback()
    if not playback:
        return
    var idx = 0
    while idx < frames:
        var chunk = min(1024, frames - idx)
        var a = PoolVector2Array()
        a.resize(chunk)
        for j in range(chunk):
            var v = buf[idx + j]
            a[j] = Vector2(v, v)
        playback.push_frame(a)
        idx += chunk
    player.play()

func play_hit():
    _play_tone(880.0, 0.08, 0.6)

func play_special():
    _play_tone(440.0, 0.18, 0.8)
