cc.Class({
    extends: cc.Component,

    properties: {
        value: {
            default: null,
            type: cc.Label
        },
        valueImg: {
            default: null,
            type: cc.Sprite
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
        this.value.node.active = false;
        this.valueImg.node.active = false;
        this.value.string = this.cardData.value;
        if (this.cardData.value == 1 || this.cardData.value > 10) {
            this.valueImg.node.active = true;
            var imgColor = (this.cardData.kind == CardKind.spade || this.cardData.kind == CardKind.club) ? 0 : 1;
            var path = cc.url.raw('resources/poker_digit_' + imgColor + '_' + this.cardData.value + '.png');
            var texture = cc.textureCache.addImage(path);
            this.valueImg.spriteFrame.setTexture(texture);
            console.log('ssss ' + path);
        } else {
            this.value.node.active = true;
        }

        this.bg.active = !this.cardData.isSee;
        if (this.cardData.kind == CardKind.heart || this.cardData.kind == CardKind.diamond) {
            this.value.node.color = new cc.Color(255, 0, 0);
        }
    },
});
