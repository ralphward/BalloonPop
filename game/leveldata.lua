local M = {}


local function getStandardEnemy( p_timerDelay, p_xpos, p_id, p_rep_number )
    local enemy = {timerDelay = p_timerDelay, xpos =  p_xpos, image = "./images/red_balloon.png", id = p_id, rep_number = p_rep_number}
	return enemy
end 



function M:getLevel(levelNum)

	if levelNum == -1 then
		return M:getLevelEasy()		
	elseif levelNum == -2 then
		return M:getLevelHard()		
	elseif levelNum == 1 then
		return M:getLevel1()
	else
		return M:getLevelEasy()
	end
	return {}
end

function M:getLevel1()
	local E = {}

	E[1] = getStandardEnemy(500, 75, "a", 1)
	E[2] = getStandardEnemy(1000, 350, "b", 1)
	E[3] = getStandardEnemy(1300, 80, "c", 1)
	E[4] = getStandardEnemy(1600, 180, "d", 1)
	E[5] = getStandardEnemy(1900, 100, "e", 1)
	E[6] = getStandardEnemy(2100, 300, "f", 1)
	E[7] = getStandardEnemy(2400, 275, "g", 1)

	return E
end


function M:getLevelEasy()
	local E = {}
	E[1] = getStandardEnemy(500, 75, "a", 1)
	E[2] = getStandardEnemy(1000, 350, "b", 1)

	return E

end

function M:getLevelHard()
	local E = {}

	E[1] = getStandardEnemy(500, 75, "a", 0)
	E[2] = getStandardEnemy(1000, 350, "b", 0)
	E[3] = getStandardEnemy(1300, 80, "c", 0)
	E[4] = getStandardEnemy(1600, 180, "d", 0)
	E[5] = getStandardEnemy(1900, 100, "e", 0)
	E[6] = getStandardEnemy(2100, 300, "f", 0)
	E[7] = getStandardEnemy(2400, 275, "g", 0)

	return E
end

return M