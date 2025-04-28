extends Node

@onready var npcs = {
	"Alien": "res://assets/scenes/npcs/alien.tscn",
	"Amooga Man": "res://assets/scenes/npcs/amooga_man.tscn",
	"Angler": "res://assets/scenes/npcs/angler.tscn",
	"Blurbo": "res://assets/scenes/npcs/blurbo.tscn",
	"Brant": "res://assets/scenes/npcs/brant.tscn",
	"Cheeto": "res://assets/scenes/npcs/cheeto.tscn",
	"CITYSIGN": "res://assets/scenes/npcs/CITYSIGN.tscn",
	"RoboCat*": "res://assets/scenes/npcs/city_robocat.tscn",
	"Catnip Dealer*": "res://assets/scenes/npcs/club_dealer.tscn",
	"Crystal": "res://assets/scenes/npcs/crystal.tscn",
	"Dad": "res://assets/scenes/npcs/dad.tscn",
	"Catnip Dealer": "res://assets/scenes/npcs/dealer.tscn",
	"Evil Ass Fucking Fish": "res://assets/scenes/npcs/evil_ass_fish.tscn",
	"Chubbs": "res://assets/scenes/npcs/fatcat.tscn",
	"Fergus": "res://assets/scenes/npcs/fergus.tscn",
	"Fini": "res://assets/scenes/npcs/fini.tscn",
	"Garebear": "res://assets/scenes/npcs/garebear.tscn",
	"Gerardo": "res://assets/scenes/npcs/gerardo.tscn",
	"Goldfish": "res://assets/scenes/npcs/goldfish.tscn",
	"Goober": "res://assets/scenes/npcs/goober_npc.tscn",
	"H4Z3L": "res://assets/scenes/npcs/hazel.tscn",
	"Chopped Fish": "res://assets/scenes/npcs/homerphish.tscn",
	"Howard": "res://assets/scenes/npcs/howard.tscn",
	"Jellina": "res://assets/scenes/npcs/jelly.tscn",
	"Jonny OrangeHands": "res://assets/scenes/npcs/jonnyoranghands.tscn",
	"Kedrick": "res://assets/scenes/npcs/ked.tscn",
	"Kwatos": "res://assets/scenes/npcs/kwatos.tscn",
	"Loan Shark": "res://assets/scenes/npcs/loanshark.tscn",
	"closet": "res://assets/scenes/npcs/lsbed.tscn",
	"bed": "res://assets/scenes/npcs/lscloset.tscn",
	"Mike": "res://assets/scenes/npcs/mike.tscn",
	"Mom": "res://assets/scenes/npcs/mom.tscn",
	"Cherri": "res://assets/scenes/npcs/monke.tscn",
	"Mozzie": "res://assets/scenes/npcs/mozzie.tscn",
	"Dad*": "res://assets/scenes/npcs/normaldad.tscn",
	"Phish": "res://assets/scenes/npcs/ogphish.tscn",
	"RAPTAR": "res://assets/scenes/npcs/raptor.tscn",
	"Scrappy": "res://assets/scenes/npcs/scrappy.tscn",
	"Scrappy*": "res://assets/scenes/npcs/shop_scrappy.tscn",
	"Schrodinger's Cat": "res://assets/scenes/npcs/shrod.tscn",
	"Sign": "res://assets/scenes/npcs/sign.tscn",
	"billy": "res://assets/scenes/npcs/testnpc.tscn",
	"Phanos": "res://assets/scenes/npcs/thanosfish.tscn",
	"Tralalerito": "res://assets/scenes/npcs/tralalerito.tscn",
	"Tralalero Tralala": "res://assets/scenes/npcs/tralalero.tscn",
	"Trippi Troppi": "res://assets/scenes/npcs/tttt.tscn",
	"Vincent": "res://assets/scenes/npcs/vincent.tscn",
	"BP": "res://assets/scenes/npcs/voidfish.tscn",
	"Washing Mashing": "res://assets/scenes/npcs/washingmashing.tscn",
	"RoboCat": "res://assets/scenes/npcs/water_robocat.tscn",
	"Xyler": "res://assets/scenes/npcs/xyler.tscn",
	"Gurt": "res://assets/scenes/npcs/gurt.tscn",
	"Gus": "res://assets/scenes/npcs/gus.tscn",
	"Big Dawg": "res://assets/scenes/npcs/bigdawg.tscn",
	"Bart Tender": "res://assets/scenes/npcs/bart.tscn"
}

var npc_folder_path = "res://assets/scenes/npcs/"
var cache = {} #npc name, (convo index, next locked)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_npcs()
	pass # Replace with function body.



func load_npcs():
	for name in npcs.keys():
		npcs[name] = load(npcs[name])

func get_npc(speakername: String) -> PackedScene:
	return npcs.get(speakername, null)

func load_cache(npc:NPC):
	if npc.npc_name == "Jellina":
		print("hi")
	if cache.has(npc.npc_name):
		npc.current_convo_index = cache[npc.npc_name][0]
		if cache[npc.npc_name][1] == true and cache[npc.npc_name][2] != null and not History.has_happened(cache[npc.npc_name][2]): #next convo locked
			npc.lock_current_convo()
		else:
			npc.unlock_current_convo()

func update_cache(npc:NPC):
	if npc.npc_name == "Jellina":
		print("hi")
	if not cache.has(npc.npc_name):
		cache[npc.npc_name] = [0, false, null]
	cache[npc.npc_name][0] = npc.current_convo_index
	if npc.get_next_convo() != null:
		cache[npc.npc_name][1] = npc.get_next_convo().locked
	if npc.get_current_convo() != null:
		if npc.get_current_convo().requests_signal:
			cache[npc.npc_name][2] = npc.get_current_convo().request_signal_name
