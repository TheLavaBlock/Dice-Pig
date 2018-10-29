extends Node

var dice = 0 # range 0 - 5
var turnPoints = 0 # 0 - 100
var player1Points = 0 # 0 - 100
var player1Total = 0
var player2Points = 0 # 0 - 100
var player2Total = 0
var currentPlayer = 0 # 0 - 1
var maxPoints = 30
onready var delay = get_node("Timer")

const colorActive = Color("#ffffff")
const colorInactive = Color("#bbbbbb")
const colorWon = Color("#ff0000")

func _ready():
	randomize()	# get random numbers for dice
	
	# reset game state
	resetTurnPoints()
	resetPlayerPoints()
	setCurrentPlayer(0) # set to Player 1
	
func resetTurnPoints():
	turnPoints = 0
	$Turn/Points.text = str(0)
	
func resetPlayerPoints():
	player1Points = 0
	$Player1/Points.text = str(0)
	player2Points = 0
	$Player2/Points.text = str(0)
	
func setCurrentPlayer(player):
	currentPlayer = player
	if currentPlayer == 0:
		$Player1/Points.modulate = colorActive
		$Player2/Points.modulate = colorInactive
		$Turn/Left.modulate = colorActive
		$Turn/Left.disabled = false
		$Turn/Right.modulate = colorInactive
		$Turn/Right.disabled = true
	else:
		$Player1/Points.modulate = colorInactive
		$Player2/Points.modulate = colorActive
		$Turn/Left.modulate = colorInactive
		$Turn/Left.disabled = true
		$Turn/Right.modulate = colorActive
		$Turn/Right.disabled = false
		
func setNextPlayer():
	resetTurnPoints()
	if currentPlayer == 0:
		setCurrentPlayer(1)
	else:
		setCurrentPlayer(0)
		
func endGame():
	$Turn/Left.disabled = true
	$Turn/Right.disabled = true
	delay.start()
	yield(delay, "timeout")
	$Sound/Pig.play()
	$Turn/Right.modulate = colorInactive
	$Turn/Left.modulate = colorInactive
	_ready()
	
	
func _on_DiceButton_pressed():
	dice = randi() % 6
	$Dice.frame = dice # show animation frame for throw number
	if dice == 0:
		$Sound/Pig.play()
		setNextPlayer()
		return
		
	# play Dice sounds
	var diceType = randi() % 4
	if diceType == 0:
		$Sound/Dice1.play()
	if diceType == 1:
		$Sound/Dice2.play()
	if diceType == 2:
		$Sound/Dice3.play()
	if diceType == 3:
		$Sound/Dice4
	turnPoints += dice + 1
	$Turn/Points.text = str(turnPoints) 

func _on_Left_pressed():
	if turnPoints == 0:
		return
		
	$Sound/Hold.play()
		
	player1Points += turnPoints
	$Player1/Points.text = str(player1Points)
	if player1Points >= maxPoints:
		player1Total = player1Total + 1
		$Player1/Total1.text = str(player1Total)
		$Player1/Points.modulate = colorWon
		endGame()
	else:
		setNextPlayer()

func _on_Right_pressed():
	if turnPoints == 0:
		return
		
	$Sound/Hold.play()
		
	player2Points += turnPoints
	$Player2/Points.text = str(player2Points)
	if player2Points >= maxPoints:
		player2Total = player2Total + 1
		$Player2/Total2.text = str(player2Total)
		$Player2/Points.modulate = colorWon
		endGame()
	else:
		setNextPlayer()
