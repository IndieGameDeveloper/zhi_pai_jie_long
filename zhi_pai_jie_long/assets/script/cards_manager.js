var CardValue = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13];

class PlayerCardsManager {
  static getInstance() {
    if (!PlayerCardsManager._instance) {
      PlayerCardsManager._instance = new PlayerCardsManager();
    }
    return PlayerCardsManager._instance;
  }

  constructor() {
    this.newGame();
  }

  newGame() {
    this.allCards = {};
    for (var key in CardPosKind) {  // 初始化位置的种类
      this.allCards[key] = [];
    };

    this.initPlayerCards();
    this.initUnknowCards();
    this.initOrderingCards();
    this.initOrderedCards();

    this.all_card_copy = JSON.parse(JSON.stringify(this.allCards));
  }

  replayGame() {
    this.allCards = JSON.parse(JSON.stringify(this.all_card_copy));
  }

  resetGame(resetGameType) {
    if (resetGameType == 'newGame') {
      this.newGame();
    } else if (resetGameType == 'replayGame') {
      this.replayGame();
    }
  }

  initPlayerCards() {   //初始化牌的值，种类
    this.playerCards = [];
    for (var i in CardKind) {
      for (var j = 0; j < CardValue.length; ++j) {
        var cardTemp = new CardData(CardValue[j], CardKind[i], 0, false);
        this.playerCards.push(cardTemp);
      }
    }
  }

  initUnknowCards() {   //右上角未翻开的牌
    for (var i = 0; i < 24; ++i) {
      var randomIndex = Math.floor(Math.random() * this.playerCards.length);
      var cardData = this.playerCards[randomIndex];
      cardData.posKind = CardPosKind.unKnow;
      this.allCards.unKnow.push(cardData);
      this.playerCards.splice(randomIndex, 1);
    }
    // console.log(this.allCards.unKnow)
  }

  initOrderingCards() { //正在排序的拍
    for (var i = 0; i < 7; ++i) {
      this.allCards.ordering.push(new Array());
      for (var k = 0; k <= i; ++k) {
        var randomIndex = Math.floor(Math.random() * this.playerCards.length);
        var card = this.playerCards[randomIndex];
        card.posKind = CardPosKind.ordering;
        card.isSee = false;
        this.allCards.ordering[i].push(card);
        this.playerCards.splice(randomIndex, 1);
      }
      // this.allCards.ordering[i][i].isSee = true;
    }
  }

  initOrderedCards() {
    for (var i = 0; i < 4; ++i) {
      this.allCards.ordered[i] = [];
    }
  }

  removeArrayElementByValue(element, arrayList) {
    for (var i = 0; i < arrayList.length; ++i) {
      if (element.value == arrayList[i].value && element.kind == arrayList[i].kind) {
        arrayList.splice(i, 1);
        return;
      }
    }
  }

  isWinGame() {
    var ordered = this.allCards.ordered;
    for (var i = 0; i < 4; ++i) {
      var isCardEnough = ordered[i].length == 13;
      var isAllSameCard = true;
      var isLessOne = true;
      if (isCardEnough) {
        for (var j = 0; j < 12; ++j) {
          isAllSameCard = isAllSameCard && (ordered[i][j].kind == ordered[i][j + 1].kind);
          isLessOne = isLessOne && (ordered[i][j + 1].value - ordered[i][j].value == 1);

        }
      }
      if (!(isCardEnough && isAllSameCard && isLessOne)) {
        return false;
      }
    }
    return true;
  }

  debugWin() {
    // var j = 0;
    // for (var key in CardKind) {  // 初始化位置的种类
    //   for (var i = 0; i < 13; ++i) {
    //     var cardTemp = new CardData(CardValue[i], j, j, true);
    //     this.allCards.ordered[j].push(cardTemp);
    //   }
    //   j++;
    // }
    // var card = this.allCards.ordered[0].splice(12, 1);
    // card[0].posKind = CardPosKind.ordering;
    // this.allCards.unKnow = [];
    // this.allCards.ordering = [];
    // for (var i = 0; i < 7; ++i) {
    //   this.allCards.ordering.push(new Array());
    // }
    // this.allCards.ordering[0].push(card[0]);
  }

};


window.PlayerCardsManager = PlayerCardsManager;