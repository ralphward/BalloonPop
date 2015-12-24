M = {}

M.currentScoreDisplay = ""  -- will be a display.newText() that draws the score on the screen
M.currentTopScore  = ""     -- will be a display.newText() that draws the to score on the screen
M.currentScore = 0          -- used to hold the numeric value of the current score
M.topScore = 0              -- will be used to store the best score for this level
M.timers = {}
M.g_enemies = {}
M.state = "playing"
M.fireState = 0

return M