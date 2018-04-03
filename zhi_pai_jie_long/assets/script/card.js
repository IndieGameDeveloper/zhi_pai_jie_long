cc.Class({
    extends: cc.Component,

    properties: {
        value: {
            default: null,
            type: cc.Label
        },
        spade: {
            default: [],
            type: cc.Node
        },
        heart: {
            default: [],
            type: cc.Node
        },
        club: {
            default: [],
            type: cc.Node
        },
        diamond: {
            default: [],
            type: cc.Node
        },
        bg: {
            default: null,
            type: cc.Node
        }
    },

    onLoad: function () {

    },

    setCardInfo: function (cardData) {
        // console.log('cardData   ' + JSON.stringify(cardData));
        this.cardData = cardData;
        for (var key in CardKind) {
            for (var i = 0; i < 2; ++i) {
                this[key][i].active = false;
                if (this.cardData.kind == CardKind[key]) {
                    this[key][i].active = true;
                }
            }
        }
        this.value.string = this.cardData.value;
        this.bg.active = !this.cardData.isSee;
        if (this.cardData.kind == CardKind.heart || this.cardData.kind == CardKind.diamond) {
            this.value.node.color = new cc.Color(255, 0, 0);
        }
    },
});
