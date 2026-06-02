function CurlyBraceClass()
{
   var _loc1_ = this;
   _loc1_._rotation = 180;
   _loc1_.colorObj = new Color(_loc1_);
   _loc1_.setBraceColor(_loc1_.initBraceColor);
   _loc1_.setLabel(_loc1_.initLabel);
}
var p = CurlyBraceClass.prototype = new MovieClip();
Object.registerClass("Curly Brace Component",CurlyBraceClass);
p.setLabel = function(arg)
{
   this.labelField.text = arg;
};
p.setBraceWidth = function(arg)
{
   var _loc1_ = this;
   var minimalWidth = _loc1_.leftMC._width + _loc1_.rightMC._width + _loc1_.middleMC._width;
   var _loc3_;
   var _loc2_;
   if(arg < minimalWidth)
   {
      _loc1_.rightFillMC.removeMovieClip();
      _loc1_.leftFillMC.removeMovieClip();
      var x1 = _loc1_.middleMC._width / 2;
      _loc1_.rightMC._x = x1;
      _loc1_.leftMC._x = - x1;
      _loc1_._xscale = 100 * arg / minimalWidth;
      _loc1_._yscale = 100 * Math.sqrt(arg / minimalWidth);
   }
   else
   {
      _loc1_._xscale = _loc1_._yscale = 100;
      var x1 = _loc1_.middleMC._width / 2;
      _loc3_ = x1 + (arg - minimalWidth) / 2;
      var y1 = 5.9;
      var y2 = 10.2;
      _loc2_ = _loc1_.createEmptyMovieClip("rightFillMC",1);
      _loc2_.clear();
      _loc2_.lineStyle(1,16711680,0);
      _loc2_.beginFill(16777215,100);
      _loc2_.moveTo(x1,y1);
      _loc2_.lineTo(x1,y2);
      _loc2_.lineTo(_loc3_,y2);
      _loc2_.lineTo(_loc3_,y1);
      _loc2_.lineTo(x1,y1);
      _loc2_.endFill();
      _loc1_.rightMC._x = _loc3_;
      _loc1_.leftMC._x = - _loc3_;
      _loc2_.duplicateMovieClip("leftFillMC",2);
      _loc1_.leftFillMC._xscale = -100;
   }
};
p.setBraceColor = function(arg)
{
   this.colorObj.setRGB(arg);
};
