function TimelineClass()
{
   var _loc1_ = this;
   _loc1_.snOccursField.restrict = "0-9 \\-ADBCEadbce";
   _loc1_.snOccursField.onChanged = _loc1_.snOccursFieldChanged;
   _loc1_.snOccursFieldNormalTextFormat = _loc1_.snOccursField.getTextFormat();
   _loc1_.snOccursFieldBeingEditedTextFormat = _loc1_.snOccursFieldBeingEditedStyle.getTextFormat();
   _loc1_.snOccursFieldNotEditableTextFormat = _loc1_.snOccursFieldNotEditableStyle.getTextFormat();
   _loc1_.snOccursFieldBeingEditedStyle._visible = false;
   _loc1_.snOccursFieldNotEditableStyle._visible = false;
   _loc1_.snOccursFieldBeingEdited = false;
   _loc1_.observedLabelMC.initLabelX = _loc1_.observedLabelMC.labelField._x;
   _loc1_.occursLabelMC.initLabelX = _loc1_.occursLabelMC.labelField._x;
   _loc1_.observedLabelMC._visible = false;
   _loc1_.snObservedField._visible = false;
   _loc1_.occursLabelStalkMC._visible = false;
   _loc1_.cursorMC.tabEnabled = false;
   _loc1_.cursorMC.useHandCursor = false;
   _loc1_.setCursorDraggable(true);
}
var p = TimelineClass.prototype = new MovieClip();
Object.registerClass("Timeline",TimelineClass);
p.minCursorX = 0;
p.maxCursorX = 540;
p.minTimelineYear = -7999;
p.maxTimelineYear = 10000;
p.timelineScale = (p.maxTimelineYear - p.minTimelineYear) / (p.maxCursorX - p.minCursorX);
p.getCursorYear = function()
{
   var _loc1_ = this;
   return _loc1_.minTimelineYear + (_loc1_.cursorMC._x - _loc1_.minCursorX) * _loc1_.timelineScale;
};
p.setCursorYear = function(arg)
{
   var _loc1_ = this;
   _loc1_.cursorMC._x = _loc1_.minCursorX + (arg - _loc1_.minTimelineYear) / _loc1_.timelineScale;
};
p.setCursorDraggable = function(arg)
{
   var _loc1_ = this;
   if(arg)
   {
      _loc1_.cursorMC.onPress = _loc1_.cursorOnPressFunc;
      _loc1_.cursorMC.onRelease = _loc1_.cursorOnReleaseFunc;
      _loc1_.cursorMC.onReleaseOutside = _loc1_.cursorOnReleaseFunc;
      _loc1_.cursorMC.gotoAndStop("draggable");
   }
   else
   {
      delete _loc1_.cursorMC.onPress;
      delete _loc1_.cursorMC.onRelease;
      delete _loc1_.cursorMC.onReleaseOutside;
      delete _loc1_.cursorMC.onMouseMove;
      _loc1_.cursorMC.gotoAndPlay("notDraggable");
   }
};
p.cursorOnPressFunc = function()
{
   var _loc1_ = this;
   _loc1_.xOffset = _loc1_._parent._xmouse - _loc1_._x;
   _loc1_.onMouseMove = _loc1_._parent.cursorOnMouseMoveFunc;
};
p.cursorOnMouseMoveFunc = function()
{
   var _loc1_ = this;
   var _loc2_ = _loc1_._parent._xmouse - _loc1_.xOffset;
   if(_loc2_ < _loc1_._parent.minCursorX)
   {
      _loc2_ = _loc1_._parent.minCursorX;
   }
   else if(_loc2_ > _loc1_._parent.maxCursorX)
   {
      _loc2_ = _loc1_._parent.maxCursorX;
   }
   var _loc3_ = Math.round(_loc1_._parent.minTimelineYear + (_loc2_ - _loc1_._parent.minCursorX) * _loc1_._parent.timelineScale);
   if(_loc3_ < _loc1_._parent.minTimelineYear)
   {
      _loc3_ = _loc1_._parent.minTimelineYear;
   }
   else if(_loc3_ > _loc1_._parent.maxTimelineYear)
   {
      _loc3_ = _loc1_._parent.maxTimelineYear;
   }
   _loc1_._parent._parent.onYearCursorDragged(_loc3_);
   updateAfterEvent();
};
p.cursorOnReleaseFunc = function()
{
   delete this.onMouseMove;
};
p.commitSNOccursFieldChanges = function()
{
   var _loc1_ = this;
   var _loc2_;
   if(_loc1_.snOccursFieldBeingEdited)
   {
      _loc2_ = _loc1_.parseForYear(_loc1_.snOccursField.text);
      _loc1_._parent.onYearCursorDragged(_loc2_);
   }
};
p.cancelSNOccursFieldChanges = function()
{
   if(this.snOccursFieldBeingEdited)
   {
      this._parent.onYearCursorDragged(NaN);
   }
};
p.setSNOccursFieldState = function(state)
{
   var _loc1_ = this;
   var _loc2_ = state;
   if(_loc2_ == "beingEdited")
   {
      _loc1_.snOccursField.setTextFormat(_loc1_.snOccursFieldBeingEditedTextFormat);
      _loc1_.snOccursField.setNewTextFormat(_loc1_.snOccursFieldBeingEditedTextFormat);
      Key.addListener(_loc1_);
      _loc1_.onMouseDown = _loc1_.onMouseDownFunc;
      _loc1_.snOccursFieldBackground.gotoAndStop("beingEdited");
      _loc1_.snOccursField.type = "input";
      _loc1_.snOccursField.selectable = true;
      _loc1_.snOccursFieldBeingEdited = true;
   }
   else if(_loc2_ == "normal")
   {
      _loc1_.snOccursField.setTextFormat(_loc1_.snOccursFieldNormalTextFormat);
      _loc1_.snOccursField.setNewTextFormat(_loc1_.snOccursFieldNormalTextFormat);
      Key.removeListener(_loc1_);
      delete _loc1_.onMouseDown;
      _loc1_.snOccursFieldBackground.gotoAndStop("normal");
      _loc1_.snOccursField.type = "input";
      _loc1_.snOccursField.selectable = true;
      _loc1_.snOccursFieldBeingEdited = false;
   }
   else if(_loc2_ == "notEditable")
   {
      _loc1_.snOccursField.setTextFormat(_loc1_.snOccursFieldNotEditableTextFormat);
      _loc1_.snOccursField.setNewTextFormat(_loc1_.snOccursFieldNotEditableTextFormat);
      Key.removeListener(_loc1_);
      delete _loc1_.onMouseDown;
      _loc1_.snOccursFieldBackground.gotoAndStop("notEditable");
      _loc1_.snOccursField.type = "dynamic";
      _loc1_.snOccursField.selectable = false;
      _loc1_.snOccursFieldBeingEdited = false;
   }
};
p.onKeyDown = function()
{
   if(Key.isDown(13))
   {
      this.commitSNOccursFieldChanges();
   }
};
p.onMouseDownFunc = function()
{
   var _loc1_ = this;
   var _loc2_ = {x:_loc1_._xmouse,y:_loc1_._ymouse};
   _loc1_.localToGlobal(_loc2_);
   if(_loc1_.cursorMC.hitTest(_loc2_.x,_loc2_.y,true))
   {
      _loc1_.cancelSNOccursFieldChanges();
   }
   else
   {
      _loc1_.commitSNOccursFieldChanges();
   }
};
p.snOccursFieldChanged = function()
{
   if(!this._parent.snOccursFieldBeingEdited)
   {
      this._parent.setSNOccursFieldState("beingEdited");
   }
};
p.parseForYear = function(arg)
{
   var _loc2_ = arg;
   _loc2_ = _loc2_.toLowerCase();
   var _loc1_ = Math.round(parseFloat(_loc2_));
   if(isNaN(_loc1_) || _loc1_ < this.minTimelineYear || _loc1_ > this.maxTimelineYear)
   {
      return NaN;
   }
   var _loc3_ = _loc2_.indexOf("bc") != -1;
   var isAD = _loc2_.indexOf("ad") != -1 || _loc2_.indexOf("ce") != -1 && !_loc3_;
   if(_loc1_ == 0)
   {
      return 0;
   }
   if(_loc3_)
   {
      return - (Math.abs(_loc1_) - 1);
   }
   if(isAD)
   {
      return Math.abs(_loc1_);
   }
   return _loc1_;
};
p.setSupernovaYear = function(arg)
{
   var _loc1_ = this;
   var _loc2_ = arg;
   _loc1_.occursLabelMC._x = _loc1_.minCursorX + (_loc2_ - _loc1_.minTimelineYear) / _loc1_.timelineScale;
   _loc1_.occursLabelStalkMC._x = _loc1_.occursLabelMC._x;
   _loc2_ = Math.round(_loc2_);
   if(_loc2_ > 0)
   {
      _loc1_.snOccursField.text = _loc2_ + " AD";
   }
   else
   {
      _loc1_.snOccursField.text = Math.abs(_loc2_ - 1) + " BC";
   }
   _loc1_.setSNOccursFieldState("normal");
};
p.setObservedYear = function(arg)
{
   var _loc1_ = this;
   var _loc2_ = arg;
   _loc1_.observedLabelMC._x = _loc1_.minCursorX + (_loc2_ - _loc1_.minTimelineYear) / _loc1_.timelineScale;
   var _loc3_ = _loc1_.observedLabelMC._x - _loc1_.occursLabelMC._x;
   _loc2_ = Math.round(_loc2_);
   if(_loc2_ > 0)
   {
      _loc1_.snObservedField.text = "is observed: " + _loc2_ + " AD";
   }
   else
   {
      _loc1_.snObservedField.text = "is observed: " + Math.abs(_loc2_ - 1) + " BC";
   }
   if(_loc3_ > 0 && _loc3_ < 67)
   {
      _loc1_.occursLabelMC.labelField._x = _loc1_.occursLabelMC.initLabelX - (30 - _loc3_ / 2);
      _loc1_.observedLabelMC.labelField._x = _loc1_.observedLabelMC.initLabelX + (37 - _loc3_ / 2);
   }
   else
   {
      _loc1_.occursLabelMC.labelField._x = _loc1_.occursLabelMC.initLabelX;
      _loc1_.observedLabelMC.labelField._x = _loc1_.observedLabelMC.initLabelX;
   }
};
p.setObservedLabelVisible = function(arg)
{
   this.observedLabelMC._visible = true;
   this.snObservedField._visible = true;
};
p.reset = function()
{
   var _loc1_ = this;
   _loc1_.cursorMC._visible = true;
   _loc1_.occursLabelStalkMC._visible = false;
   _loc1_.observedLabelMC._visible = false;
   _loc1_.snObservedField._visible = false;
   _loc1_.setSNOccursFieldState("normal");
};
p.onAnimationStart = function()
{
   var _loc1_ = this;
   _loc1_.cursorMC._visible = true;
   _loc1_.occursLabelStalkMC._visible = true;
   _loc1_.setSNOccursFieldState("notEditable");
};
