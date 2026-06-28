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

	## Envelope: attack -> decay -> sustain -> release
	var target_volume: float = 0.0
	var volume_step: float = 0.0
	var peak_volume: float = 0.0
	var sustain_volume: float = 0.0
	var decay_step: float = 0.0
	var env_phase: String = "idle" ## idle, attack, decay, sustain, release

	## Vibrato (pitch LFO) - the thing that makes sustained leads sing
	var vibrato_depth: float = 0.0 ## peak deviation in semitones
	var vibrato_rate: float = 0.0  ## Hz
	var vibrato_phase: float = 0.0
	var vibrato_delay: float = 0.0 ## seconds before vibrato fades in
	var vibrato_time: float = 0.0

	## Noise
	var lfsr: int = 1 ## NES noise is 15bit linear feedback shift register
	var noise_short_mode: bool = false
	var noise_acc: float = 0.0

	func set_note(p_freq: float, p_volume: float, p_duty: float = 0.5, \
			decay_ms: float = 0.0, sustain: float = 1.0, \
			vib_depth: float = 0.0, vib_rate: float = 0.0, vib_delay: float = 0.0) -> void:
		freq = p_freq
		duty = p_duty
		peak_volume = p_volume
		sustain_volume = p_volume * clamp(sustain, 0.0, 1.0)
		## Attack first: ramp toward the peak.
		target_volume = p_volume
		volume_step = abs(p_volume - volume) / 64.0
		env_phase = "attack"
		if decay_ms > 0.0 and sustain_volume < p_volume:
			decay_step = (p_volume - sustain_volume) / max(decay_ms * 0.001 * SAMPLE_RATE, 1.0)
		else:
			decay_step = 0.0
		## Reset vibrato so each retrigger starts clean.
		vibrato_depth = vib_depth
		vibrato_rate = vib_rate
		vibrato_delay = vib_delay
		vibrato_time = 0.0
		vibrato_phase = 0.0

	func set_noise_hit(p_freq: float, p_volume: float, p_short: bool = false, decay_ms: float = 0.0) -> void:
		freq = p_freq
		noise_short_mode = p_short
		peak_volume = p_volume
		## Percussion decays to silence, giving a snap instead of a sustained buzz.
		sustain_volume = 0.0 if decay_ms > 0.0 else p_volume
		target_volume = p_volume
		volume_step = abs(p_volume - volume) / 16.0
		env_phase = "attack"
		if decay_ms > 0.0:
			decay_step = p_volume / max(decay_ms * 0.001 * SAMPLE_RATE, 1.0)
		else:
			decay_step = 0.0
		vibrato_depth = 0.0

	func note_off(release_samples: float = 400.0) -> void:
		env_phase = "release"
		target_volume = 0.0
		volume_step = volume / max(release_samples, 1.0)
		decay_step = 0.0

	func next_sample() -> float:
		## Apply vibrato to the playback frequency (pitch only, not the stored freq).
		var f := freq
		if vibrato_depth > 0.0 and freq > 0.0:
			vibrato_time += 1.0 / SAMPLE_RATE
			if vibrato_time >= vibrato_delay:
				vibrato_phase = fposmod(vibrato_phase + vibrato_rate / SAMPLE_RATE, 1.0)
				var semis := sin(vibrato_phase * TAU) * vibrato_depth
				f = freq * pow(2.0, semis / 12.0)

		var out := 0.0
		match waveform:
			"pulse":
				out = 1.0 if phase < duty else -1.0
				if f > 0.0:
					phase = fposmod(phase + f / SAMPLE_RATE, 1.0)
			"triangle":
				out = 1.0 - 4.0 * abs(fposmod(phase + 0.25, 1.0) - 0.5)
				if f > 0.0:
					phase = fposmod(phase + f / SAMPLE_RATE, 1.0)
			"sawtooth":
				out = 2.0 * phase - 1.0
				if f > 0.0:
					phase = fposmod(phase + f / SAMPLE_RATE, 1.0)
			"noise":
				if f > 0.0:
					noise_acc += f / SAMPLE_RATE
					while noise_acc >= 1.0:
						noise_acc -= 1.0
						_clock_lfsr()
				out = 1.0 if (lfsr & 1) == 1 else -1.0

		## Envelope progression.
		if volume != target_volume:
			volume = move_toward(volume, target_volume, volume_step)
		else:
			match env_phase:
				"attack":
					if decay_step > 0.0:
						env_phase = "decay"
						target_volume = sustain_volume
						volume_step = decay_step
					else:
						env_phase = "sustain"
				"decay":
					env_phase = "sustain"
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

## Vibrato preset for sustained lead notes.
const VIB_DEPTH := 0.2   ## semitones
const VIB_RATE := 6.5    ## Hz
const VIB_DELAY := 0.07  ## seconds

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
	return {"freq": 200.0, "vol": 0.9, "short": false, "decay": 70.0}

func _snare() -> Dictionary:
	return {"freq": 6000.0, "vol": 0.6, "decay": 90.0}

func _hat() -> Dictionary:
	return {"freq": 9000.0, "vol": 0.28, "decay": 35.0}

func _octave_bass(roots: Array) -> Array:
	var out: Array = []
	for r in roots:
		var oct := int(r.substr(r.length() - 1, 1))
		var up = r.substr(0, r.length() - 1) + str(oct + 1)
		out.append(r); out.append(""); out.append(up); out.append("")
	return out
	
func _tone(arr: Array, i: int, vol: float, duty: float, decay: float, sustain: float, allow_vib: bool = true) -> Variant:
	var v: String = arr[i]
	if v == "":
		return null
	if v == "-":
		return {"note": "-"}
	var d := {"note": v, "vol": vol, "duty": duty, "decay": decay, "sustain": sustain}
	if allow_vib:
		var held := 0
		var j := i + 1
		while j < arr.size() and arr[j] == "-":
			held += 1
			j += 1
		if held >= 2:
			d["vib_depth"] = VIB_DEPTH
			d["vib_rate"] = VIB_RATE
			d["vib_delay"] = VIB_DELAY
	return d

func _ready() -> void:
	triangle.waveform = "triangle"
	noise.waveform = "noise"

	samples_per_step = int(SAMPLE_RATE * 60.0 / BPM / STEPS_PER_BEAT)
	samples_until_step = samples_per_step
	_build_song()
	pattern = song[0]

	var gen := AudioStreamGenerator.new()
	gen.mix_rate = SAMPLE_RATE
	gen.buffer_length = 0.15
	stream = gen
	play()
	playback = get_stream_playback()

	if playback == null:
		push_error("Stream playback is null after play(). ")

func _process(_delta: float) -> void:
	if playback == null:
		playback = get_stream_playback() as AudioStreamGeneratorPlayback
		if playback == null:
			return
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
	_apply_pulse(pulse1, row, "pulse1")
	_apply_pulse(pulse2, row, "pulse2")

	## Triangle bass: real NES triangle has NO volume envelope, so keep it flat
	## (no decay) - that flatness IS the authentic behavior here.
	if row.has("triangle"):
		var n3: Dictionary = row["triangle"]
		if n3["note"] != "-":
			triangle.set_note(_note_to_hz(n3["note"]), n3.get("vol", 0.85))
	else:
		triangle.note_off(120.0) ## short release keeps the bass arp articulated

	if row.has("noise"):
		var n4: Dictionary = row["noise"]
		noise.set_noise_hit(n4.get("freq", 4000.0), n4.get("vol", 0.6), n4.get("short", false), n4.get("decay", 0.0))
	else:
		noise.note_off(60.0)

func _apply_pulse(ch: Channel, row: Dictionary, key: String) -> void:
	if row.has(key):
		var n: Dictionary = row[key]
		if n["note"] == "-":
			return ## sustain: leave the envelope running, do not retrigger
		ch.set_note(
			_note_to_hz(n["note"]),
			n.get("vol", 0.8),
			n.get("duty", 0.5),
			n.get("decay", 120.0),
			n.get("sustain", 0.5),
			n.get("vib_depth", 0.0),
			n.get("vib_rate", 0.0),
			n.get("vib_delay", 0.0)
		)
	else:
		ch.note_off()

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
		_section_intro(),
		_section_main_a(),
		_section_main_a(),
		_section_development(),
		_section_main_b(),
		_section_main_a(),
		_section_main_a(),
		_section_development(),
		_section_main_b(),
	]


## INTRO SECTION 0:00-0:13
func _section_intro() -> Array:
	var rows: Array = []
	var bass := [
		"G2","","G2","G3", "G2","","G2","G3", "G2","","G2","G3", "G2","","G2","G3", \
		"G2","","G2","G3", "G2","","G2","G3", "F2","","D#2","",  "D2","","D2",""
	]
	## Gm arpeggio (G - Bb - D), stabbed and syncopated; last beat leans into A.
	var riff := [
		"G4","-","","",  "A#4","","G4","",  "D5","-","","",  "G4","","D5","", \
		"G4","-","","",  "A#4","","G4","",  "F4","","D#4","", "D5","-","-","-"
	]
	for step in range(32):
		var row: Dictionary = {}
		if bass[step] != "":
			row["triangle"] = {"note": bass[step], "vol": 0.85}
		var lp = _tone(riff, step, 0.5, 0.5, 110.0, 0.3)
		if lp != null:
			row["pulse1"] = lp
		if step % 8 == 0:
			row["noise"] = _kick()
		elif step % 8 == 4:
			row["noise"] = _snare()
		elif step >= 29:
			row["noise"] = _snare() ## fill into Theme A
		elif step % 2 == 1:
			row["noise"] = _hat()
		rows.append(row)
	return rows

## MAIN THEME A 0:13-0:33
func _section_main_a() -> Array:
	var rows: Array = []
	var bass := _octave_bass(["G2","G2","F2","F2", "D#2","D#2","D2","D2"])
	var lead := [
		"D5","-", "D5","-", "C5","-", "A#4","-",  "A4","-", "G4","-", "A#4","-","C5","-", \
		"D5","-", "D5","-", "D#5","D5","C5","-",   "A#4","-","A4","-", "G4","-", "-","-"
	]
	## Bright high stabs that punch the start of each phrase.
	var accents := {0: "D6", 8: "A#5", 16: "D6", 24: "A#5"}
	for step in range(32):
		var row: Dictionary = {}
		var lp = _tone(lead, step, 0.7, 0.5, 130.0, 0.55)
		if lp != null:
			row["pulse1"] = lp
		if accents.has(step):
			row["pulse2"] = {"note": accents[step], "duty": 0.125, "vol": 0.32, "decay": 60.0, "sustain": 0.0}
		if bass[step] != "":
			row["triangle"] = {"note": bass[step], "vol": 0.7}
		if step % 8 == 0:
			row["noise"] = _kick()
		elif step % 8 == 4:
			row["noise"] = _snare()
		elif step % 2 == 1:
			row["noise"] = _hat()
		rows.append(row)
	return rows

## DEVELOPMENT  0:33-0:55
func _section_development() -> Array:
	var rows: Array = []
	var bass := _octave_bass(["G2","A2","A#2","C3", "D3","D#3","F3","D3"])
	var lead := [
		"",   "G4", "A4", "A#4","",   "C5", "D5", "",   "D#5","F5", "",   "G5", "",   "F5", "D#5","D5", \
		"C5", "",   "A#4","",   "A4", "",   "G4", "",   "F4", "",   "D4", "",   "G4", "-",  "-",  "-"
	]
	var kicks := [0, 3, 6, 10, 14, 16, 19, 22, 26]
	var snares := [8, 13, 24, 29]
	for step in range(32):
		var row: Dictionary = {}
		var lp = _tone(lead, step, 0.8, 0.25, 90.0, 0.4)
		if lp != null:
			row["pulse1"] = lp
		if bass[step] != "":
			row["triangle"] = {"note": bass[step], "vol": 0.8}
		if step in kicks:
			row["noise"] = _kick()
		elif step in snares:
			row["noise"] = _snare()
		elif step % 4 == 2:
			row["noise"] = _hat()
		rows.append(row)
	return rows

## MAIN THEME B  0:55-1:18
func _section_main_b() -> Array:
	var rows: Array = []
	var bass := _octave_bass(["G2","G2","F2","F2", "D#2","D#2","D2","D2"])
	var lead := [
		"D5","-", "D5","-", "C5","-", "A#4","-",  "A4","-", "G4","-", "A#4","C5","D5","-", \
		"G5","-", "F5","-", "D#5","D5","C5","-",   "A#4","-","A4","-", "G4","-", "-","-"
	]
	## A third below the lead, kept in the G-minor scale.
	var harm := [
		"A#4","-","A#4","-","A4","-","G4","-",     "F4","-","D#4","-","G4","A4","A#4","-", \
		"D#5","-","D5","-", "C5","A#4","A4","-",    "F4","-","F4","-", "D#4","-","-","-"
	]
	for step in range(32):
		var row: Dictionary = {}
		var lp = _tone(lead, step, 0.9, 0.5, 150.0, 0.6)
		if lp != null:
			row["pulse1"] = lp
		var hp = _tone(harm, step, 0.4, 0.25, 150.0, 0.6)
		if hp != null:
			row["pulse2"] = hp
		if bass[step] != "":
			row["triangle"] = {"note": bass[step], "vol": 0.85}
		if step % 8 == 0 or step % 8 == 6:
			row["noise"] = _kick()
		elif step % 8 == 4:
			row["noise"] = _snare()
		elif step % 2 == 1:
			row["noise"] = _hat()
		rows.append(row)
	return rows
