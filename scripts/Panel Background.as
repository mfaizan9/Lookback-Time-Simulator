function PanelBackgroundClass()
{
   var _loc1_ = this;
   _loc1_.width = _loc1_._width;
   _loc1_.height = _loc1_._height;
   _loc1_.placeholderMC._visible = false;
   _loc1_._xscale = 100;
   _loc1_._yscale = 100;
   _loc1_.attachMovie(_loc1_.fontSourceLinkageName,"fontMC",121212,{_visible:false});
   _loc1_.interfaceTextFormat = _loc1_.fontMC.fontField.getTextFormat();
   _loc1_.update();
}
var p = PanelBackgroundClass.prototype = new MovieClip();
Object.registerClass("Panel Background",PanelBackgroundClass);
p.update = function()
{
   var _loc1_ = this;
   var _loc2_ = _loc1_.createEmptyMovieClip("backgroundMC",1);
   _loc2_.lineStyle(_loc1_.borderThickness,_loc1_.borderColor);
   _loc2_.beginFill(_loc1_.backgroundColor);
   _loc2_.moveTo(0,0);
   _loc2_.lineTo(_loc1_.width,0);
   _loc2_.lineTo(_loc1_.width,_loc1_.height);
   _loc2_.lineTo(0,_loc1_.height);
   _loc2_.lineTo(0,0);
   _loc2_.endFill();
   _loc1_.interfaceTextFormat.color = _loc1_.titleColor;
   _loc1_.interfaceTextFormat.size = _loc1_.titleFontSize;
   var tmc = _loc1_.displayText(_loc1_.title,{depth:2,vAlign:"top",hAlign:"left",x:_loc1_.xMargin,y:_loc1_.yMargin,embedFonts:true,textFormat:_loc1_.interfaceTextFormat});
   var _loc3_;
   if(_loc1_.showBar)
   {
      _loc3_ = _loc1_.yMargin + _loc1_.barYOffset + tmc._height / 2;
      _loc2_.lineStyle(_loc1_.barThickness,_loc1_.barColor);
      _loc2_.moveTo(2 * _loc1_.xMargin + tmc.textWidth,_loc3_);
      _loc2_.lineTo(_loc1_.width - _loc1_.xMargin,_loc3_);
   }
};
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
