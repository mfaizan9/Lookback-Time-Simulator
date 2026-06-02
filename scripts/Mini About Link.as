function MiniAboutLinkClass()
{
   var _loc1_ = this;
   var _loc2_ = _loc1_._width / 2;
   var _loc3_ = - _loc1_._height;
   _loc1_.createEmptyMovieClip("backgroundMC",0);
   _loc1_.backgroundMC.beginFill(16711680,0);
   _loc1_.backgroundMC.moveTo(- _loc2_,0);
   _loc1_.backgroundMC.lineTo(_loc2_,0);
   _loc1_.backgroundMC.lineTo(_loc2_,_loc3_);
   _loc1_.backgroundMC.lineTo(- _loc2_,_loc3_);
   _loc1_.backgroundMC.lineTo(- _loc2_,0);
   _loc1_.backgroundMC.endFill();
   _loc1_.createEmptyMovieClip("underlineMC",1);
   _loc1_.underlineMC.lineStyle(1,13260);
   _loc1_.underlineMC.moveTo(- _loc2_,0);
   _loc1_.underlineMC.lineTo(_loc2_,0);
   _loc1_.underlineMC._visible = false;
   _loc1_.attachMovie("Dialog Window v2","aboutWindowMC",2,{topLimit:- _loc1_._y,bottomLimit:Stage.height - _loc1_._y,leftLimit:- _loc1_._x,rightLimit:Stage.width - _loc1_._x,contentLinkageName:"About",title:"About",topLimit:0,buffer:5});
   _loc1_.aboutWindowMC.hide();
   _loc1_.backgroundMC._focusrect = false;
   _loc1_.backgroundMC.useHandCursor = true;
   _loc1_.backgroundMC.onSetFocus = function()
   {
      var _loc1_ = this;
      _loc1_._parent.underlineMC._visible = true;
      _loc1_.onKeyDown = _loc1_.onKeyDownFunc;
   };
   _loc1_.backgroundMC.onKillFocus = function()
   {
      this._parent.underlineMC._visible = false;
      delete this.onKeyDown;
   };
   _loc1_.backgroundMC.onKeyDownFunc = function()
   {
      var _loc1_ = this;
      if(Key.isDown(32))
      {
         _loc1_._parent.doToggle();
         _loc1_._parent.underlineMC._visible = false;
         delete _loc1_.onKeyDown;
      }
   };
   _loc1_.backgroundMC.onRollOver = function()
   {
      this._parent.underlineMC._visible = true;
   };
   _loc1_.backgroundMC.onRollOut = function()
   {
      this._parent.underlineMC._visible = false;
   };
   _loc1_.backgroundMC.onRelease = function()
   {
      this._parent.doToggle();
      this._parent.underlineMC._visible = false;
   };
   _loc1_.backgroundMC.onReleaseOutside = function()
   {
      this._parent.underlineMC._visible = false;
   };
}
var p = MiniAboutLinkClass.prototype = new MovieClip();
Object.registerClass("Mini About Link",MiniAboutLinkClass);
p.doToggle = function()
{
   var _loc1_ = this;
   if(_loc1_.aboutWindowMC.visible)
   {
      _loc1_.aboutWindowMC.hide();
   }
   else
   {
      _loc1_.aboutWindowMC.show();
   }
};
