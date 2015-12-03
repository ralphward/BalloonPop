local M = {}

function M:getLevel(levelNum)

	if levelNum == 1 then
		return M:getLevel1()
	else
		return M:getLevel1()
	end
	return {}
end

function M:getLevel1()
	local E = {}

	E[1] = {timerDelay = 500, xpos =  75, image = "./images/red_balloon.png"}
	E[2] = {timerDelay = 1000, xpos =  350, image = "./images/red_balloon.png"}
	E[3] = {timerDelay = 1300, xpos =  80, image = "./images/red_balloon.png"}
	E[4] = {timerDelay = 1600, xpos =  180, image = "./images/red_balloon.png"}
	E[5] = {timerDelay = 1900, xpos =  100, image = "./images/red_balloon.png"}
	E[6] = {timerDelay = 2100, xpos =  300, image = "./images/red_balloon.png"}
	E[7] = {timerDelay = 2400, xpos =  275, image = "./images/red_balloon.png"}

	return E
end

return M