M = {}
M.maxLevels = 20
M.levelScore = 0
M.products = {}
M.settings = {}
M.settings.currentLevel = 1
M.settings.unlockedLevels = 1
M.settings.bestScore = 0
M.settings.soundOn = true
M.settings.musicOn = true
M.settings.levels = {} 
M.settings.levels[1] = {}
M.settings.levels[1].topScore = 0
-- levels data members:
--      .stars -- Stars earned per level
--      .score -- Score for the level
-- 		.energyBonus -- Bonus for unused energy
return M