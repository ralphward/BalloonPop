local M = {}

function M:getLevel(levelNum)

	if levelNum == 1 then
		return M:getLevel1()
	end
	return {}
end

function M:getLevel1()
	local E = {}

	E[1] = {fillColor = {1, 0, 0}, radius = 25, timerDelay = 500, xpos =  50}
	E[2] = {fillColor = {1, 0, 0}, radius = 30, timerDelay = 1000, xpos =  25}

	return E
end

return M