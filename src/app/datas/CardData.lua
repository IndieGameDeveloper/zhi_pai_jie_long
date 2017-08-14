local CardData = class("CardData")

CardKind ={
	spade = 1,    --黑桃
	heart = 2,    --红桃
    diamond =3,   --方块
    club = 4,	  --梅花
}
CardPosKind ={
	ordered = 1, 		--左上角排好序的牌
	unKnow = 2, 		--右上角未翻开的牌
	knowFromUnknow = 3, --从右上未翻出来的被翻开的拍
	ordering = 4,       --下面正在排序的已翻出的牌
}

--CardValue = {1,2,3,4,5,6,7,8,9,10,11,12,13}

function CardData:ctor()
	self.value = 0		--卡牌的值 2，3，
	self.kind  = 0 		--卡牌的种类 红桃，方块，黑桃，梅花
	self.posKind = 0    --五种位置种类，位置种类不同，点击牌有不同的行为
	self.isSee = false  --卡片是否翻拍
end

return CardData