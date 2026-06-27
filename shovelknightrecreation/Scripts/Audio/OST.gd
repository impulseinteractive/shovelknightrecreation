extends AudioStreamPlayer
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
		null
	
	func set_noise_hit(p_freq: float, p_volume: float, p_short: bool = false) -> void:
		null
	
	func note_off(release_samples: float = 400.0) -> void:
		null
	
	func next_sample() -> float:
		return 0.0
	
	func _clock_lfsr() -> void:
		null

const SAMPLE_RATE := 44100.0
const BPM := 180.0
const STEPS_PER_BEAT := 4 ## 16th note resolution. step = 1/16 note

const NOTE_OFFSETS := {
	"C": 0, "C#": 1, "D": 2, "D#": 3, "E": 4, "F": 5,
	"F#": 6, "G": 7, "G#": 8, "A": 9, "A#": 10, "B": 11,
}

var playback: AudioStreamGenerator
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

func _ready() -> void:
	null

func _process(_delta: float) -> void:
	null
