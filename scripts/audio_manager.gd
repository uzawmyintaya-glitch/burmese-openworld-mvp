extends Node

# Audio manager: prefer real OGG assets if present, else fallback to runtime synth

var music_player: AudioStreamPlayer = null
var sfx_player: AudioStreamPlayer = null
var synth_fallback = null

func _ready():
    # music
    if ResourceLoader.exists("res://assets/audio/music.ogg"):
        music_player = AudioStreamPlayer.new()
        music_player.stream = load("res://assets/audio/music.ogg")
        music_player.autoplay = true
        add_child(music_player)
    else:
        # no music file: keep silence or fallback later
        pass

    # sfx
    if ResourceLoader.exists("res://assets/audio/hit.ogg") or ResourceLoader.exists("res://assets/audio/special.ogg"):
        sfx_player = AudioStreamPlayer.new()
        add_child(sfx_player)
    else:
        synth_fallback = preload("res://scripts/audio_sfx.gd").new()
        add_child(synth_fallback)

func play_hit():
    if sfx_player and ResourceLoader.exists("res://assets/audio/hit.ogg"):
        sfx_player.stream = load("res://assets/audio/hit.ogg")
        sfx_player.play()
    elif synth_fallback:
        synth_fallback.play_hit()

func play_special():
    if sfx_player and ResourceLoader.exists("res://assets/audio/special.ogg"):
        sfx_player.stream = load("res://assets/audio/special.ogg")
        sfx_player.play()
    elif synth_fallback:
        synth_fallback.play_special()

func play_music():
    if music_player:
        music_player.play()
