extends Node
var is_flush = false
const CARD_CHANCE=2
var player_ref

func _ready() -> void:
	player_ref = $"../Player"
	
const Straight_flush = [ ["Ace_Club", "King_Club", "Queen_Club", "Jack_Club", "Ten_Club"], ["King_Club", "Queen_Club", "Jack_Club", "Ten_Club", "Nine_Club"],
[ "Queen_Club", "Jack_Club", "Ten_Club", "Nine_Club", "Eight_Club"], ["Jack_Club", "Ten_Club", "Nine_Club", "Eight_Club", "Seven_Club"], ["Ten_Club", "Nine_Club", "Eight_Club", "Seven_Club", "Six_Club"], 
["Nine_Club", "Eight_Club", "Seven_Club", "Six_Club", "Five_Club"], ["Eight_Club", "Seven_Club", "Six_Club", "Five_Club", "Four_Club"], ["Seven_Club", "Six_Club", "Five_Club", "Four_Club", "Three_Club"], 
["Six_Club", "Five_Club", "Four_Club", "Three_Club", "Two_Club"], ["Five_Club", "Four_Club", "Three_Club", "Two_Club", "Ace_Club"],

["Ace_Diamond", "King_Diamond", "Queen_Diamond", "Jack_Diamond", "Ten_Diamond"], ["King_Diamond", "Queen_Diamond", "Jack_Diamond", "Ten_Diamond", "Nine_Diamond"],
[ "Queen_Diamond", "Jack_Diamond", "Ten_Diamond", "Nine_Diamond", "Eight_Diamond"], ["Jack_Diamond", "Ten_Diamond", "Nine_Diamond", "Eight_Diamond", "Seven_Diamond"], ["Ten_Diamond", "Nine_Diamond", "Eight_Diamond", "Seven_Diamond", "Six_Diamond"], 
["Nine_Diamond", "Eight_Diamond", "Seven_Diamond", "Six_Diamond", "Five_Diamond"], ["Eight_Diamond", "Seven_Diamond", "Six_Diamond", "Five_Diamond", "Four_Diamond"], ["Seven_Diamond", "Six_Diamond", "Five_Diamond", "Four_Diamond", "Three_Diamond"], 
["Six_Diamond", "Five_Diamond", "Four_Diamond", "Three_Diamond", "Two_Diamond"], ["Five_Diamond", "Four_Diamond", "Three_Diamond", "Two_Diamond", "Ace_Diamond"],

["Ace_Heart", "King_Heart", "Queen_Heart", "Jack_Heart", "Ten_Heart"], ["King_Heart", "Queen_Heart", "Jack_Heart", "Ten_Heart", "Nine_Heart"],
[ "Queen_Heart", "Jack_Heart", "Ten_Heart", "Nine_Heart", "Eight_Heart"], ["Jack_Heart", "Ten_Heart", "Nine_Heart", "Eight_Heart", "Seven_Heart"], ["Ten_Heart", "Nine_Heart", "Eight_Heart", "Seven_Heart", "Six_Heart"], 
["Nine_Heart", "Eight_Heart", "Seven_Heart", "Six_Heart", "Five_Heart"], ["Eight_Heart", "Seven_Heart", "Six_Heart", "Five_Heart", "Four_Heart"], ["Seven_Heart", "Six_Heart", "Five_Heart", "Four_Heart", "Three_Heart"], 
["Six_Heart", "Five_Heart", "Four_Heart", "Three_Heart", "Two_Heart"], ["Five_Heart", "Four_Heart", "Three_Heart", "Two_Heart", "Ace_Heart"],

["Ace_Spade", "King_Spade", "Queen_Spade", "Jack_Spade", "Ten_Spade"], ["King_Spade", "Queen_Spade", "Jack_Spade", "Ten_Spade", "Nine_Spade"],
[ "Queen_Spade", "Jack_Spade", "Ten_Spade", "Nine_Spade", "Eight_Spade"], ["Jack_Spade", "Ten_Spade", "Nine_Spade", "Eight_Spade", "Seven_Spade"], ["Ten_Spade", "Nine_Spade", "Eight_Spade", "Seven_Spade", "Six_Spade"], 
["Nine_Spade", "Eight_Spade", "Seven_Spade", "Six_Spade", "Five_Spade"], ["Eight_Spade", "Seven_Spade", "Six_Spade", "Five_Spade", "Four_Spade"], ["Seven_Spade", "Six_Spade", "Five_Spade", "Four_Spade", "Three_Spade"], 
["Six_Spade", "Five_Spade", "Four_Spade", "Three_Spade", "Two_Spade"], ["Five_Spade", "Four_Spade", "Three_Spade", "Two_Spade", "Ace_Spade"] ] 

const RANKS = ["2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"]
const RANK_MAP = {
	"Two": "2", "Three": "3", "Four": "4", "Five": "5",
	"Six": "6", "Seven": "7", "Eight": "8", "Nine": "9",
	"Ten": "10", "Jack": "J", "Queen": "Q", "King": "K", "Ace": "A"
}
const SUIT_MAP = {
	"Spade": "S",
	"Heart": "H",
	"Diamond": "D",
	"Club": "C"
}

enum HandRank {
	HIGH_CARD,
	ONE_PAIR,
	TWO_PAIR,
	THREE_OF_A_KIND,
	STRAIGHT,
	FLUSH,
	FULL_HOUSE,
	FOUR_OF_A_KIND,
	STRAIGHT_FLUSH,
	ROYAL_FLUSH
}

enum GameStages {
	pre, 
	flop, 
	turn, 
	river, 
	showdown
}

func parse_card(card_str: String) -> Dictionary:
	var parts = card_str.split("_")
	var rank = RANK_MAP.get(parts[0], "")
	var suit = SUIT_MAP.get(parts[1], "")
	return {"rank": rank, "suit": suit}

func evaluate_hand(card_strs: Array) -> int:
	var cards = []
	for c in card_strs:
		cards.append(parse_card(c))
	print("cards: ", cards)
	var values = []
	var suits = []
	for c in cards:
		values.append(c["rank"])
		suits.append(c["suit"])

	var rank_counts = {}
	for v in values:
		rank_counts[v] = rank_counts.get(v, 0) + 1

	var unique_counts = rank_counts.values()
	unique_counts.sort()

	var flush = suits.all(func(s): s == suits[0])

	var idxs = []

	for v in values:
		if RANKS.has(v):
			idxs.append(RANKS.find(v))

	idxs.sort()
	var straight = false
	if idxs.size() >= 5:
		straight = idxs == range(idxs[0], idxs[0] + 5)

	var sorted_values = values.duplicate()
	sorted_values.sort()
	if sorted_values == ["2", "3", "4", "5", "A"]:
		straight = true

	var sorted_hand = card_strs.duplicate()
	sorted_hand.sort()
	if Straight_flush.has(sorted_hand):
		if values.has("A"):
			return HandRank.ROYAL_FLUSH
		else:
			return HandRank.STRAIGHT_FLUSH

	if 4 in unique_counts:
		return HandRank.FOUR_OF_A_KIND
	if 3 in unique_counts and 2 in unique_counts:
		return HandRank.FULL_HOUSE
	if flush:
		return HandRank.FLUSH
	if straight:
		return HandRank.STRAIGHT
	if 3 in unique_counts:
		return HandRank.THREE_OF_A_KIND
	if unique_counts.count(2) == 2:
		return HandRank.TWO_PAIR
	if 2 in unique_counts:
		return HandRank.ONE_PAIR
	return HandRank.HIGH_CARD

func hand_rank_to_string(rank: int) -> String:
	match rank:
		HandRank.ROYAL_FLUSH:
			return "Royal Flush"
		HandRank.STRAIGHT_FLUSH:
			return "Straight Flush"
		HandRank.FOUR_OF_A_KIND:
			return "Four of a Kind"
		HandRank.FULL_HOUSE:
			return "Full House"
		HandRank.FLUSH:
			return "Flush"
		HandRank.STRAIGHT:
			return "Straight"
		HandRank.THREE_OF_A_KIND:
			return "Three of a Kind"
		HandRank.TWO_PAIR:
			return "Two Pair"
		HandRank.ONE_PAIR:
			return "One Pair"
		_:
			return "High Card"

func out_chance(hand_rank:int, stage:int):
	var outs=0
	print("stage: ", stage)
	print("Card chance", CARD_CHANCE)
	if stage==GameStages.flop || stage==GameStages.turn:
		if hand_rank==0 && stage==GameStages.flop:
			outs+=(CARD_CHANCE)*(5*3)
		elif hand_rank==0 && stage==GameStages.turn:
			outs+=(CARD_CHANCE)*(6*3)
		if hand_rank==1 && stage==GameStages.flop:
			outs+=((CARD_CHANCE)*2 + (CARD_CHANCE)*(3*3))
		elif hand_rank==1 && stage==GameStages.turn:
			outs+=((CARD_CHANCE)*2 + (CARD_CHANCE)*(4*3))
		if hand_rank==2 && stage==GameStages.flop:
			outs+=((CARD_CHANCE)*(2*2) + (CARD_CHANCE)*3)
		elif hand_rank==2 && stage==GameStages.turn:
			outs+=((CARD_CHANCE)*(2*2) + (CARD_CHANCE)*(2*3))
		if hand_rank==3:
			outs+=(CARD_CHANCE)
			outs+=(CARD_CHANCE)*(2*3)
		if hand_rank==4:
			outs+=(CARD_CHANCE)*4
		if hand_rank==6:
			outs+=(CARD_CHANCE)*3
	print("Outs: ", outs)
	return outs
	
func suggest_move(hand_rank:int, out_chance:int, stage: int):
	var move = "Call"
	if stage == GameStages.flop || stage==GameStages.pre:
		if player_ref.raise_check_user == true && hand_rank<1:
			move="Fold"
		elif player_ref.raise_check_user == false:
			if hand_rank>2:
				move= "Raise"
			elif hand_rank<2:
				move="Call"
	if stage == GameStages.turn:
		if player_ref.raise_check_user == true && hand_rank<1:
			move="Fold"
		elif player_ref.raise_check_user == false:
			if hand_rank>2:
				move= "Raise"
			elif hand_rank<2:
				move="Call"
	if stage == GameStages.river:
		if player_ref.raise_check_user == true && hand_rank<1:
			move="Fold"
		elif player_ref.raise_check_user == false:
			if hand_rank>2:
				move= "Raise"
			elif hand_rank<2:
				move="Call"
	return move
