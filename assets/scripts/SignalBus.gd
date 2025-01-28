extends Node

@warning_ignore("unused_signal")
signal day_end
@warning_ignore("unused_signal")
signal plant_watered
@warning_ignore("unused_signal")
signal interact
@warning_ignore("unused_signal")
signal cam_ready
@warning_ignore("unused_signal")
signal player_ready
@warning_ignore("unused_signal")
signal items_ready
@warning_ignore("unused_signal")
signal playerdata_ready
@warning_ignore("unused_signal")
signal invslot_clicked
@warning_ignore("unused_signal")
signal invslot_hovered
@warning_ignore("unused_signal")
signal invslot_unhovered
@warning_ignore("unused_signal")
signal inv_closed
@warning_ignore("unused_signal")
signal inv_opened
@warning_ignore("unused_signal")
signal new_dialogue
@warning_ignore("unused_signal")
signal item_given_to_npc
@warning_ignore("unused_signal")
signal dialogue_finished
@warning_ignore("unused_signal")
signal convotest
@warning_ignore("unused_signal")
signal play_random_song
@warning_ignore("unused_signal")
signal rain_start
@warning_ignore("unused_signal")
signal rain_end
@warning_ignore("unused_signal")
signal snow_start
@warning_ignore("unused_signal")
signal snow_end
@warning_ignore("unused_signal")
signal dawn_end
@warning_ignore("unused_signal")
signal dusk_start
signal midnight_debug

func emit(string):
	emit_signal(string)
	print("emitted: ", string)
