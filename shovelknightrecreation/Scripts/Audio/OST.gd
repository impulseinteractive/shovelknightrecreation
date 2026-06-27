extends AudioStreamPlayer2D
class_name OST

## ----------------------------------------------------------------------------
## Procedural NES-Style Chiptune Synth and a multi-section sequencer.
## Recreating Shovel Knight's song The Rival (Black Knight - First Battle)
##
## KEY: G | Minor BPM: 180 | Loop: 0:00-1:18 | Link: https://shorturl.at/mR1d5
##
## Song is broken into 4 main parts:
##	Intro        0:00-0:13  Driving rythmic foundation, this establishes key
##	Main Theme A 0:13-0:33  Descending lead hook and apeggiated bass
##	Development  0:33-0:55  Syncopated, uneasy, energy shift
##	Main Theme B 0:55-1:18  Driving rythmic foundation, this establishes key
##
## G minor scale for reference: G A A# C D D# F
## ----------------------------------------------------------------------------

## Class that contains channel specific logic
class Channel:
	var waveform: String = "pulse" ## Pulse, Triangle, Sawtooth, Noise
	var freq: float = 0.0
	var phase: float = 0.0
	var duty: float = 0.5
	var volume: float = 0.0
	var target_volume: float = 0.0
	var volume_step: float = 0.0
	var lfsr: int = 1 ## NES noise is 15bit linear feedback shift register
	var noise_short_mode: bool = false
	var noise_acc: float = 0.0
	
	func set_note(p_freq: float, p_volume: float, p_duty: float = 0.5) -> void:
		freq = p_freq
		duty = p_duty
		target_volume = p_volume
		volume_step = abs(p_volume - volume) / 64.0
	
	func set_noise_hit(p_freq: float, p_volume: float, p_short: bool = false) -> void:
		freq = p_freq
		noise_short_mode = p_short
		target_volume = p_volume
		volume_step = abs(p_volume - volume) / 16.0
	
	func note_off(release_samples: float = 400.0) -> void:
		target_volume = 0.0
		volume_step = volume / max(release_samples, 1.0)
	
	func next_sample() -> float:
		var out := 0.0
		match waveform:
			"pulse":
				out = 1.0 if phase < duty else -1.0
				if freq > 0.0:
					phase = fposmod(phase + freq / SAMPLE_RATE, 1.0)
			"triangle":
				out = 1.0 - 4.0 * abs(fposmod(phase + 0.25, 1.0) - 0.5)
				if freq > 0.0:
					phase = fposmod(phase + freq / SAMPLE_RATE, 1.0)
			"sawtooth":
				out = 2.0 * phase - 1.0
				if freq > 0.0:
					phase = fposmod(phase + freq / SAMPLE_RATE, 1.0)
			"noise":
				if freq > 0.0:
					noise_acc += freq / SAMPLE_RATE
					while noise_acc >= 1.0:
						noise_acc -= 1.0
						_clock_lfsr()
				out = 1.0 if (lfsr & 1) == 1 else -1.0
		if volume != target_volume:
			volume = move_toward(volume, target_volume, volume_step)
		return out * volume
	
	## Claude helped with this one, don't ask me lol
	func _clock_lfsr() -> void:
		var bit0 := lfsr & 1
		var tap := (lfsr >> (6 if noise_short_mode else 1)) & 1
		var feedback := bit0 ^ tap
		lfsr = (lfsr >> 1) | (feedback << 14)

const SAMPLE_RATE := 44100.0
const BPM := 180.0
const STEPS_PER_BEAT := 4 ## 16th note resolution. step = 1/16 note

const NOTE_OFFSETS := {
	"C": 0, "C#": 1, "D": 2, "D#": 3, "E": 4, "F": 5,
	"F#": 6, "G": 7, "G#": 8, "A": 9, "A#": 10, "B": 11,
}

var playback: AudioStreamGeneratorPlayback
var samples_per_step: int
var samples_until_step: int = 0
var step_index: int = 0

## Song is ordered list of sections. Sequencer plays them end-to-end then loops.
var song: Array = []
var section_index: int = 0
var pattern: Array = [] ## Current section's rows

## Channels
var pulse1 := Channel.new() ## Lead melody (square)
var pulse2 := Channel.new() ## Harmony / counter-lead (square)
var triangle := Channel.new() ## Sub-bass and arpeggiated bass (triangle)
var noise := Channel.new() ## Percussion (noise)

func _kick() -> Dictionary:
	return {"freq": 220.0, "vol": 0.7, "short": true}
 
func _snare() -> Dictionary:
	return {"freq": 6000.0, "vol": 0.6}
 
func _hat() -> Dictionary:
	return {"freq": 9000.0, "vol": 0.3}

func _ready() -> void:
	triangle.waveform = "triangle"
	noise.waveform = "noise"
 
	var gen := AudioStreamGenerator.new()
	gen.mix_rate = SAMPLE_RATE
	gen.buffer_length = 0.15
	stream = gen
	play()
	playback = get_stream_playback()
 
	samples_per_step = int(SAMPLE_RATE * 60.0 / BPM / STEPS_PER_BEAT)
	samples_until_step = samples_per_step
 
	_build_song()
	pattern = song[0]

func _process(_delta: float) -> void:
	_fill_buffer()
	
func _fill_buffer() -> void:
	var frames_available = playback.get_frames_available()
	if frames_available <= 0:
		return
 
	var buffer := PackedVector2Array()
	buffer.resize(frames_available)
 
	for i in range(frames_available):
		samples_until_step -= 1
		if samples_until_step <= 0:
			_advance_step()
			samples_until_step = samples_per_step
 
		var s := 0.0
		s += pulse1.next_sample() * 0.24
		s += pulse2.next_sample() * 0.18
		s += triangle.next_sample() * 0.30
		s += noise.next_sample() * 0.20
		s = clamp(s, -1.0, 1.0)
		buffer[i] = Vector2(s, s)
 
	playback.push_buffer(buffer)

func _advance_step() -> void:
	## Apply current step, then advance; roll over to next section / loop song.
	_apply_step(pattern[step_index])
	step_index += 1
	if step_index >= pattern.size():
		step_index = 0
		section_index = (section_index + 1) % song.size()
		pattern = song[section_index]

func _apply_step(row: Dictionary) -> void:
	if row.has("pulse1"):
		var n: Dictionary = row["pulse1"]
		pulse1.set_note(_note_to_hz(n["note"]), n.get("vol", 0.8), n.get("duty", 0.5))
	if row.has("pulse2"):
		var n2: Dictionary = row["pulse2"]
		pulse2.set_note(_note_to_hz(n2["note"]), n2.get("vol", 0.8), n2.get("duty", 0.5))
	if row.has("triangle"):
		var n3: Dictionary = row["triangle"]
		triangle.set_note(_note_to_hz(n3["note"]), n3.get("vol", 0.85))
	if row.has("noise"):
		var n4: Dictionary = row["noise"]
		noise.set_noise_hit(n4.get("freq", 4000.0), n4.get("vol", 0.6), n4.get("short", false))
 
	## Channels not named in this row release rather than sustain forever.
	if not row.has("pulse1"):
		pulse1.note_off()
	if not row.has("pulse2"):
		pulse2.note_off()
	if not row.has("triangle"):
		triangle.note_off(120.0)  ## short release keeps the bass arp articulated
	if not row.has("noise"):
		noise.note_off(60.0)

func _note_to_hz(note: String) -> float:
	if note == "":
		return 0.0
	var octave := int(note.substr(note.length() - 1, 1))
	var name1 := note.substr(0, note.length() - 1)
	var semitone: int = NOTE_OFFSETS.get(name1, 7)
	var midi := (octave + 1) * 12 + semitone
	return 440.0 * pow(2.0, float(midi - 69) / 12.0)

## Song reconstruction
func _build_song() -> void:
	song = [
		_section_intro(),
		#_section_main_a(),
		#_section_development(),
		#_section_main_b(),
	]

## INTRO SECTION 0:00-0:13
func _section_intro() -> Array:
	var rows: Array = []
	## Arpeggiated bass outlining G minor root motion (G - D - G - A#)
	var bass := ["G2", "D3", "G2", "A#2"]
	for step in range(16):
		var row: Dictionary = {}
		row["triangle"] = {"note": bass[step % bass.size()], "vol": 0.85}
		if step % 4 == 0:
			row["noise"] = _kick()
		elif step % 4 == 2:
			row["noise"] = _hat()
		## Faint pulse stab on the downbeats to hint at the key
		if step == 0 or step == 8:
			row["pulse2"] = {"note": "G4", "duty": 0.125, "vol": 0.4}
		rows.append(row)
	return rows
