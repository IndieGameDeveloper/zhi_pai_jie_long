local MainLayer = class("MainLayer",function () 
	return display.newLayer() 
end)

ordering_with =45

local PlayerCardsManager = require("app.datas.PlayerCardsManager")

function MainLayer:ctor()
	self:loadCSB()
	self._zOrder = 100
	self._isTouchOrdring = false;
	self._isNewGame = true
	self._moveCardData = {}
	self._moveCardSprite = {}
	self._cardPosTable = {}
    self._allCardSprite = {}
	self:getKindPos()
    self:displayCard()
    self:addTouchEvent()
end

function MainLayer:loadCSB()
	self._rootNode  = cc.CSLoader:getInstance():createNodeWithFlatBuffersFile("main_scene.csb") 
	self:addChild(self._rootNode)
	-- self:createCardSprite({	value = 1,kind  = 2})
end

function MainLayer:onEnter()
	-- print("onEnter-----------")
end

function MainLayer:getKindPos()
	self._cardPosRootNode = self._rootNode:getChildByName("card_root_node")  
	self._rootNode:getChildByName("backfbg_node"):setTouchEnabled(false)
	self._cardPosRootNode:setTouchEnabled(false)
	for k,i in pairs(CardPosKind) do
		self._cardPosTable[k] = {}
		if i == 1 then
			-- print("KindPos",k)
			for j =1,4 do 
				local orderedNode = self._cardPosRootNode:getChildByTag(i+j-1)
				table.insert(self._cardPosTable[k],orderedNode)
			end
		elseif i == 2 then 
			-- print("KindPos ",k)
			local unKnowNode = self._cardPosRootNode:getChildByTag(5)
			table.insert(self._cardPosTable[k],unKnowNode)
		elseif i == 3 then 
			-- print("KindPos",k)
			local knowNode = self._cardPosRootNode:getChildByTag(13)
			table.insert(self._cardPosTable[k],knowNode)
		elseif i == 4 then    --正在排序的
			-- print("KindPos",k)
			for j =1, 7 do 
				local orderingNode = self._cardPosRootNode:getChildByTag(6+j-1)
				table.insert(self._cardPosTable[k],orderingNode)
			end
		end
	end 
end

function MainLayer:displayCard()
	self:destroyAllCardSprite()
	local playerCardsManager = PlayerCardsManager:getInstance()
	--显示正在排序的图片
	local orderingCardDatas = playerCardsManager.allCards.ordering
	for i=1,7 do 
		for j =1, #orderingCardDatas[i] do 
			local card_data =orderingCardDatas[i][j]
			local card_sprite = self:createCardSprite(card_data)
			local posX = self._cardPosTable.ordering[i]:getPositionX()
			local posY = self._cardPosTable.ordering[i]:getPositionY()

			local endPos = cc.p(posX, posY - (j-1)*ordering_with)

			if self._isNewGame == true then 
				local startPos = cc.p( self._cardPosTable.unKnow[1]:getPosition())
				local mediePos = cc.p(posX,posY)
				card_sprite:setPosition(startPos)
				card_sprite:runAction( cc.Sequence:create( cc.MoveTo:create(0.5,mediePos),cc.MoveTo:create(0.5,endPos) ) )
			else
				card_sprite:setPosition(endPos)
			end

			self._rootNode:addChild(card_sprite)
		end
	end
	self._isNewGame = false

	--显示没有翻拍的界面
	local unKnowCardDatas = playerCardsManager.allCards.unKnow
	for i=1,#unKnowCardDatas do 
		local card_data = unKnowCardDatas[i]
		local card_sprite = self:createCardSprite(card_data)
		local posX = self._cardPosTable.unKnow[1]:getPositionX()
		local posY = self._cardPosTable.unKnow[1]:getPositionY()
		card_sprite:setPosition(cc.p(posX, posY))
		self._rootNode:addChild(card_sprite)
	end

	--显示已经排好序的界面
    local orderedCardDatas =  playerCardsManager.allCards.ordered
    for i =1,4 do 
    	for j =1, #orderedCardDatas[i] do
			local card_data = orderedCardDatas[i][j]
			local card_sprite = self:createCardSprite(card_data)
			local posX = self._cardPosTable.ordered[i]:getPositionX()
			local posY = self._cardPosTable.ordered[i]:getPositionY()
			card_sprite:setPosition(cc.p(posX, posY))
			self._rootNode:addChild(card_sprite) 
    	end
    end
    
	--显示被翻了的牌
    local knowFromUnknowCardDatas =  playerCardsManager.allCards.knowFromUnknow
    for i =1,#knowFromUnknowCardDatas do 
		local card_data = knowFromUnknowCardDatas[i]
		local card_sprite = self:createCardSprite(card_data)
		local posX = self._cardPosTable.knowFromUnknow[1]:getPositionX()
		local posY = self._cardPosTable.knowFromUnknow[1]:getPositionY()
		card_sprite:setPosition(cc.p(posX, posY))
		self._rootNode:addChild(card_sprite)
    end

end

function MainLayer:createCardSprite(card_data)
    local cardSprite = cc.CSLoader:getInstance():createNodeWithFlatBuffersFile("card.csb")
    local rootNode = cardSprite:getChildByName("Image_1")
    local 	bgNode = rootNode:getChildByName("bg") 
	bgNode:setVisible( not card_data.isSee)
    for i =1,4 do 
    	rootNode:getChildByName("0"..tostring(i)):setVisible(false)
    	rootNode:getChildByName("1"..tostring(i)):setVisible(false)
    end
    rootNode:getChildByName("0"..tostring(card_data.kind)):setVisible(true)
    rootNode:getChildByName("1"..tostring(card_data.kind)):setVisible(true)
    rootNode:getChildByName("value"):setString(card_data.value)
    if card_data.kind == 3 or card_data.kind == 2 then
     	rootNode:getChildByName("value"):setColor(cc.c3b(255,0, 0))
    end
    cardSprite.cardData = card_data
 	table.insert(self._allCardSprite,cardSprite)
    return cardSprite
end


function MainLayer:destroyAllCardSprite()
	for i=1, #self._allCardSprite do
		self._allCardSprite[i]:removeFromParent()
	end
	self._allCardSprite = {}
end

function MainLayer:getCardSprite(cardData)
	for i =1,(#self._allCardSprite) do
		if cardData ==self._allCardSprite[i].cardData  then 
			return self._allCardSprite[i]
		end
	end
	return nil
end

function MainLayer:addTouchEvent()
	self:setTouchEnabled(true)
	local listener = cc.EventListenerTouchOneByOne:create()
	listener:registerScriptHandler( handler(self,self.touchBegan), cc.Handler.EVENT_TOUCH_BEGAN)
	listener:registerScriptHandler( handler(self,self.touchMove), cc.Handler.EVENT_TOUCH_MOVED)
	listener:registerScriptHandler( handler(self,self.touchEndled),cc.Handler.EVENT_TOUCH_ENDED)

	local eventDispatcher = self:getEventDispatcher()
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener,self)

end

function MainLayer:touchBegan(touch, event)
	local pos = touch:getLocation()
	-- dump(pos, "-----touchBegan: ")
	for k,i in pairs(CardPosKind) do
		if i == CardPosKind.ordered then      --触摸已经排好序的卡牌
			for j=1,4 do 
				local rect = self._cardPosTable[k][j]:getBoundingBox()
				if cc.rectContainsPoint(rect,pos) then 
					-- print("click on then ordered: ", j)
				end
			end
		elseif i == CardPosKind.unKnow then   
			local rect = self._cardPosTable[k][1]:getBoundingBox()
			if cc.rectContainsPoint(rect,pos) then 
				-- print("click on then unKnow: ")
				local origin_card_data_list = PlayerCardsManager:getInstance().allCards.unKnow
				local card_count  = #origin_card_data_list
				local touchIndex = #origin_card_data_list
				if touchIndex > 0 then 
					origin_card_data_list[touchIndex].isSee = true
					local canMovingCard,des_card_data_list,dest_card_kind = self:checkCardMoving(origin_card_data_list[touchIndex], true  )
					self:addMoveCardSprite(origin_card_data_list,card_count,card_count, canMovingCard ,  CardPosKind.unKnow ,des_card_data_list, dest_card_kind )
					if canMovingCard then
						self:addMoveCardData( origin_card_data_list, des_card_data_list, touchIndex, touchIndex,CardPosKind.knowFromUnknow)
					end
				else -- todo knowFrowUnKnow的卡牌数据移动到 unknow中去
					if PlayerCardsManager:getInstance().allCards.knowFromUnknow[1] == nil then 
						return;
					end
					local des_card_data_list = origin_card_data_list;
					origin_card_data_list = PlayerCardsManager:getInstance().allCards.knowFromUnknow;

					self:addMoveCardSprite(origin_card_data_list,1,#origin_card_data_list, true, CardPosKind.knowFromUnknow ,des_card_data_list,CardPosKind.unKnow )
					self:addMoveCardData(origin_card_data_list, des_card_data_list , 1, #origin_card_data_list, CardPosKind.unKnow)
				end
		   end
		elseif i == CardPosKind.knowFromUnknow then  
			local rect = self._cardPosTable[k][1]:getBoundingBox()
			if cc.rectContainsPoint(rect,pos) then 
				local origin_card_data_list =PlayerCardsManager:getInstance().allCards.knowFromUnknow
				local card_count  = #origin_card_data_list
				local card_data = origin_card_data_list[card_count]
				if card_count > 0 then
					local canMovingCard,des_card_data_list,dest_card_kind = self:checkCardMoving(card_data, true)
					self:addMoveCardSprite(origin_card_data_list,card_count,card_count, canMovingCard ,  CardPosKind.knowFromUnknow ,des_card_data_list, dest_card_kind )
					if  canMovingCard == true  then 
						self:addMoveCardData(origin_card_data_list, des_card_data_list, card_count,card_count, dest_card_kind )
					end
				end
		   end
		elseif i == CardPosKind.ordering then    --触摸正在排序的card牌
			self:handlerTouchOrdringArea(pos,false);
		end
	end 
	return true
end

function MainLayer:handlerTouchOrdringArea(pos,isTouchEnd,isTouchOrdred)
	for j=1, 7 do 
		local origin_card_data_list =PlayerCardsManager:getInstance().allCards.ordering[j]
		local card_count  = #origin_card_data_list
		local rect = self._cardPosTable["ordering"][j]:getBoundingBox()

		rect.height = rect.height+ (card_count-1)*ordering_with
		rect.y = rect.y - (card_count-1)*ordering_with
		if  cc.rectContainsPoint(rect,pos) then 
			self._isTouchOrdring = true;
			local touchCardIndex = math.ceil((rect.y+rect.height- pos.y)/ordering_with)

			if touchCardIndex > card_count then 
				touchCardIndex = card_count
			end

			local cardData = origin_card_data_list[touchCardIndex]
			local canMovingCard,des_card_data_list,dest_card_kind = self:checkCardMoving(cardData, touchCardIndex == card_count, isTouchOrdred )
			print("sssss111   ",canMovingCard,dest_card_kind)
			dump(des_card_data_list)
			self:addMoveCardSprite(origin_card_data_list,touchCardIndex,#origin_card_data_list ,canMovingCard, CardPosKind.ordering, des_card_data_list, dest_card_kind)
			if canMovingCard == true and isTouchEnd then 
				self:addMoveCardData(origin_card_data_list, des_card_data_list,touchCardIndex, #origin_card_data_list,dest_card_kind)
			end
		end
	end
end


function MainLayer:canLinkCard(card_1,card_2,isSameKind)
	if isSameKind == nil then 
		if card_1.kind == CardKind.spade or  card_1.kind == CardKind.club then 
			if card_2.kind == CardKind.heart or  card_2.kind == CardKind.diamond  then 
				if card_2.value - card_1.value == 1 then 
					return true
				end
			end
		else
			if card_2.kind == CardKind.spade or  card_2.kind == CardKind.club  then 
				if card_2.value - card_1.value == 1 then 
					return true
				end
			end
		end
	elseif isSameKind == true then 
		if  card_1.kind  ==  card_2.kind then 
			if (card_1.value  - card_2.value) == 1 then 
				return true
			end
		end
	end
	return false
end

function MainLayer:checkMoveToUnknow(cardData,isLastCard)
	if cardData then 
		local dest_cards = PlayerCardsManager:getInstance().allCards.unKnow
		return true, dest_cards
	end
end

function MainLayer:checkMoveToKnowFromUnknow(cardData,isLastCard)
	if cardData then
		local dest_cards = PlayerCardsManager:getInstance().allCards.knowFromUnknow
		return true, dest_cards;
	end 
end

function  MainLayer:checkMoveToOrdering(cardData, isLastCard)
	-- print("moving card : CardPosKind.ordering  ",#PlayerCardsManager:getInstance().allCards.ordering)
	if cardData.value == CardValue[13] then 
		for i = 1, #PlayerCardsManager:getInstance().allCards.ordering do
			local dest_cards = PlayerCardsManager:getInstance().allCards.ordering[i]
			if #dest_cards == 0 then 
				 return  true, dest_cards
		 	end
		end
	end

	for i = 1, #PlayerCardsManager:getInstance().allCards.ordering do 
		local dest_cards = PlayerCardsManager:getInstance().allCards.ordering[i]
		if #dest_cards >0 then 
			local lastCard = dest_cards[#dest_cards]
			if self:canLinkCard(cardData,lastCard) == true then 
				return true, dest_cards
			end
		end 
	end

end
 
function MainLayer:checkMoveToOrdered(cardData, isLastCard)
	if isLastCard == true  then 
		for i=1,#PlayerCardsManager:getInstance().allCards.ordered do
			local dest_cards = PlayerCardsManager:getInstance().allCards.ordered[i]
			local dest_cards_count = #dest_cards
			if dest_cards_count == 0 and cardData.value == 1 then
				return true,dest_cards
			elseif dest_cards_count > 0 then
				local lastCard = dest_cards[dest_cards_count]
				if self:canLinkCard(cardData, lastCard, true) == true then 
					return true, dest_cards
				end	 
			end
		end
	end
end

function MainLayer:checkCardMoving(cardData, isLastCard,isTouchOrdred)
	local retValue = false
	if cardData.isSee == true  then 
		if cardData.posKind == CardPosKind.unKnow then 
			-- todo 移动到 knowFromUnknow 中去
			local card_pos_kind = CardPosKind.knowFromUnknow
			local canMovingToOrdered, dest_cards_2 = self:checkMoveToKnowFromUnknow(cardData, isLastCard)
			if canMovingToOrdered == true then 
				return canMovingToOrdered,dest_cards_2, card_pos_kind
			end
		elseif cardData.posKind == CardPosKind.ordering  then 
			-- todo 可移动到 ordering 
			-- todo 检测是否可移动到 ordered 中去
			local canMovingToOrdered, dest_cards_2 = self:checkMoveToOrdered(cardData, isLastCard) 
			if canMovingToOrdered == true then
				return canMovingToOrdered ,dest_cards_2, CardPosKind.ordered
			end

			local canMovingToOrdering,dest_cards_1 = self:checkMoveToOrdering(cardData, isLastCard) 
			if canMovingToOrdering == true then 
				return canMovingToOrdering, dest_cards_1, CardPosKind.ordering
			end
		elseif  cardData.posKind == CardPosKind.ordered  then 
			-- todo 可移动到ordering 和 ordered 
		elseif cardData.posKind == CardPosKind.knowFromUnknow  then 
			if isTouchOrdred then 
				local canMovingToOrdered, dest_cards_2 = self:checkMoveToOrdered(cardData, isLastCard) 
				if canMovingToOrdered == true then
					return canMovingToOrdered ,dest_cards_2, CardPosKind.ordered
				end
			else 
				local canMovingToOrdering,dest_cards_1 = self:checkMoveToOrdering(cardData, isLastCard) 
				if canMovingToOrdering == true then 
					return canMovingToOrdering, dest_cards_1,CardPosKind.ordering
				end
			end
		end

	end
	return false 
end

function MainLayer:clearMoveCardSprite()
	self._moveCardSprite = {}
	self._moveCardData = {}
end

function MainLayer:addMoveCardSprite(OriginCardDatas,startIndex,endIndex,canMovingCard,OriginCardType, DestCardDatas, destCardType)
	
	self._moveCardData.canMovingCard = canMovingCard
    self._moveCardData.originCardPoss ={}
	self._moveCardData.destCardPoss = {}


	for i =startIndex, endIndex do 
		self._zOrder = self._zOrder +1
		local cardSprite = self:getCardSprite(OriginCardDatas[i])
		cardSprite:setZOrder(self._zOrder)  
		table.insert(self._moveCardSprite,cardSprite)

		local originPosX =  cardSprite:getPositionX()
		local originPosY =  cardSprite:getPositionY()
		table.insert(self._moveCardData.originCardPoss, cc.p(originPosX,originPosY) )
	end
	-- dump(OriginCardDatas,"OriginCardDatas")
	-- dump(DestCardDatas,"DestCardDatas")
	-- dump(self._moveCardSprite,"self._moveCardSprite")
	print("OriginCardType--- ",OriginCardType,destCardType)
     

	if canMovingCard == true then   -- 如果可以移动计算，目的地位置
		if destCardType == CardPosKind.unKnow then 
			local unKnowCard = PlayerCardsManager:getInstance().allCards.unKnow
			local destPosX =  self._cardPosTable.unKnow[1]:getPositionX()
			local destPosY =  self._cardPosTable.unKnow[1]:getPositionY()
			for i =1, #self._moveCardSprite do 
   				table.insert(self._moveCardData.destCardPoss, cc.p(destPosX,destPosY))
			end

			-- dump(self._moveCardData.destCardPoss,"self._moveCardData.destCardPoss ")
		elseif destCardType == CardPosKind.knowFromUnknow then 
			local knowFromUnknowCard = PlayerCardsManager:getInstance().allCards.knowFromUnknow
   			local destPosX =  self._cardPosTable.knowFromUnknow[1]:getPositionX()
   			local destPosY =  self._cardPosTable.knowFromUnknow[1]:getPositionY()
   			table.insert(self._moveCardData.destCardPoss, cc.p(destPosX,destPosY))
		elseif destCardType == CardPosKind.ordered then 
			local orderedCard = PlayerCardsManager:getInstance().allCards.ordered
			for i=1,#orderedCard do
				if orderedCard[i] == DestCardDatas then   --
   					local destPosX =  self._cardPosTable.ordered[i]:getPositionX()
   					local destPosY =  self._cardPosTable.ordered[i]:getPositionY()
					-- print("--------------------------dest_pos",destPosX,destPosY)
   					table.insert(self._moveCardData.destCardPoss, cc.p(destPosX,destPosY))
   					return
				end
			end
		else
			local orderingCard = PlayerCardsManager:getInstance().allCards.ordering
			for i=1,#orderingCard do
				if orderingCard[i] == DestCardDatas then   --
					local card_count = #orderingCard[i]
					local destPosX =  self._cardPosTable.ordering[i]:getPositionX()
   					local destPosY =  self._cardPosTable.ordering[i]:getPositionY()
   					local count = 0
					for j = startIndex,endIndex do
   						table.insert(self._moveCardData.destCardPoss, cc.p(destPosX,destPosY -(card_count+count)*ordering_with)) 
						count = count +1
					end
					-- dump("-------------all des pos",self._moveCardData.destCardPoss)
   					return 
				end
			end
		end
	end

end

function MainLayer:addMoveCardData(originCardDataList,desCardDataList,startIndex,endIndex, desCardDType)
	for i =startIndex ,endIndex do 
	    -- 点击的类型是unknown类型的牌是，修改可见性
		if desCardDType  == CardPosKind.unKnow then
			originCardDataList[startIndex].isSee = false
		end
		originCardDataList[startIndex].posKind = desCardDType
		table.insert(desCardDataList,originCardDataList[startIndex])
		table.remove(originCardDataList,startIndex)
	end

	if startIndex>1 and originCardDataList[startIndex-1].posKind ~= CardPosKind.unKnow then 
		originCardDataList[startIndex-1].isSee = true
	end

	self:displayWinEffect()
end

function MainLayer:doMoveCard()
end

function MainLayer:checkIsWin()
	local orderedCard = PlayerCardsManager:getInstance().allCards.ordered
	for i =1, #orderedCard do
		if #orderedCard[i] ~= 13 then
			return false 
		end
	end
	self._zOrder = 100
	return true
end

function MainLayer:displayWinEffect()
	if self:checkIsWin() == true then
		-- todo  显示胜利动画
		local winLayer = cc.CSLoader:getInstance():createNodeWithFlatBuffersFile("win.csb")
		winLayer:setPosition( cc.p(display.cx, display.cy))
		winLayer:setScale(0.001)
		winLayer:runAction( cc.ScaleTo:create(1,1)  )
		self:addChild(winLayer)
	end
end

function MainLayer:touchMove(touch,event)
	local pos = touch:getDelta()
	for i=1,#self._moveCardSprite do 
		local posOrigin = cc.p( self._moveCardSprite[i]:getPosition())
		self._moveCardSprite[i]:setPosition( cc.pAdd(posOrigin,pos) )
	end
end

function MainLayer:touchEndled(touch,event)

	local start_pos = touch:getStartLocation();	
	local end_pos = touch:getLocation()

	local isEndTouchOrdred = false;
	for j=1,#self._cardPosTable["ordered"] do 
		if cc.rectContainsPoint(self._cardPosTable["ordered"][j]:getBoundingBox(),end_pos)  then 
			isEndTouchOrdred = true
		end
	end
	if self._isTouchOrdring then 
		self:clearMoveCardSprite()
		self:handlerTouchOrdringArea(start_pos,true,isTouchOrdred)
	end
	self:showMoveCardToDestinationAnimation()
	self._isTouchOrdring = false
end

function MainLayer:showMoveCardToDestinationAnimation()
	if self._moveCardData.canMovingCard ~= nil then
	 	if self._moveCardData.canMovingCard  == true then
	 		for i =1, #self._moveCardSprite do 
	 			self._moveCardSprite[i]:runAction( cc.MoveTo:create(0.2,self._moveCardData.destCardPoss[i] ) )
	 		end 
	 	else 
	 		for i =1, #self._moveCardSprite do 
	 			self._moveCardSprite[i]:runAction( cc.MoveTo:create(0.2,self._moveCardData.originCardPoss[i] ) )
	 		end 
	 	end 
	end

	local callBack = cc.CallFunc:create( function () 
										self:displayCard()
										self:clearMoveCardSprite()
								  end )
	self:runAction( cc.Sequence:create( cc.DelayTime:create(0.25), callBack ) )
end





return MainLayer





