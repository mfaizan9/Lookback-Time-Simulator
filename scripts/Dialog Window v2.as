function DialogWindowV2Class()
{
   var _loc1_ = this;
   if(_loc1_.borderColor == undefined)
   {
      _loc1_.borderColor = 6316128;
   }
   if(_loc1_.borderThickness == undefined)
   {
      _loc1_.borderThickness = 1;
   }
   if(_loc1_.fontSourceLinkageName == undefined)
   {
      _loc1_.fontSourceLinkageName = "Dialog Window Font";
   }
   if(_loc1_.closeButtonLinkageName == undefined)
   {
      _loc1_.closeButtonLinkageName = "Dialog Window Close Button";
   }
   if(_loc1_.leftLimit == undefined)
   {
      _loc1_.leftLimit = 0;
   }
   if(_loc1_.rightLimit == undefined)
   {
      _loc1_.rightLimit = Stage.width;
   }
   if(_loc1_.topLimit == undefined)
   {
      _loc1_.topLimit = 0;
   }
   if(_loc1_.bottomLimit == undefined)
   {
      _loc1_.bottomLimit = Stage.height;
   }
   if(_loc1_.buffer == undefined)
   {
      _loc1_.buffer = 0;
   }
   if(_loc1_.titleBarColor == undefined)
   {
      _loc1_.titleBarColor = 6710886;
   }
   if(_loc1_.titleBarHeight == undefined)
   {
      _loc1_.titleBarHeight = 26;
   }
   if(_loc1_.title == undefined)
   {
      _loc1_.title = "";
   }
   if(_loc1_.titleSize == undefined)
   {
      _loc1_.titleSize = 12;
   }
   if(_loc1_.titleColor == undefined)
   {
      _loc1_.titleColor = 16777215;
   }
   if(_loc1_.titleXPosition == undefined)
   {
      _loc1_.titleXPosition = 10;
   }
   if(_loc1_.titleYPosition == undefined)
   {
      _loc1_.titleYPosition = 7;
   }
   _loc1_.initialize();
}
var p = DialogWindowV2Class.prototype = new MovieClip();
Object.registerClass("Dialog Window v2",DialogWindowV2Class);
p.initialize = function()
{
   var _loc1_ = this;
   _loc1_.createEmptyMovieClip("backgroundMC",1);
   _loc1_.createEmptyMovieClip("titleBarBackgroundMC",5);
   _loc1_.attachMovie(_loc1_.contentLinkageName,"contentMC",15,{_x:0,_y:0});
   _loc1_.createEmptyMovieClip("contentMaskMC",16);
   _loc1_.createEmptyMovieClip("borderMC",20);
   _loc1_.attachMovie(_loc1_.closeButtonLinkageName,"closeButtonMC",25);
   _loc1_.attachMovie(_loc1_.fontSourceLinkageName,"fontMC",121212);
   _loc1_.titleTextFormat = _loc1_.fontMC.fontField.getTextFormat();
   _loc1_.fontMC.removeMovieClip();
   _loc1_.loadSuccessful = _loc1_.contentMC != undefined;
   var _loc3_;
   var _loc2_;
   if(!_loc1_.loadSuccessful)
   {
      _loc1_._visible = false;
   }
   else
   {
      _loc1_.contentMC.setMask(_loc1_.contentMaskMC);
      _loc3_ = _loc1_.contentMC._width;
      var cHeight = _loc1_.contentMC._height;
      _loc2_ = _loc1_.titleBarHeight;
      _loc1_.minX = _loc1_.leftLimit + _loc1_.buffer;
      _loc1_.maxX = _loc1_.rightLimit - _loc1_.buffer - _loc3_;
      _loc1_.minY = _loc1_.topLimit + _loc1_.buffer + _loc2_;
      _loc1_.maxY = _loc1_.bottomLimit - _loc1_.buffer - cHeight;
      _loc1_.closeButtonMC._x = _loc3_ - (_loc2_ - _loc1_.closeButtonMC._height) / 2;
      _loc1_.closeButtonMC._y = (- _loc2_) / 2;
      _loc1_.titleTextFormat.color = _loc1_.titleColor;
      _loc1_.titleTextFormat.size = _loc1_.titleFontSize;
      _loc1_.displayText(_loc1_.title,{depth:10,vAlign:"top",hAlign:"left",x:_loc1_.titleXPosition,y:_loc1_.titleYPosition - _loc2_,embedFonts:true,textFormat:_loc1_.titleTextFormat});
      var mc = _loc1_.backgroundMC;
      mc.beginFill(16711680,0);
      mc.moveTo(0,- _loc2_);
      mc.lineTo(0,cHeight);
      mc.lineTo(_loc3_,cHeight);
      mc.lineTo(_loc3_,- _loc2_);
      mc.lineTo(0,- _loc2_);
      mc.endFill();
      var mc = _loc1_.titleBarBackgroundMC;
      mc.beginFill(_loc1_.titleBarColor);
      mc.moveTo(0,0);
      mc.lineTo(_loc3_,0);
      mc.lineTo(_loc3_,- _loc2_);
      mc.lineTo(0,- _loc2_);
      mc.lineTo(0,0);
      mc.endFill();
      var mc = _loc1_.contentMaskMC;
      mc.beginFill(16711680,10);
      mc.moveTo(0,0);
      mc.lineTo(_loc3_,0);
      mc.lineTo(_loc3_,cHeight);
      mc.lineTo(0,cHeight);
      mc.lineTo(0,0);
      mc.endFill();
      var mc = _loc1_.borderMC;
      mc.lineStyle(_loc1_.borderThickness,_loc1_.borderColor);
      mc.moveTo(0,- _loc2_);
      mc.lineTo(0,cHeight);
      mc.lineTo(_loc3_,cHeight);
      mc.lineTo(_loc3_,- _loc2_);
      mc.lineTo(0,- _loc2_);
      mc.moveTo(0,0);
      mc.lineTo(_loc3_,0);
      _loc1_.backgroundMC.tabEnabled = false;
      _loc1_.backgroundMC.useHandCursor = false;
      _loc1_.backgroundMC.onPress = function()
      {
      };
      _loc1_.closeButtonMC.tabEnabled = true;
      _loc1_.closeButtonMC.useHandCursor = true;
      _loc1_.closeButtonMC._focusrect = false;
      _loc1_.closeButtonMC.onSetFocus = function()
      {
         var _loc1_ = this;
         _loc1_.gotoAndStop(2);
         _loc1_.onKeyDown = _loc1_.onKeyDownFunc;
      };
      _loc1_.closeButtonMC.onKillFocus = function()
      {
         this.gotoAndStop(1);
         delete this.onKeyDown;
      };
      _loc1_.closeButtonMC.onKeyDownFunc = function()
      {
         if(Key.isDown(32) || Key.isDown(13))
         {
            this._parent.hide();
         }
      };
      _loc1_.closeButtonMC.onPress = function()
      {
         this._parent.hide();
      };
      _loc1_.titleBarBackgroundMC.tabEnabled = false;
      _loc1_.titleBarBackgroundMC.useHandCursor = false;
      _loc1_.titleBarBackgroundMC.onPress = function()
      {
         var _loc1_ = this;
         _loc1_.xOffset = _loc1_._parent._parent._xmouse - _loc1_._parent._x;
         _loc1_.yOffset = _loc1_._parent._parent._ymouse - _loc1_._parent._y;
         _loc1_.onMouseMove = _loc1_.onMouseMoveFunc;
      };
      _loc1_.titleBarBackgroundMC.onMouseMoveFunc = function()
      {
         var _loc1_ = this;
         var _loc3_ = _loc1_._parent._parent._xmouse - _loc1_.xOffset;
         var _loc2_ = _loc1_._parent._parent._ymouse - _loc1_.yOffset;
         if(_loc3_ < _loc1_._parent.minX)
         {
            _loc3_ = _loc1_._parent.minX;
         }
         else if(_loc3_ > _loc1_._parent.maxX)
         {
            _loc3_ = _loc1_._parent.maxX;
         }
         if(_loc2_ < _loc1_._parent.minY)
         {
            _loc2_ = _loc1_._parent.minY;
         }
         else if(_loc2_ > _loc1_._parent.maxY)
         {
            _loc2_ = _loc1_._parent.maxY;
         }
         _loc1_._parent._x = _loc3_;
         _loc1_._parent._y = _loc2_;
         updateAfterEvent();
      };
      _loc1_.titleBarBackgroundMC.onRelease = _loc1_.titleBarBackgroundMC.onReleaseOutside = function()
      {
         delete this.onMouseMove;
      };
      _loc1_._x = _loc1_.leftLimit + (_loc1_.rightLimit - _loc1_.leftLimit) / 2 - _loc3_ / 2;
      _loc1_._y = _loc1_.topLimit + (_loc1_.bottomLimit - _loc1_.topLimit) / 2 - (cHeight - _loc2_) / 2;
   }
};
p.hide = function()
{
   var _loc1_ = this;
   _loc1_._visible = false;
   _loc1_.closeButtonMC.gotoAndStop(1);
   delete _loc1_.closeButtonMC.onKeyDown;
};
p.show = function()
{
   this._visible = true;
};
p.getVisible = function()
{
   return this._visible;
};
p.setVisible = function(arg)
{
   this._visible = arg;
};
p.addProperty("visible",p.getVisible,p.setVisible);
p.displayText = function(textString, options)
{
   var _loc1_ = textString;
   _loc1_ = String(_loc1_);
   if(options.depth != undefined)
   {
      var mcDepth = options.depth;
   }
   else if(_global._displayedTextLastDepthUsed != undefined)
   {
      var mcDepth = ++_global._displayedTextLastDepthUsed;
   }
   else
   {
      var mcDepth = _global._displayedTextLastDepthUsed = 913001;
   }
   if(options.name != undefined)
   {
      var mcName = options.name;
   }
   else
   {
      var mcName = "_textWrapper_" + mcDepth;
   }
   if(options.mc != undefined)
   {
      var mc = options.mc.createEmptyMovieClip(mcName,mcDepth);
   }
   else
   {
      var mc = this.createEmptyMovieClip(mcName,mcDepth);
   }
   if(options.x != undefined)
   {
      mc._x = options.x;
   }
   if(options.y != undefined)
   {
      mc._y = options.y;
   }
   if(options.embedFonts != undefined)
   {
      var embedFonts = options.embedFonts;
   }
   else
   {
      var embedFonts = false;
   }
   if(options.textFormat != undefined)
   {
      var normalFormat = options.textFormat;
   }
   else
   {
      var normalFormat = new TextFormat(null,12);
   }
   var scriptFormat = new TextFormat();
   for(var x in normalFormat)
   {
      scriptFormat[x] = normalFormat[x];
   }
   if(options.sizeRatio != undefined)
   {
      scriptFormat.size = normalFormat.size / options.sizeRatio;
   }
   else
   {
      scriptFormat.size = normalFormat.size / 1.5;
   }
   mc.createTextField("_0",0,0,0,0,0);
   mc._0.autoSize = "left";
   mc._0.embedFonts = embedFonts;
   mc._0.setNewTextFormat(normalFormat);
   mc._0.text = "X";
   mc._0._visible = false;
   mc.createTextField("_1",1,0,0,0,0);
   mc._1.autoSize = "left";
   mc._1.embedFonts = embedFonts;
   mc._1.setNewTextFormat(scriptFormat);
   mc._1.text = "X";
   mc._1._visible = false;
   var lineHeight = mc._0._height;
   var scriptHeight = mc._1._height;
   if(options.superscriptPosition != undefined)
   {
      var superscriptDelta = - options.superscriptPosition;
   }
   else
   {
      var superscriptDelta = 0;
   }
   if(options.subscriptPosition != undefined)
   {
      var subscriptDelta = lineHeight - scriptHeight + options.subscriptPosition;
   }
   else
   {
      var subscriptDelta = lineHeight - scriptHeight;
   }
   if(options.extraSpacing != undefined)
   {
      var extraSpacing = options.extraSpacing;
   }
   else
   {
      var extraSpacing = 0.5;
   }
   var _loc2_ = [];
   var pos = 0;
   var iLimit = 0;
   var startInd = 0;
   do
   {
      var ind = _loc1_.indexOf("<su",startInd);
      if(ind == -1)
      {
         _loc2_.push({pos:pos,str:_loc1_});
      }
      else if(_loc1_.charAt(ind + 3) == "b" && _loc1_.charAt(ind + 4) == ">")
      {
         if(ind != 0)
         {
            _loc2_.push({pos:pos,str:_loc1_.substring(0,ind)});
         }
         _loc1_ = _loc1_.slice(ind + 5);
         pos = -1;
         var ind2 = _loc1_.indexOf("</sub>");
         if(ind2 != -1)
         {
            if(ind2 != 0)
            {
               _loc2_.push({pos:pos,str:_loc1_.substring(0,ind2)});
            }
            _loc1_ = _loc1_.slice(ind2 + 6);
            pos = 0;
         }
         startInd = 0;
      }
      else if(_loc1_.charAt(ind + 3) == "p" && _loc1_.charAt(ind + 4) == ">")
      {
         if(ind != 0)
         {
            _loc2_.push({pos:pos,str:_loc1_.substring(0,ind)});
         }
         _loc1_ = _loc1_.slice(ind + 5);
         pos = 1;
         var ind2 = _loc1_.indexOf("</sup>");
         if(ind2 != -1)
         {
            if(ind2 != 0)
            {
               _loc2_.push({pos:pos,str:_loc1_.substring(0,ind2)});
            }
            _loc1_ = _loc1_.slice(ind2 + 6);
            pos = 0;
         }
         startInd = 0;
      }
      else
      {
         startInd = ind + 3;
      }
      iLimit++;
   }
   while(ind != -1 && _loc1_.length > 0 && iLimit < 100);
   if(iLimit >= 100)
   {
      trace("WARNING: iteration limit reached");
   }
   var tL = [];
   var totalWidth = 0;
   var depth = 2;
   var i = 0;
   while(i < _loc2_.length)
   {
      var name = "_" + depth;
      mc.createTextField(name,depth++,0,0,0,0);
      var tf = mc[name];
      tf.autoSize = "left";
      tf.embedFonts = embedFonts;
      tf.selectable = false;
      if(_loc2_[i].pos == 0)
      {
         var dy = 0;
         tf.setNewTextFormat(normalFormat);
      }
      else if(_loc2_[i].pos == 1)
      {
         var dy = superscriptDelta;
         tf.setNewTextFormat(scriptFormat);
      }
      else
      {
         var dy = subscriptDelta;
         tf.setNewTextFormat(scriptFormat);
      }
      tf.text = _loc2_[i].str;
      tL.push({tf:tf,dy:dy});
      totalWidth += tf.textWidth;
      i++;
   }
   totalWidth += extraSpacing * (tL.length - 1);
   if(options.hAlign == "left")
   {
      var x = -2;
   }
   else if(options.hAlign == "right")
   {
      var x = -2 - totalWidth;
   }
   else
   {
      var x = -2 - totalWidth / 2;
   }
   if(options.vAlign == "top")
   {
      var y = -2;
   }
   else if(options.vAlign == "bottom")
   {
      var y = - lineHeight + 2;
   }
   else
   {
      var y = (- lineHeight) / 2;
   }
   var i = 0;
   var _loc3_;
   while(i < tL.length)
   {
      _loc3_ = tL[i];
      _loc3_.tf._x = x;
      _loc3_.tf._y = y + _loc3_.dy;
      x += _loc3_.tf.textWidth + extraSpacing;
      i++;
   }
   mc.textWidth = totalWidth;
   return mc;
};
