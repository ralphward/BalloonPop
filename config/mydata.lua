M = {}
M.maxLevels = 20
M.settings = {}
M.settings.currentLevel = 1
M.settings.unlockedLevels = 1
M.settings.soundOn = true
M.settings.musicOn = true
M.levels = {} 
M.levels[1] = {}
--M.levels[1].topScore = 0
M.survival = {}
M.survival[1] = {}
-- levels data members:
--      .stars -- Stars earned per level
-- 		.energyBonus -- Bonus for unused energy
return M  