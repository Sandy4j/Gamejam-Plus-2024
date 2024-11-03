extends AudioStreamPlayer2D

const mainM_song = preload("res://Music/Sid - Gameplay Hg 2024-11-02 19_01_02-11-24_19-02-16-535 (1).wav")
const L1_song = preload("res://Music/24 12.58_011033.wav")

func play_music(music: AudioStream):
	if stream == music:
		return
	stream = music
	play()
	

func play_bgm(v:int):
	if v == 1:
		play_music(L1_song)
		return
	else:
		play_music(mainM_song)
