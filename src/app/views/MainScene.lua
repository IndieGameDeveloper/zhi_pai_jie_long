
local MainLayer = require("app.views.MainLayer")

local MainScene = class("MainScene", cc.load("mvc").ViewBase)

MainScene.RESOURCE_FILENAME = "MainScene.csb"

function MainScene:onCreate()
	self.mainLayer = MainLayer:new()
	self:addChild(self.mainLayer)
    print("sssss --- ")
end

return MainScene
