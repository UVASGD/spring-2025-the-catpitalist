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
signal pause_opened
signal pause_closed
signal tutorial_planted
signal tutorial_watered
signal tutorial_pickup
signal spawn_seeds
signal mom_dialogue_done
signal shop_price_change
signal cant_afford_item
signal cant_hold_item
signal unlock_farmhouse
signal unlock_city
signal start_loanshark_quest
signal made_1000
signal gift_100
signal chubbs_move
signal unlock_water
signal jellina_mentioned
signal unlock_junkyard
signal entered_junkyard
signal tutorial_finished
signal made_10000
signal made_100000
signal made_1000000
signal made_10000000
signal made_100000000
signal scrappy_shop_closed
signal unlock_scrappy_shop_again
signal start_loan_shark_animation
signal end_loanshark_quest
signal give_suit
signal unlock_loan_shark_house
signal cheeto_move
signal cheeto_can_move
signal emo_hazel
signal final_hazel
signal give_strange_piece
signal ask_for_robocat
signal delete_water_robocat
signal repair_rocket
signal alien_learn_english
signal beanstalk_grew
func emit(string):
	emit_signal(string)
	print("emitted: ", string)
