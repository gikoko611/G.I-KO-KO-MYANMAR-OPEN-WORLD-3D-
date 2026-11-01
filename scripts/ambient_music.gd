extends Node

var player
var playback
var phase = 0.0
var music_enabled = true
var sound_enabled = true
var sample_rate = 22050.0

func _ready():
    var stream = AudioStreamGenerator.new()
    stream.mix_rate = int(sample_rate)
    stream.buffer_length = 2.0
    player = AudioStreamPlayer.new()
    player.stream = stream
    player.volume_db = -22.0
    add_child(player)
    player.play()
    playback = player.get_stream_playback()

func _process(_delta):
    if playback == null:
        return
    var frames = 256
    var buffer = PoolVector2Array()
    buffer.resize(frames)
    var gain = 0.10 if music_enabled and sound_enabled else 0.0
    for i in range(frames):
        var time = phase / sample_rate
        var fade = 0.65 + 0.35 * sin(time * 0.22)
        var chord = sin(TAU * 110.0 * time) * 0.42 + sin(TAU * 164.81 * time) * 0.25 + sin(TAU * 220.0 * time) * 0.16
        var melody = sin(TAU * 329.63 * time + sin(time * 0.35)) * 0.08
        var sample = (chord + melody) * fade * gain
        buffer[i] = Vector2(sample, sample)
        phase += 1.0
    playback.push_buffer(buffer)

func set_music_enabled(value):
    music_enabled = value

func set_sound_enabled(value):
    sound_enabled = value
