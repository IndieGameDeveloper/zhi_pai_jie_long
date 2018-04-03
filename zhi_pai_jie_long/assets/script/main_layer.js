cc.Class({
    extends: cc.Component,
    properties: {
        player: {
            default: null,
            type: cc.Node
        },

        cardPrefab: {
            default: null,
            type: cc.Prefab
        },
        ordered: {
            default: [],
            type: cc.Node
        },
        unKnow: {
            default: null,
            type: cc.Node
        },
        knowFromUnknow: {
            default: null,
            type: cc.Node
        },
        ordering: {
            default: [],
            type: cc.Node
        },
        btnShield: {
            default: null,
            type: cc.Button
        },
        labelWin: {
            default: null,
            type: cc.Label
        }
    },

    ctor: function () {
        this.allCardNode = [];
        this.moveCardNodes = [];
        this.isCardAnimation = false;
        // PlayerCardsManager.getInstance().debugWin();
    },

    createCardView(info, pos, parent) {
        var card = cc.instantiate(this.cardPrefab);
        card.getComponent('card').setCardInfo(info);
        card.setPosition(pos);
        card.parent = this.node;
        this.allCardNode.push(card);
        return card;
    },

    initDisplayAllCard: function () {
        var allCards = PlayerCardsManager.getInstance().allCards;
        for (var key in CardPosKind) {
            switch (CardPosKind[key]) {
                case CardPosKind.ordered:
                    for (var i = 0; i < allCards[key].length; i++) {
                        var pos = this.ordered[i].getPosition();
                        for (var j = 0; j < allCards[key][i].length; ++j) {
                            var card = this.createCardView(allCards[key][i][j], pos, this.node)
                        }
                    }
                    break;
                case CardPosKind.unKnow:
                    var pos = this.unKnow.getPosition();
                    for (var i = 0; i < allCards[key].length; i++) {
                        var card = this.createCardView(allCards[key][i], pos, this.node)
                    }
                    break;
                case CardPosKind.knowFromUnknow:
                    break;
                case CardPosKind.ordering:
                    for (var i = 0; i < allCards[key].length; i++) {
                        var pos = this.ordering[i].getPosition();
                        for (var j = 0; j < allCards[key][i].length; ++j) {
                            var card = this.createCardView(allCards[key][i][j], pos, this.node);
                            card.isOrderingLast = (j == allCards[key][i].length - 1);
                            var action_move = cc.moveTo(0.15, cc.p(pos.x, pos.y - j * ordering_with));
                            var action_delay = cc.delayTime(0.2);
                            var action_callFunc = cc.callFunc(function (sender) {
                                if (sender.isOrderingLast) {
                                    var cardData = sender.getComponent('card').cardData;
                                    cardData.isSee = true;
                                    sender.getComponent('card').setCardInfo(cardData);
                                }
                            });
                            card.runAction(cc.sequence(action_delay, action_move, action_callFunc));
                        }
                    }
                    break;
            }
        }
    },

    onLoad: function () {
        this.btnShield.node.active = false;
        this.node.on('touchstart', this.onTouchStart, this);
        this.node.on('touchmove', this.onTouchMove, this);
        this.node.on('touchend', this.onTouchEnded, this);
        this.resetGame('newGame');
    },

    resetGame: function (restGameType) {
        this.moveCardNodes = [];
        this.isCardAnimation = false;
        this.allCardNode.forEach(function (value) {
            value.parent = null;
        })
        this.allCardNode = [];
        PlayerCardsManager.getInstance().resetGame(restGameType);
        this.initDisplayAllCard();
    },

    onTouchStart: function (event) {
        var touchPos = this.node.convertTouchToNodeSpaceAR(event.touch);
        for (var key in CardPosKind) {
            switch (CardPosKind[key]) {
                case CardPosKind.ordered:
                    break;
                case CardPosKind.unKnow:
                    if (this.unKnow.getBoundingBox().contains(touchPos)) {
                        this.handleTouchUnknow();
                        return true;
                    }
                    break;
                case CardPosKind.knowFromUnknow:
                    if (this.knowFromUnknow.getBoundingBox().contains(touchPos)) {
                        this.handleTouchKnowFromUnknow();
                        return true;
                    }
                    break;
                case CardPosKind.ordering:
                    var result = this.isPointInOrderingArea(touchPos, {})
                    if (result && result.isIn) {
                        this.handleTouchOrdering(result.areaCardKindIndex, result.startIndex);
                        return true;
                    }
                    break;
            }
        }
        return true;
    },

    onTouchMove: function (event) {
        var deltaPos = event.getDelta();
        for (var i = 0; i < this.moveCardNodes.length; ++i) {
            var pos = this.moveCardNodes[i].getPosition();
            this.moveCardNodes[i].setLocalZOrder(MOVE_CARD_ZORDER + this.moveCardNodes[i].originZOrder);
            this.moveCardNodes[i].setPosition(cc.pAdd(pos, deltaPos))
        }
    },

    onTouchEnded: function (event) {
        if (this.moveCardNodes.length != 0) {
            var starPos = this.node.convertToNodeSpaceAR(event.getStartLocation());
            var curPos = this.node.convertToNodeSpaceAR(event.getLocation());
            this.linkCardNode(starPos, curPos);
        }
    },

    /* 该移动掉在 */
    isPointInOrderingArea: function (point, result) {
        for (var i = 0; i < this.ordering.length; ++i) {
            var rect = this.ordering[i].getBoundingBox();
            if ((rect.x < point.x) && (point.x < rect.x + rect.width)) {
                var orderingCard = PlayerCardsManager.getInstance().allCards.ordering[i];
                var max_y = rect.y + card_height;
                var min_y = max_y - (orderingCard.length - 1) * ordering_with - card_height;  // 计算高度有效点击范围；
                if (min_y < point.y && point.y < max_y) {
                    var offset_y = (rect.y + card_height) - point.y
                    var touchIndex = Math.floor(offset_y / ordering_with);
                    var startIndex = Math.min(touchIndex, orderingCard.length - 1);
                    result.areaCards = orderingCard;   // 目标区域牌的集合
                    result.areaCardKindIndex = i;      // 目标区域可能多组牌，对应的index
                    result.startIndex = startIndex;    // 触目具体哪个组的那张牌的索引值
                    result.canLink = false;            // 排至能否链接上；
                    result.areaCardPosKind = CardPosKind.ordering; // 目标区域的牌的种类；
                    result.isIn = true;
                    return result;
                }
            }
        }
    },

    isPointInOrderedArea: function (point, result) {
        if (this.moveCardNodes.length != 1) {
            return;
        }
        var sourceCard = this.moveCardNodes[0].getComponent('card').cardData
        var orderedAreaY = this.ordered[0].getBoundingBox().y;
        for (var i = 0; i < this.ordered.length; ++i) {
            var areaCard = PlayerCardsManager.getInstance().allCards.ordered[i];
            if (point.y >= orderedAreaY) {
                var lastIndex = areaCard.length;
                var noTargetCard = lastIndex == 0;
                if ((noTargetCard && sourceCard.value == 1) ||
                    (!noTargetCard &&
                        (sourceCard.value - areaCard[lastIndex - 1].value == 1) &&
                        (sourceCard.kind == areaCard[lastIndex - 1].kind)
                    )
                ) {
                    result.areaCards = areaCard;             // 目标区域牌的集合
                    result.areaCardKindIndex = i;                       // 目标区域可能多组牌，对应的index
                    result.startIndex = result.areaCards.length - 1;    // 触目具体哪个组的那张牌的索引值
                    result.canLink = false;                             // 排至能否链接上；
                    result.areaCardPosKind = CardPosKind.ordered;       // 目标区域的牌的种类；
                    result.isIn = true;
                    return result;

                }
            }
        }
    },


    getCardNodeByCardData: function (cardData) {
        for (var i = 0; i < this.allCardNode.length; ++i) {
            if (cardData == this.allCardNode[i].getComponent('card').cardData) {
                return this.allCardNode[i];
            }
        }
        return null;
    },

    addMoveCardNode: function (moveCardNode) {
        this.moveCardNodes.push(moveCardNode);
        moveCardNode.originZOrder = moveCardNode.getLocalZOrder();
    },

    handleTouchUnknow: function () {
        var unknowCards = PlayerCardsManager.getInstance().allCards.unKnow;
        var knowFromUnknow = PlayerCardsManager.getInstance().allCards.knowFromUnknow;
        if (unknowCards.length > 0) {
            var pos = this.knowFromUnknow.getPosition();
            var cardNode = this.getCardNodeByCardData(unknowCards[unknowCards.length - 1]);
            if (cardNode) {
                var cardComponent = cardNode.getComponent('card');
                cardComponent.cardData.posKind = CardPosKind.knowFromUnknow;
                cardComponent.cardData.isSee = true;
                cardComponent.setCardInfo(cardComponent.cardData);
                cardNode.setLocalZOrder(knowFromUnknow.length + unknowCards.length);
                cardNode.runAction(cc.sequence(cc.moveTo(0.1, pos), cc.callFunc(function (sender) {
                    sender.setLocalZOrder(knowFromUnknow.length)
                })));

                var deletCardData = unknowCards.splice(unknowCards.length - 1, 1);
                knowFromUnknow.push(deletCardData[0]);
            }
        } else {
            var pos = this.unKnow.getPosition();
            for (var i = 0; i < knowFromUnknow.length; ++i) {
                var cardNode = this.getCardNodeByCardData(knowFromUnknow[i]);
                if (cardNode) {
                    cardNode.setPosition(pos);
                    cardNode.setLocalZOrder(knowFromUnknow.length - i);
                    var cardComponent = cardNode.getComponent('card');
                    cardComponent.cardData.posKind = CardPosKind.unKnow;
                    cardComponent.cardData.isSee = false;
                    cardNode.getComponent('card').setCardInfo(cardComponent.cardData);
                }
            }
            PlayerCardsManager.getInstance().allCards.unKnow = knowFromUnknow.reverse();
            PlayerCardsManager.getInstance().allCards.knowFromUnknow = [];
        }
    },

    handleTouchKnowFromUnknow: function () {
        var unknowCards = PlayerCardsManager.getInstance().allCards.unKnow;
        var knowFromUnknow = PlayerCardsManager.getInstance().allCards.knowFromUnknow;
        var cardNode = this.getCardNodeByCardData(knowFromUnknow[knowFromUnknow.length - 1]);
        cardNode.starPos = cardNode.getPosition();
        this.addMoveCardNode(cardNode);
    },

    handleTouchOrdering: function (orderingIndex, touchCardIndex) {
        var orderingCard = PlayerCardsManager.getInstance().allCards.ordering;
        var touchedCards = orderingCard[orderingIndex];
        if (touchedCards[touchCardIndex].isSee) {
            for (var i = touchCardIndex; i < touchedCards.length; ++i) {
                var card = this.getCardNodeByCardData(touchedCards[i]);
                if (card && touchedCards[i].isSee) {
                    card.starPos = card.getPosition();
                    this.addMoveCardNode(card);
                }
            }
        }
    },

    linkCardNode: function (starPos, endPos) {
        var result = {
            'areaCards': null,          // 目标区域牌的集合
            'areaCardKindIndex': -1,    // 目标区域可能多组牌，对应的index
            'startIndex': null,         // 触目具体哪个组的那张牌的索引值
            'canLink': false,           // 排至能否链接上；
            'areaCardPosKind': -1       // 目标区域的牌的种类;
        };

        var desPos = null;
        var sourceCards = null;

        // 判断移动的卡牌是否移动到某个区域
        var cardData = this.moveCardNodes[0].getComponent('card').cardData;
        if (cardData.posKind == CardPosKind.knowFromUnknow) {   // 移动卡牌的类型： 

            var result_1 = this.isPointInOrderingArea(endPos, {});  //是否移动到正在排序数组中；
            var result_2 = this.isPointInOrderedArea(endPos, {}, this.moveCardNodes);   //是否移动到已排好序的数组中；
            var result = (result_1 && result_1.areaCards) ? result_1 : ((result_2 && result_2.areaCards) ? result_2 : result);
            if (result.areaCards) {
                this.canLinkCardData(result, cardData, result.areaCards[result.areaCards.length - 1], result.areaCardPosKind);
                sourceCards = PlayerCardsManager.getInstance().allCards.knowFromUnknow;
            }
        } else if (cardData.posKind == CardPosKind.ordering) {   // 移动卡牌的类型:
            var startResult = this.isPointInOrderingArea(starPos, {})
            var result_1 = this.isPointInOrderingArea(endPos, {});
            var result_2 = this.isPointInOrderedArea(endPos, {}, this.moveCardNodes);   //是否移动到已排好序的数组中；

            var result = (result_1 && result_1.areaCards) ? result_1 : ((result_2 && result_2.areaCards) ? result_2 : result);
            if (result.areaCards) {
                this.canLinkCardData(result, cardData, result.areaCards[result.areaCards.length - 1], result.areaCardPosKind);
                sourceCards = PlayerCardsManager.getInstance().allCards.ordering[startResult.areaCardKindIndex];
            }
        }

        // 判断是否可连接，计算目标位置；
        var targetCards = result.areaCards;
        if (result.canLink) {
            if (result.areaCardPosKind == CardPosKind.ordering) {    // 目标区域
                var pos = this.ordering[result.areaCardKindIndex].getPosition();
                desPos = cc.p(pos.x, pos.y - targetCards.length * ordering_with);

            } else if (result.areaCardPosKind == CardPosKind.ordered) {  // 目标区域    
                desPos = this.ordered[result.areaCardKindIndex].getPosition();
            }

        }

        desPos = desPos ? [desPos] : [];
        this.playerCardAnimation(desPos, targetCards, sourceCards, result.areaCardPosKind, cardData.posKind);
    },

    canLinkCardData: function (result, sourceCardData, targetCardData, targetCardPosKind) {
        if (!targetCardData) {
            if (targetCardPosKind == CardPosKind.ordered) {
                result.canLink = sourceCardData.value == 1;
            } else if (targetCardPosKind == CardPosKind.ordering) {
                result.canLink = sourceCardData.value == 13;
            }
        } else
            if (targetCardPosKind == CardPosKind.ordered) {
                var isLessOne = (sourceCardData.value - targetCardData.value == 1);
                result.canLink = isLessOne && (targetCardData.kind == sourceCardData.kind);
            } else if (targetCardData.value - sourceCardData.value == 1) {
                var m_kind = sourceCardData.kind;
                var t_kind = targetCardData.kind;
                var b_temp = (m_kind == CardKind.spade || m_kind == CardKind.club) && (t_kind == CardKind.heart || t_kind == CardKind.diamond);
                b_temp = b_temp || (t_kind == CardKind.spade || t_kind == CardKind.club) && (m_kind == CardKind.heart || m_kind == CardKind.diamond);
                result.canLink = b_temp;
            }
    },

    playerCardAnimation: function (desPosArray, targetCards, sourceCards, targetPosKind, sourcePosKind) {
        var self = this;
        this.btnShield.node.active = this.moveCardNodes.length != 0;
        for (var i = 0; i < this.moveCardNodes.length; ++i) {
            var targetPos = desPosArray[i] ? desPosArray[i] : this.moveCardNodes[i].starPos;
            if (targetPosKind == CardPosKind.ordering && desPosArray[0]) {
                targetPos = cc.p(desPosArray[0].x, desPosArray[0].y - i * ordering_with);
                desPosArray.push(targetPos);
            }
            this.moveCardNodes[i].index = i;
            var moveAni = cc.moveTo(0.2, targetPos);
            var callBack = cc.callFunc(function (sender) {
                self.btnShield.node.active = false;
                sender.setLocalZOrder(sender.originZOrder);
                if (desPosArray[sender.index]) {
                    var cardData = sender.getComponent('card').cardData;
                    cardData.posKind = targetPosKind;
                    targetCards.push(cardData);
                    PlayerCardsManager.getInstance().removeArrayElementByValue(cardData, sourceCards);
                    sender.setLocalZOrder(targetCards.length);
                }
            })
            this.moveCardNodes[i].runAction(cc.sequence(moveAni, callBack));
        }
        this.moveCardNodes = [];

        setTimeout(function () {
            self.updateOrderingCardSprite(sourceCards, desPosArray[0]);
            self.checkIsWind(sourceCards);
        }, 500);
    },

    updateOrderingCardSprite(sourceCards, isUpdate) {
        if (isUpdate && sourceCards[0] && sourceCards[0].posKind == CardPosKind.ordering) {
            var cardData = sourceCards[sourceCards.length - 1]
            cardData.isSee = true;
            var cardSprite = this.getCardNodeByCardData(cardData).getComponent('card');
            cardSprite.setCardInfo(sourceCards[sourceCards.length - 1]);
        }
    },

    checkIsWind(sourceCards) {
        if (PlayerCardsManager.getInstance().isWinGame()) {
            this.labelWin.node.active = true;
        }
    },

    onClickBtnEvent(event) {
        if (event.currentTarget.name == 'btnNewGame') {
            this.resetGame('newGame');
        } else if (event.currentTarget.name == 'btnReplay') {
            // 从新开始
            this.resetGame('replayGame');
        } else if (event.currentTarget.name == 'btnSetting') {
            // 设置游戏
        }
    }

});
