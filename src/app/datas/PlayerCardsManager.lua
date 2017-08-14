
--
-- Author: leeshuan
-- Date: 2016-04-21 17:20:23
--


CardValue = {1,2,3,4,5,6,7,8,9,10,11,12,13}

local CardData = require("app.datas.CardData")
local PlayerCardsManager = class("PlayerCardsManager")

function PlayerCardsManager:getInstance()
	if playerCardsManager_instance == nil then 
		playerCardsManager_instance = PlayerCardsManager:new()
	end
	return playerCardsManager_instance
end

function PlayerCardsManager:ctor()
	self.allCards = {}	
    for k,v in pairs(CardPosKind) do
    	self.allCards[k] = {}
    end

	self:initPlayerCards()
	self:initUnknowCards()
	self:initOrderingCards()
	self:initOrderedCards()
end

function PlayerCardsManager:initPlayerCards()   --初始化牌的值，种类
	self.playerCards = {}
	for k,ck in pairs(CardKind) do        	    --牌的种类(花色)
		for i,cv in ipairs(CardValue) do   		--牌的值
			local card = CardData.new()
			card.value = cv
			card.kind =  ck 
			card.posKind = 0 
			table.insert(self.playerCards,card)
		end
	end
end

function PlayerCardsManager:initUnknowCards()   --右上角未翻开的牌
	for i =1,24 do
	    math.randomseed(os.time())
	    local cardIndex = math.random(1,#self.playerCards)
	    local card = self.playerCards[cardIndex]
	    card.isSee = false
	    card.posKind = CardPosKind.unKnow
	    table.insert(self.allCards.unKnow,card)
	    table.remove(self.playerCards,cardIndex)
	end
end

function PlayerCardsManager:initOrderingCards()  --正在排序的拍
	for i=1,7 do
	   self.allCards.ordering[i] ={}
	   for k =1,i do 
	   	  math.randomseed(os.time())
	      local cardIndex = math.random(1,#self.playerCards)
	   	  local card = self.playerCards[cardIndex]
	   	  card.posKind = CardPosKind.ordering
	   	  card.isSee = false
	   	  table.insert(self.allCards.ordering[i],card)
	   	  table.remove(self.playerCards,cardIndex)
	   end
	   self.allCards.ordering[i][i].isSee = true
	   -- self.allCards.ordering[i][i].value =i


	   -- if i >1 then 
	   -- 		self.allCards.ordering[i][i-1].value =i+6
	   -- end
	   -- if i%2 == 0 then 
	   -- 		self.allCards.ordering[i][i].kind =CardKind.spade
	   -- 		self.allCards.ordering[i][i-1].kind =CardKind.spade
	   -- else
	   -- 		self.allCards.ordering[i][i].kind =CardKind.heart
	   -- 		if i >1 then 
	   -- 			self.allCards.ordering[i][i-1].kind =CardKind.heart
	   -- 		end
	   -- end
	end
end

function PlayerCardsManager:initOrderedCards()   -- 已经排好序的牌
	for i =1, 4 do 
		self.allCards.ordered[i] ={}
	end
end

function PlayerCardsManager:moveCard(indexCard,from,to)
	-- 对 from， to 进行数据解析
end

return PlayerCardsManager