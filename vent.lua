local CBE = require("CBE.CBE")

local M = CBE.newVent({
    preset = "fountain",
    title = "explosion",

    positionType = "inRadius",
    color = {{1, 0, 0}, {0.9, 0, 0}, {0.7, 0, 0}},
    particleProperties = {blendMode = "add"},
    emitX = display.contentCenterX,
    emitY = display.contentCenterY,

    emissionNum = 5,
    emitDelay = 5,
    perEmit = 1,

    inTime = 100,
    lifeTime = 0,
    outTime = 200,

    onCreation = function(particle)
        particle:changeColor({
            color = {0.1, 0.1, 0.1},
            time = 600
        })
    end,

    onUpdate = function(particle)
        particle:setCBEProperty("scaleRateX", particle:getCBEProperty("scaleRateX") * 0.998)
        particle:setCBEProperty("scaleRateY", particle:getCBEProperty("scaleRateY") * 0.998)
    end,

    physics = {
        velocity = 0,
        gravityY = 0,
        angles = {0, 360},
        scaleRateX = 1,
        scaleRateY = 1
    }
})


return M