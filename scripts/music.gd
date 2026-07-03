extends Node

# Procedural technopop backing track: pad + bass + arpeggio + kick/hihat,
# synthesized sample-by-sample (no audio assets needed).

const BPM := 128.0
const MIX_RATE := 44100.0

const STEP_DUR := 60.0 / BPM / 4.0   # 16th note
const BEAT_DUR := STEP_DUR * 4.0     # quarter note
const BAR_DUR := STEP_DUR * 16.0
const LOOP_DUR := BAR_DUR * 4.0

# i - VI - III - VII progression in A minor: Am, F, C, G (simple + harmonic)
const CHORDS := [
	[220.00, 261.63, 329.63], # Am
	[174.61, 220.00, 261.63], # F
	[261.63, 329.63, 392.00], # C
	[196.00, 246.94, 293.66], # G
]
const BASS_ROOTS := [110.00, 87.31, 130.81, 98.00]
const ARP_PATTERN := [0, 1, 2, 1]

var _playback: AudioStreamGeneratorPlayback
var _t := 0.0
var _sample_delta := 0.0

func _ready() -> void:
	_sample_delta = 1.0 / MIX_RATE

	var gen := AudioStreamGenerator.new()
	gen.mix_rate = MIX_RATE
	gen.buffer_length = 0.3

	var player := AudioStreamPlayer.new()
	player.stream = gen
	player.volume_db = -8.0
	add_child(player)
	player.play()
	_playback = player.get_stream_playback()

func _process(_delta: float) -> void:
	if _playback == null:
		return
	var frames := _playback.get_frames_available()
	for _i in range(frames):
		var s := _sample(_t)
		_playback.push_frame(Vector2(s, s))
		_t += _sample_delta
		if _t >= LOOP_DUR:
			_t -= LOOP_DUR

func _sample(t: float) -> float:
	var bar_index: int = int(floor(t / BAR_DUR)) % 4
	var t_in_bar := fmod(t, BAR_DUR)
	var step_index: int = int(floor(t_in_bar / STEP_DUR)) % 16
	var t_in_step := fmod(t_in_bar, STEP_DUR)
	var t_in_beat := fmod(t_in_bar, BEAT_DUR)

	var chord: Array = CHORDS[bar_index]
	var bass_freq: float = BASS_ROOTS[bar_index]

	var out := 0.0
	out += _pad(chord, t_in_bar) * 0.10
	out += _bass(bass_freq, t_in_beat) * 0.22
	out += _arp(chord, step_index, t_in_step) * 0.16
	if step_index % 4 == 0:
		out += _kick(t_in_beat) * 0.35
	if step_index % 4 == 2:
		out += _hihat(t_in_step) * 0.10

	return clamp(tanh(out * 1.4), -1.0, 1.0)

# Sustained triad (the "harmonic" layer) with a short fade at bar edges to avoid clicks.
func _pad(chord: Array, t_in_bar: float) -> float:
	var fade := 0.03 * BAR_DUR
	var env := 1.0
	if t_in_bar < fade:
		env = t_in_bar / fade
	elif t_in_bar > BAR_DUR - fade:
		env = (BAR_DUR - t_in_bar) / fade
	var v := 0.0
	for freq in chord:
		v += sin(TAU * freq * t_in_bar)
	return v / chord.size() * env

# Plucky square-wave bass retriggered every beat.
func _bass(freq: float, t_in_beat: float) -> float:
	var env: float = exp(-t_in_beat * 7.0)
	return sign(sin(TAU * freq * t_in_beat)) * env

# Bright staccato square-wave arpeggio (the technopop hook), one octave above the pad.
func _arp(chord: Array, step_index: int, t_in_step: float) -> float:
	var idx: int = ARP_PATTERN[step_index % ARP_PATTERN.size()]
	var freq: float = chord[idx] * 2.0
	var env: float = exp(-t_in_step * 18.0)
	return sign(sin(TAU * freq * t_in_step)) * env

# Pitch-swept kick on every beat for the techno pulse.
func _kick(t_in_beat: float) -> float:
	var dur := 0.12
	if t_in_beat > dur:
		return 0.0
	var freq: float = lerp(150.0, 45.0, t_in_beat / dur)
	var env: float = exp(-t_in_beat * 28.0)
	return sin(TAU * freq * t_in_beat) * env

# Short noise burst on the off-beats.
func _hihat(t_in_step: float) -> float:
	var dur := 0.045
	if t_in_step > dur:
		return 0.0
	var env: float = exp(-t_in_step * 90.0)
	return (randf() * 2.0 - 1.0) * env
