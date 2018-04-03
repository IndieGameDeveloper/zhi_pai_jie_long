var CardKind = {
  "spade": 0,     //黑桃
  "heart": 1,     //红桃
  "club": 2,      //梅花
  "diamond": 3,   //方块
};
var CardPosKind = {
  "ordered": 0, 		   //左上角排好序的牌
  "unKnow": 1,           //右上角未翻开的牌
  "knowFromUnknow": 2,   //从右上未翻出来的被翻开的拍
  "ordering": 3,         //下面正在排序的已翻出的牌
};

class CardData {
  constructor(value, kind, posKind, isSee) {
    this.value = value;           //卡牌的值 2，3，
    this.kind = kind;             //卡牌的种类 红桃，方块，黑桃，梅花
    this.posKind = posKind;       //五种位置种类，位置种类不同，点击牌有不同的行为
    this.isSee = isSee;        //卡片是否翻拍
  }
};

window.ordering_with = 45;
window.card_width = 100;
window.card_height = 150;
window.CardKind = CardKind;
window.CardPosKind = CardPosKind;
window.CardData = CardData;
window.MOVE_CARD_ZORDER = 100;
