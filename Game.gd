extends Node

var current = 0 # 0 = left - 1 = right

var tempElapsed = 0
var diced = false
var dice = 0
var diceTime = 0
var diceCount = 0
var thinkTime = 0.5
var againCount = 0
var againMax = 3
var againRandom = 7
var enemyAgainMax = 3

var diceMovement = 0

var playerScore = 0
var playerRoundScore = 0

var currentEnemy = 0
var enemies = ["rat", "cat", "rabbit", "dog", "monkey", "bear", "cow", "dragon", "pig"]

var lives = 3
var extraLife = false
var extraLifeLimit = 0

const colorActive = Color("#ffffff")
const colorInactive = Color("#909090")
const assetPath = "res://assets/" 
const imagePath = assetPath + "image/"
const texFileExt = ".png"

var playTest = false # demo mode
var music = true
var effects = true	
var tougher = false
var speedRun = false

var saveGame = File.new() #file
var highScorePath = "user://highscore.save" 
var highScoreData = {"1": 4000, "2": 3000, "3": 2000, "4": 1000, "5": 500} 

var settingsPath = "user://settings.save"
var settingsData = {"FullScreen": 0, "Music": 1, "SoundEffects": 1, "Tougher": 0, "FastMode": 0}

func createHighScoreSave():
	saveGame.open(highScorePath, File.WRITE)
	saveGame.store_var(highScoreData)
	saveGame.close()
	
func createSettingsSave():
	saveGame.open(settingsPath, File.WRITE)
	saveGame.store_var(settingsData)
	saveGame.close()
	
func readHighScore():
	saveGame.open(highScorePath, File.READ) 
	highScoreData = saveGame.get_var() 
	saveGame.close() 
	
func readSettings():
	saveGame.open(settingsPath, File.READ) 
	settingsData = saveGame.get_var() 
	saveGame.close() 
	
func updateHighScoreLabels():
	$HighScoreView/Background/Label1.text = str(highScoreData["1"])
	$HighScoreView/Background/Label2.text = str(highScoreData["2"])
	$HighScoreView/Background/Label3.text = str(highScoreData["3"])
	$HighScoreView/Background/Label4.text = str(highScoreData["4"])
	$HighScoreView/Background/Label5.text = str(highScoreData["5"])

func updateSavedSettings():
	if bool(settingsData["FullScreen"]) and not OS.window_fullscreen:
		OS.set_window_fullscreen(true)
	elif not bool(settingsData["FullScreen"]) and OS.window_fullscreen:
		OS.set_window_fullscreen(false)
		
	music = bool(settingsData["Music"])
	if music:
		$MusicPlayer.play()
	else:
		$MusicPlayer.stop()
		
	effects = bool(settingsData["SoundEffects"])
	tougher = bool(settingsData["Tougher"])
	speedRun = bool(settingsData["FastMode"])
	
	updateSettings()

func saveHighScore(highScore):
	
	var scores = []
	for score in highScoreData:
		scores.append(highScoreData[score])
		
	scores.append(highScore)
	scores.sort()
	scores.pop_front()
	
	if not scores.count(highScore):
		return false
	
	highScoreData.clear()
	
	highScoreData["1"] = scores[4]
	highScoreData["2"] = scores[3]
	highScoreData["3"] = scores[2]
	highScoreData["4"] = scores[1]
	highScoreData["5"] = scores[0]
	
	saveGame.open(highScorePath, File.WRITE) 
	saveGame.store_var(highScoreData) 
	saveGame.close() 
	
	updateHighScoreLabels()
	return true

func saveSettings():
	
	settingsData["FullScreen"] = bool(OS.window_fullscreen)
	settingsData["Music"] = bool(music)
	settingsData["SoundEffects"] = bool(effects)
	settingsData["Tougher"] = bool(tougher)
	settingsData["FastMode"] = bool(speedRun)
	
	saveGame.open(settingsPath, File.WRITE) 
	saveGame.store_var(settingsData) 
	saveGame.close()

func _ready():
	randomize()
	
	if not saveGame.file_exists(settingsPath):
		createSettingsSave()
	else:
		readSettings()
		updateSavedSettings()
	
	if not saveGame.file_exists(highScorePath):
		createHighScoreSave()
	else:
		readHighScore()
	
	updateHighScoreLabels()
	
	set_process(true)
	updateSettings()
	
	newGame()
	resetPlayerScore()
	loadEnemy()
	
func loadEnemy():
	$Player2.texture = load(imagePath + enemies[currentEnemy] + texFileExt)
	
	var level = 0
	if currentEnemy < 3:
		level = 0
	elif currentEnemy < 6:
		level = 3
	else:
		level = 6
	
	$enemy1.texture = load(imagePath + enemies[level] + texFileExt)
	if level < currentEnemy:
		$enemy1.modulate = colorInactive
	else:
		$enemy1.modulate = colorActive
	$enemy2.texture = load(imagePath + enemies[level + 1] + texFileExt)
	if level + 1 < currentEnemy:
		$enemy2.modulate = colorInactive
	else:
		$enemy2.modulate = colorActive
	$enemy3.texture = load(imagePath + enemies[level + 2] + texFileExt)
	if level + 2 < currentEnemy:
		$enemy3.modulate = colorInactive
	else:
		$enemy3.modulate = colorActive
		
	$LevelProgress.value = currentEnemy
	updateInfos()
	
func nextEnemy():
	currentEnemy = (currentEnemy + 1) % enemies.size()
	loadEnemy()
	
func updateLives():
	$pig1.modulate = colorActive
	$pig2.modulate = colorActive
	$pig3.modulate = colorActive
	if lives <= 2:
		$pig3.modulate = colorInactive
	if lives <= 1:
		$pig2.modulate = colorInactive
	if lives == 0:
		$pig1.modulate = colorInactive
		
func updateInfos():
	var rand = randi() % 4
	
	if currentEnemy == 0:
		match rand:
			0: $Player2Name.text = "Chuck E. Cheese"
			1: $Player2Name.text = "Nigel Ratburn"
			2: $Player2Name.text = "Remy the Rat"
			3: $Player2Name.text = "Professor Ratigan"
		$Player2Info.text = ""
		enemyAgainMax = 2
		againRandom = 4
	elif currentEnemy == 1:
		match rand:
			0: $Player2Name.text = "Cindy Clawford"
			1: $Player2Name.text = "Cat Damon"
			2: $Player2Name.text = "Catzilla"
			3: $Player2Name.text = "The Great Catsby"
		$Player2Info.text = "x2"
		enemyAgainMax = 2
		extraLife = true
		extraLifeLimit = 200
		againRandom = 5
	elif currentEnemy == 2:
		match rand:
			0: $Player2Name.text = "Harry Hopper"
			1: $Player2Name.text = "Rabbit De Niro"
			2: $Player2Name.text = "Eddie Rabbit"
			3: $Player2Name.text = "David Hasselhop"
		$Player2Info.text = "x2"
		enemyAgainMax = 3
		extraLife = true
		extraLifeLimit = 300
		againRandom = 6
	elif currentEnemy == 3:
		match rand:
			0: $Player2Name.text = "The Notorious D.O.G."
			1: $Player2Name.text = "Captain Sniffer"
			2: $Player2Name.text = "Miss Furbulous"
			3: $Player2Name.text = "Santa Paws"
		$Player2Info.text = "x3"
		enemyAgainMax = 3
		againRandom = 7
	elif currentEnemy == 4:
		match rand:
			0: $Player2Name.text = "Bubbles The Chimp"
			1: $Player2Name.text = "Curious George"
			2: $Player2Name.text = "Mighty J. Young"
			3: $Player2Name.text = "Space Albert"
		$Player2Info.text = "x3"
		enemyAgainMax = 4
		extraLife = true
		extraLifeLimit = 300
		againRandom = 8
	elif currentEnemy == 5:
		match rand:
			0: $Player2Name.text = "Lazy Bear"
			1: $Player2Name.text = "Fuzzy Wuzzy"
			2: $Player2Name.text = "Mr. Goodbear"
			3: $Player2Name.text = "Wojtek the Soldier"
		$Player2Info.text = "x4"
		enemyAgainMax = 4
		extraLife = true
		extraLifeLimit = 300
		againRandom = 9
	elif currentEnemy == 6:	
		match rand:
			0: $Player2Name.text = "MooDonna"
			1: $Player2Name.text = "Mrs. Buttercup"
			2: $Player2Name.text = "Mooham Ed"
			3: $Player2Name.text = "Bessie Milkshake"
		$Player2Info.text = "x4"
		enemyAgainMax = 5
		extraLife = true
		extraLifeLimit = 400
		againRandom = 10
	elif currentEnemy == 7:	
		match rand:
			0: $Player2Name.text = "Pep Falcor"
			1: $Player2Name.text = "Elliot Drakhead"
			2: $Player2Name.text = "Zag Reptar"
			3: $Player2Name.text = "Drogon Magneto"
		$Player2Info.text = "x5"
		enemyAgainMax = 5
		againRandom = 11
	elif currentEnemy == 8:	
		match rand:
			0: $Player2Name.text = "Chris P. Bacon"
			1: $Player2Name.text = "Albert Einswine"
			2: $Player2Name.text = "Piggie Smalls"
			3: $Player2Name.text = "Amy Swinehouse"
		$Player2Info.text = "x6"
		enemyAgainMax = 5
		againRandom = 12
		
	if not tougher and extraLife and (lives < 3):
		$Player2Info.text += "  (" + str(extraLifeLimit) + " > 1UP)" 
					
func updatePlayerScore():
	if playerScore == 0:
		$ScoreValue.text = str(playerRoundScore)
	elif playerRoundScore == 0:
		$ScoreValue.text = str(playerScore)
	else:
		$ScoreValue.text = str(playerScore) + " + " + str(playerRoundScore)
	
func resetPlayerScore():
	playerScore = 0
	playerRoundScore = 0
	updatePlayerScore()
	
func addPlayerRoundScore(score):
	playerRoundScore = playerRoundScore + score
	updatePlayerScore()
	
func addPlayerScore():
	var multi = 1
	if currentEnemy == 1 or currentEnemy == 2:
		multi = 2
	elif currentEnemy == 3 or currentEnemy == 4:
		multi = 3
	elif currentEnemy == 5 or currentEnemy == 6:
		multi = 4
	elif currentEnemy == 7:
		multi = 5
	elif currentEnemy == 8:
		multi = 6
		
	if not tougher and extraLife and (playerRoundScore >= extraLifeLimit) and (lives < 3):
		lives += 1
		updateLives()
	
	playerScore += playerRoundScore * multi
	playerRoundScore = 0
	updatePlayerScore()
	
func resetPlayerRoundScore():
	playerRoundScore = 0;
	updatePlayerScore()
	
func newGame():
	$Player1Score.text = str(0)
	$Player2Score.text = str(0)
	$RoundScore.text = str(0)
	$RoundScore.modulate = colorInactive
	switchToPlayer1()
	$SpeechAnger.visible = false
	
var thinkingBlinking = 0	
	
func _process(delta):
	tempElapsed = tempElapsed + delta
	
	if diced:
		if tempElapsed < diceTime:
			diceMovement = diceMovement + delta
			if diceMovement >= 0.03:
				$Dice.frame = randi() % 6
				diceMovement = 0
		else:
			diced = false
			$Dice.frame = dice
			handleDice()
			
			if playTest or (current == 1):
				setThinkTime()
					
	elif playTest or (current == 1):
		if tempElapsed < thinkTime:
			if thinkingBlinking < 0:
				$Thinking.visible = false
				thinkingBlinking = randi() % 33
			else:
				if current == 1:
					$Thinking.visible = true
				thinkingBlinking -= 1
			
			return;
			
		$Thinking.visible = false
			
		var finish = false
		if current == 0:
			finish = (int($Player1Score.text) + int($RoundScore.text)) >= 100
		else:
			finish = (int($Player2Score.text) + int($RoundScore.text)) >= 100
			
		var seek = false
		if current == 0:
			seek = int($Player2Score.text) - int($Player1Score.text) - int($RoundScore.text) > 10
		else:
			seek = int($Player1Score.text) - int($Player2Score.text) - int($RoundScore.text) > 10
			
		var seekToWin = false
		if current == 0:
			seekToWin = (int($Player2Score.text) > 87) and (int($Player1Score.text) > 55)
		else:
			seekToWin = (int($Player1Score.text) > 87) and (int($Player2Score.text) > 55)
			
		var urgentSeekToWin = false
		if current == 0:
			urgentSeekToWin = (int($Player2Score.text) > 93) and (int($Player1Score.text) > 80)
		else:
			urgentSeekToWin = (int($Player1Score.text) > 93) and (int($Player2Score.text) > 80)
			
		if (current == 1) and (urgentSeekToWin or seekToWin):
			$SpeechAnger.visible = true
		else:
			$SpeechAnger.visible = false
		
		var tooSmall = int($RoundScore.text) <= 4
		var again = randi() % againRandom
		
		if ((again == 0) and !seek and !tooSmall and !seekToWin) or ((againCount > againMax) and !urgentSeekToWin) or finish:
			if current == 0:
				roundPlayer1()
			else:
				roundPlayer2()
		else:
			dice()
			againCount = againCount + 1
				
	if int($Player1Score.text) >= 100:
		print("1 won: ", int($Player1Score.text), " - ", int($Player2Score.text), " - ", $ScoreValue.text) #debug
		addPlayerScore()
		nextEnemy()
		if currentEnemy == 0:
			checkHighScore(true)
				
			lives = 3
			resetPlayerScore()
			loadEnemy()
			updateLives()
		
		newGame()
	if int($Player2Score.text) >= 100:
		print("2 won: ", int($Player1Score.text), " - ", int($Player2Score.text), " - ", $ScoreValue.text) #debug
		resetPlayerRoundScore()
		newGame()
		lives -= 1
		if lives == 0:
			checkHighScore(false)	
			
			lives = 3
			currentEnemy = 0
			resetPlayerScore()
			loadEnemy()
			
		updateLives()
		updateInfos()
		
func checkHighScore(won):
	var text = "Game Over ! Try Again..."
	if won:
		text = "Wow.. You Won !"
	if saveHighScore(playerScore):
		text = "New Score: " + str(playerScore) + " - " + text
		
	$GameStateView/Background/Title.text = text
	$GameStateView.popup()	

func restartGame():
	currentEnemy = 0
	lives = 3
	resetPlayerScore()
	loadEnemy()
	updateLives()	
	newGame()

func setThinkTime():
	if speedRun:
		thinkTime = 0
	else:
		thinkTime = randf() * 2 + 0.5
		if current == 1:
			$Thinking.visible = true
	tempElapsed = 0

func _on_DiceButton_pressed():
	if !playTest && (current == 0):
		dice()

func dice():
	if diced:
		return
		
	dice = randi() % 6
	$Dice.frame = dice
	$DiceButton.disabled = true
	diced = true
	tempElapsed = 0
	diceMovement = 0
	
	var diceType = randi() % 4
	if diceType == 0:
		diceTime = 0.3
		if effects:
			$DiceAudio1.play()
	if diceType == 1:
		diceTime = 0.1
		if effects:
			$DiceAudio2.play()
	if diceType == 2:
		diceTime = 0.5
		if effects:
			$DiceAudio3.play()
	if diceType == 3:
		diceTime = 0.2
		if effects:
			$DiceAudio4.play()	

func _on_DiceHiddenButton_pressed():
	if !playTest && (current == 0):
		dice()
	
func handleDice():
	$DiceButton.disabled = false
	if dice == 0:
		$RoundScore.text = str(0) 
		$RoundScore.modulate = colorInactive
		if effects:
			$PigAudio.play()
		diceCount = 0
		if current == 0:
			switchToPlayer2()
		else:
			switchToPlayer1()
	else:
		$RoundScore.text = str(dice + 1 + int($RoundScore.text))
		$RoundScore.modulate = colorActive
		diceCount = diceCount + 1

func roundPlayer2():
	if int($RoundScore.text) == 0:
		return
		
	$Player2Score.text = str(int($RoundScore.text) + int($Player2Score.text))
	$RoundScore.text = str(0)
	$RoundScore.modulate = colorInactive
	switchToPlayer1()
	if effects:
		$HoldAudio.play()
	diceCount = 0
	
func roundPlayer1():
	if int($RoundScore.text) == 0:
		return
	
	$Player1Score.text = str(int($RoundScore.text) + int($Player1Score.text))
	addPlayerRoundScore(int($RoundScore.text) * diceCount)
	$RoundScore.text = str(0)
	$RoundScore.modulate = colorInactive
	switchToPlayer2()
	if effects:
		$HoldAudio.play()
	diceCount = 0
	
func _on_RoundButton_pressed():
	if !playTest && (current == 0):
		roundPlayer1()

func _on_ArrowLeft_pressed():
	if !playTest && (current == 0):
		roundPlayer1()
	
func switchToPlayer1():
	$ArrowRight.modulate = colorInactive
	$ArrowRight.disabled = true
	$Player2Score.modulate = colorInactive
	$ArrowLeft.modulate = colorActive
	$ArrowLeft.disabled = false
	$Player1Score.modulate = colorActive
	current = 0
	doCPU()
	$Thinking.visible = false
	
func switchToPlayer2():
	$ArrowLeft.modulate = colorInactive
	$ArrowLeft.disabled = true
	$Player1Score.modulate = colorInactive
	$ArrowRight.modulate = colorActive
	$ArrowRight.disabled = false
	$Player2Score.modulate = colorActive
	current = 1
	doCPU()
	
func doCPU():	
	setThinkTime()
	againCount = 0
	againMax = randi() % enemyAgainMax + 1

func _on_MenuButton_pressed():
	$MenuView.popup()

func _on_ScoreButton_pressed():
	$HighScoreView.popup()

func _on_NewGame_pressed():
	restartGame()
	$MenuView.hide()

func _on_Quit_pressed():
	get_tree().quit()

func _on_Instruments_pressed():
	$InstructionsView.popup()

func _on_Settings_pressed():
	$SettingsView.popup()
	
func updateSettings():
	if OS.window_fullscreen: 
		$SettingsView/Background/FullScreenButton.text = "On"
	else:
		$SettingsView/Background/FullScreenButton.text = "Off"
		
	if music:
		$SettingsView/Background/MusicButton.text = "On"
	else:
		$SettingsView/Background/MusicButton.text = "Off"
		
	if effects:
		$SettingsView/Background/EffectsButton.text = "On"
	else:
		$SettingsView/Background/EffectsButton.text = "Off"
		
	if tougher:
		$SettingsView/Background/TougherButton.text = "On"
	else:
		$SettingsView/Background/TougherButton.text = "Off"
		
	if speedRun:
		$SettingsView/Background/FastModeButton.text = "On"
	else:
		$SettingsView/Background/FastModeButton.text = "Off"
		
	if playTest:
		$DemoButton.modulate = colorActive
	else:
		$DemoButton.modulate = colorInactive

func _on_FullScreenButton_pressed():
	if OS.window_fullscreen:
		OS.set_window_fullscreen(false)
		$SettingsView/Background/FullScreenButton.text = "Off"
	else:
		OS.set_window_fullscreen(true)
		$SettingsView/Background/FullScreenButton.text = "On"
		
	saveSettings()

func _on_MusicButton_pressed():
	if music:
		$MusicPlayer.stop()
		music = false;
		$SettingsView/Background/MusicButton.text = "Off"
	else:
		$MusicPlayer.play()
		music = true
		$SettingsView/Background/MusicButton.text = "On"
		
	saveSettings()

func _on_EffectsButton_pressed():
	if effects:
		effects = false;
		$SettingsView/Background/EffectsButton.text = "Off"
	else:
		effects = true
		$SettingsView/Background/EffectsButton.text = "On"
		
	saveSettings()

func _on_TougherButton_pressed():
	if tougher:
		tougher = false;
		$SettingsView/Background/TougherButton.text = "Off"
	else:
		tougher = true
		$SettingsView/Background/TougherButton.text = "On"
	
	saveSettings()

func _on_FastModeButton_pressed():
	if speedRun:
		speedRun = false;
		$SettingsView/Background/FastModeButton.text = "Off"
	else:
		speedRun = true
		$SettingsView/Background/FastModeButton.text = "On"
		
	saveSettings()

func _on_Credits_pressed():
	$CreditsView.popup()

func _on_Link_pressed():
	OS.shell_open("https://lava-block.com")

func _on_DemoButton_pressed():
	playTest = not playTest
	restartGame()
	
	if playTest:
		$DemoButton.modulate = colorActive
	else:
		$DemoButton.modulate = colorInactive
