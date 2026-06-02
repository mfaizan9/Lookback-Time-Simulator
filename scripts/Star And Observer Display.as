function StarAndObserverDisplayClass()
{
   var _loc1_ = this;
   _loc1_.attachMovie("Curly Brace Component","curlyBraceMC",1,{_y:65,initBraceColor:11579647});
   _loc1_.observerMC.useHandCursor = false;
   _loc1_.observerMC.tabEnabled = false;
   _loc1_.minObserverX = _loc1_.starMC._x + _loc1_.minDistanceValue / _loc1_.maxDistanceValue * (_loc1_.maxObserverX - _loc1_.starMC._x);
   _loc1_.displayScale = (_loc1_.maxObserverX - _loc1_.starMC._x) / _loc1_.maxDistanceValue;
   _loc1_.lightMC._x = _loc1_.starMC._x;
   _loc1_.lightMC._y = _loc1_.starMC._y;
   _loc1_.lightMC._visible = false;
   _loc1_.setObserverDraggable(true);
}
var p = StarAndObserverDisplayClass.prototype = new MovieClip();
Object.registerClass("Star And Observer Display",StarAndObserverDisplayClass);
p.minDistanceValue = 1000;
p.maxDistanceValue = 10000;
p.maxObserverX = 560;
p.setObserverDraggable = function(arg)
{
   var _loc1_ = this;
   if(arg)
   {
      _loc1_.observerMC.onPress = _loc1_.observerOnPressFunc;
      _loc1_.observerMC.onRelease = _loc1_.observerOnReleaseFunc;
      _loc1_.observerMC.onReleaseOutside = _loc1_.observerOnReleaseFunc;
      _loc1_.curlyBraceMC.setBraceColor(16448250);
   }
   else
   {
      delete _loc1_.observerMC.onPress;
      delete _loc1_.observerMC.onRelease;
      delete _loc1_.observerMC.onReleaseOutside;
      delete _loc1_.observerMC.onMouseMove;
      _loc1_.curlyBraceMC.setBraceColor(9474192);
   }
};
p.observerOnPressFunc = function()
{
   var _loc1_ = this;
   _loc1_.xOffset = _loc1_._parent._xmouse - _loc1_._x;
   _loc1_.onMouseMove = _loc1_._parent.observerOnMouseMoveFunc;
};
p.observerOnReleaseFunc = function()
{
   delete this.onMouseMove;
};
p.observerOnMouseMoveFunc = function()
{
   var _loc1_ = this;
   var _loc2_ = _loc1_._parent._xmouse - _loc1_.xOffset;
   if(_loc2_ < _loc1_._parent.minObserverX)
   {
      _loc2_ = _loc1_._parent.minObserverX;
   }
   else if(_loc2_ > _loc1_._parent.maxObserverX)
   {
      _loc2_ = _loc1_._parent.maxObserverX;
   }
   var _loc3_ = Math.round((_loc2_ - _loc1_._parent.starMC._x) / _loc1_._parent.displayScale);
   _loc1_._parent._parent.onObserverDragged(_loc3_);
   updateAfterEvent();
};
p.setObserverDistance = function(arg)
{
   var _loc1_ = this;
   var _loc3_ = arg;
   var _loc2_ = _loc1_.displayScale * _loc3_;
   _loc1_.observerMC._x = _loc1_.starMC._x + _loc2_;
   _loc1_.distanceField.text = _loc3_ + " ly";
   _loc1_.thoughtBubbleMC._x = _loc1_.observerMC._x;
   _loc1_.curlyBraceMC.setBraceWidth(_loc2_);
   _loc1_.curlyBraceMC._x = _loc1_.starMC._x + _loc2_ / 2;
   _loc1_.curlyBraceMC.setLabel(_loc3_ + " ly");
};
p.setLightDistance = function(arg)
{
   var _loc1_ = this;
   var _loc2_ = _loc1_.displayScale * arg;
   if(_loc2_ > 1500)
   {
      _loc2_ = 1500;
   }
   if(_loc2_ < 1e-10)
   {
      _loc1_.starMC.gotoAndStop(1);
      _loc1_.lightMC._visible = false;
   }
   else
   {
      if(_loc1_.starMC._currentframe == 1)
      {
         _loc1_.starMC.gotoAndStop("endBlowup");
      }
      _loc1_.lightMC._visible = true;
      _loc1_.lightMC._xscale = _loc1_.lightMC._yscale = _loc2_;
   }
};
p.showStarBlowingUp = function()
{
   this.starMC.gotoAndPlay("startBlowup");
};
p.showStarBlowingUpInThought = function()
{
   this.thoughtBubbleMC.starMC.gotoAndPlay("startBlowup");
};
p.showStarInThought = function(arg)
{
   if(arg)
   {
      this.thoughtBubbleMC.starMC.gotoAndStop(1);
   }
   else
   {
      this.thoughtBubbleMC.starMC.gotoAndStop("endBlowup");
   }
};
p.reset = function()
{
   var _loc1_ = this;
   _loc1_.starMC.gotoAndStop(1);
   _loc1_.lightMC._visible = false;
   _loc1_.showStarInThought(true);
};
p.onAnimationStart = function()
{
   var _loc1_ = this;
   _loc1_.showStarBlowingUp();
   _loc1_.lightMC._visible = true;
   _loc1_.lightMC._xscale = _loc1_.lightMC._yscale = 0;
};
