function LookbackSimulatorClass()
{
   this.maxSupernovaYear = TimelineClass.prototype.maxTimelineYear;
}
var p = LookbackSimulatorClass.prototype = new MovieClip();
Object.registerClass("Lookback Simulator",LookbackSimulatorClass);
p.animRate = 0.6;
p.reset = function()
{
   var _loc1_ = this;
   _loc1_.observerDistance = 3000;
   _loc1_.displayedYear = _loc1_.supernovaYear = 1200;
   _loc1_.setState(0);
};
p.animateOnEnterFrame = function()
{
   var _loc1_ = this;
   var _loc2_ = getTimer();
   var wasPreSN = _loc1_.displayedYear < _loc1_.supernovaYear;
   var _loc3_ = _loc1_.displayedYear < _loc1_.supernovaYear + _loc1_.observerDistance;
   _loc1_.displayedYear += (_loc2_ - _loc1_._timeLast) * _loc1_.animRate;
   if(_loc3_ && _loc1_.displayedYear >= _loc1_.supernovaYear + _loc1_.observerDistance)
   {
      _loc1_.displayMC.showStarBlowingUpInThought();
   }
   if(wasPreSN && _loc1_.displayedYear >= _loc1_.supernovaYear)
   {
      _loc1_.displayMC.showStarBlowingUp();
   }
   if(_loc1_.displayedYear > _loc1_.timelineMC.maxTimelineYear)
   {
      _loc1_.displayedYear = _loc1_.timelineMC.maxTimelineYear;
      _loc1_.setState(3);
   }
   _loc1_.updateSim();
   _loc1_._timeLast = _loc2_;
};
p.updateSim = function()
{
   var _loc1_ = this;
   _loc1_.timelineMC.setCursorYear(_loc1_.displayedYear);
   if(_loc1_.state == 0)
   {
      _loc1_.timelineMC.setSupernovaYear(_loc1_.supernovaYear);
   }
   _loc1_.displayMC.setLightDistance(_loc1_.displayedYear - _loc1_.supernovaYear);
   if(_loc1_.displayedYear > _loc1_.supernovaYear + _loc1_.observerDistance)
   {
      _loc1_.timelineMC.setObservedLabelVisible(true);
   }
};
p.onYearCursorDragged = function(yr)
{
   var _loc1_ = this;
   var _loc2_ = yr;
   if(isNaN(_loc2_))
   {
      _loc1_.updateSim();
   }
   else if(_loc1_.state != 1)
   {
      if(_loc1_.state == 0)
      {
         if(_loc2_ > _loc1_.maxSupernovaYear)
         {
            _loc2_ = _loc1_.maxSupernovaYear;
         }
         _loc1_.displayedYear = _loc1_.supernovaYear = _loc2_;
      }
      else if(_loc1_.state == 2)
      {
         _loc1_.displayedYear = _loc2_;
         if(_loc1_.displayedYear >= _loc1_.timelineMC.maxTimelineYear - 1e-10)
         {
            _loc1_.setState(3);
         }
      }
      else if(_loc1_.state == 3)
      {
         _loc1_.displayedYear = _loc2_;
         if(_loc1_.displayedYear < _loc1_.timelineMC.maxTimelineYear - 1e-10)
         {
            _loc1_.setState(2);
         }
      }
      if(_loc1_.state == 2 || _loc1_.state == 3)
      {
         _loc1_.displayMC.showStarInThought(_loc1_.displayedYear < _loc1_.supernovaYear + _loc1_.observerDistance);
      }
      _loc1_.updateSim();
   }
};
p.onObserverDragged = function(dist)
{
   var _loc1_ = this;
   var _loc2_ = dist;
   if(_loc1_.state == 0)
   {
      _loc2_ = 100 * Math.round(_loc2_ / 100);
      _loc1_.observerDistance = _loc2_;
      _loc1_.displayMC.setObserverDistance(_loc1_.observerDistance);
   }
};
p.onStartResetButtonPressed = function()
{
   var _loc1_ = this;
   if(_loc1_.state == 0)
   {
      _loc1_.setState(1);
   }
   else
   {
      _loc1_.setState(0);
   }
};
p.onPauseResumeButtonPressed = function()
{
   var _loc1_ = this;
   if(_loc1_.state == 1)
   {
      _loc1_.setState(2);
   }
   else if(_loc1_.state == 2)
   {
      _loc1_.setState(1);
   }
};
p.setState = function(newState)
{
   var _loc1_ = this;
   var _loc2_ = newState;
   if(_loc2_ == 0)
   {
      _loc1_.displayMC.reset();
      _loc1_.timelineMC.reset();
      _loc1_.displayedYear = _loc1_.supernovaYear;
      _loc1_.displayMC.setObserverDistance(_loc1_.observerDistance);
      _loc1_.timelineMC.setCursorYear(_loc1_.supernovaYear);
      _loc1_.timelineMC.setSupernovaYear(_loc1_.supernovaYear);
      delete _loc1_.onEnterFrame;
   }
   else if(_loc2_ == 1 && _loc1_.state == 0)
   {
      _loc1_.timelineMC.setSupernovaYear(_loc1_.supernovaYear);
      _loc1_.timelineMC.setObservedYear(_loc1_.supernovaYear + _loc1_.observerDistance);
      _loc1_.displayMC.onAnimationStart();
      _loc1_.timelineMC.onAnimationStart();
      _loc1_._timeLast = getTimer();
      _loc1_.onEnterFrame = _loc1_.animateOnEnterFrame;
   }
   else if(_loc2_ == 1 && _loc1_.state == 2)
   {
      _loc1_._timeLast = getTimer();
      _loc1_.onEnterFrame = _loc1_.animateOnEnterFrame;
   }
   else if(_loc2_ == 2 && _loc1_.state == 1)
   {
      delete _loc1_.onEnterFrame;
   }
   else if(_loc2_ == 3)
   {
      delete _loc1_.onEnterFrame;
   }
   _loc1_.state = _loc2_;
   _loc1_.displayMC.setObserverDraggable(_loc1_.state == 0);
   _loc1_.timelineMC.setCursorDraggable(_loc1_.state != 1);
   if(_loc1_.state == 0)
   {
      _loc1_.startResetButton.setEnabled(true);
      _loc1_.startResetButton.setLabel("go supernova");
      _loc1_.pauseResumeButton.setEnabled(false);
      _loc1_.pauseResumeButton.setLabel("...");
   }
   else if(_loc1_.state == 1)
   {
      _loc1_.startResetButton.setEnabled(false);
      _loc1_.startResetButton.setLabel("reset");
      _loc1_.pauseResumeButton.setEnabled(true);
      _loc1_.pauseResumeButton.setLabel("pause");
   }
   else if(_loc1_.state == 2)
   {
      _loc1_.startResetButton.setEnabled(true);
      _loc1_.startResetButton.setLabel("reset");
      _loc1_.pauseResumeButton.setEnabled(true);
      _loc1_.pauseResumeButton.setLabel("resume");
   }
   else if(_loc1_.state == 3)
   {
      _loc1_.startResetButton.setEnabled(true);
      _loc1_.startResetButton.setLabel("reset");
      _loc1_.pauseResumeButton.setEnabled(false);
      _loc1_.pauseResumeButton.setLabel("...");
   }
};
