extends Node

# Background music
var music_player: AudioStreamPlayer = null
var current_music: AudioStream = null

# Sound effects
var sfx_players: Array[AudioStreamPlayer] = []
const MAX_SFX_PLAYERS = 10  # Allow multiple SFX to play simultaneously

# Volume controls
@export var music_volume: float = 0.5  # 0.0 to 1.0
@export var sfx_volume: float = 1.0  # 0.0 to 1.0 (louder for SFX)

# Music tracks
var background_music: AudioStream = null

func _ready():
	# Create music player
	music_player = AudioStreamPlayer.new()
	music_player.name = "MusicPlayer"
	music_player.volume_db = linear_to_db(music_volume)
	music_player.bus = "Master"
	add_child(music_player)
	
	# Create SFX players pool
	for i in range(MAX_SFX_PLAYERS):
		var sfx_player = AudioStreamPlayer.new()
		sfx_player.name = "SFXPlayer" + str(i)
		sfx_player.volume_db = linear_to_db(sfx_volume)
		sfx_player.bus = "Master"
		add_child(sfx_player)
		sfx_players.append(sfx_player)
	
	# Load background music
	load_background_music()
	
	# Start playing background music
	play_background_music()

func load_background_music():
	# Load the background music file
	var music_path = "res://sfx/1 Hour of Nintendo Cooking Music .mp3"
	if ResourceLoader.exists(music_path):
		background_music = load(music_path)
		print("AudioManager: Background music loaded")
	else:
		print("AudioManager: WARNING - Background music file not found at: ", music_path)

func play_background_music():
	if background_music and music_player:
		music_player.stream = background_music
		music_player.play()
		music_player.finished.connect(_on_music_finished)
		print("AudioManager: Background music started")

func _on_music_finished():
	# Loop the music
	if music_player:
		music_player.play()

func stop_background_music():
	if music_player:
		music_player.stop()

func set_music_volume(volume: float):
	music_volume = clamp(volume, 0.0, 1.0)
	if music_player:
		music_player.volume_db = linear_to_db(music_volume)

func set_sfx_volume(volume: float):
	sfx_volume = clamp(volume, 0.0, 1.0)
	for player in sfx_players:
		player.volume_db = linear_to_db(sfx_volume)

# SFX Functions - Add your sound effects here
func play_sfx(sound_path: String, pitch_scale: float = 1.0):
	# Find an available SFX player
	var available_player: AudioStreamPlayer = null
	for player in sfx_players:
		if not player.playing:
			available_player = player
			break
	
	# If all players are busy, use the first one (will interrupt)
	if not available_player:
		available_player = sfx_players[0]
	
	# Load and play the sound
	if ResourceLoader.exists(sound_path):
		var sound = load(sound_path)
		available_player.stream = sound
		available_player.pitch_scale = pitch_scale
		available_player.volume_db = linear_to_db(sfx_volume)  # Apply SFX volume
		available_player.play()
	else:
		print("AudioManager: WARNING - SFX file not found at: ", sound_path)

# Predefined SFX functions for common game events
func play_fridge_open():
	play_sfx("res://sfx/FRIDGE OPEN.mp3")

func play_fridge_close():
	play_sfx("res://sfx/FRIDGE CLOSE.mp3")

func play_cabinet_open():
	play_sfx("res://sfx/kitchen cupboard open.mp3")

func play_cabinet_close():
	play_sfx("res://sfx/kitchen cupboard close.mp3")

func play_cutting():
	play_sfx("res://sfx/cutting board.mp3")

func play_mixer():
	play_sfx("res://sfx/mixer.mp3")

func play_oven():
	play_sfx("res://sfx/OVEN.mp3")

func play_frying():
	play_sfx("res://sfx/FRYING.mp3")

func play_faucet():
	play_sfx("res://sfx/FAUCET.mp3")

func play_bell():
	play_sfx("res://sfx/bell-ring-390294.mp3")

func play_money():
	play_sfx("res://sfx/MONEY.mp3")

func play_angry_grunt():
	play_sfx("res://sfx/angry-grunt-103204.mp3")

func play_hmph():
	play_sfx("res://sfx/hmph-338183.mp3")

func play_order_taken():
	play_sfx("res://sfx/pencil-writing-on-paper-84424.mp3")
