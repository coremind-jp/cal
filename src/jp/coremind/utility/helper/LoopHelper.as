package jp.coremind.utility.helper
{
    import jp.coremind.utility.process.FramePostProcessLoop;
    import jp.coremind.utility.process.FramePreProcessLoop;
    import jp.coremind.utility.process.JugglerLoop;
    import jp.coremind.utility.process.TimerLoop;

    public class LoopHelper
    {
        private var
            _lowResolutionTimer:TimerLoop,
            _highResolutionTimer:TimerLoop,
            _framePreProcess:FramePreProcessLoop,
            _framePostProcess:FramePostProcessLoop,
            _juggler:JugglerLoop;
        
        public function LoopHelper()
        {
        }
        
        public function run():void
        {
            _lowResolutionTimer  = new TimerLoop(250);  // 1/4 sec
            _highResolutionTimer = new TimerLoop(18);   // 60  fps
            _framePreProcess     = new FramePreProcessLoop();   //stage refresh rate an application.
            _framePostProcess    = new FramePostProcessLoop();  //stage refresh rate an application.
            _juggler             = new JugglerLoop();
        }
        
        public function terminate():void
        {
            _lowResolutionTimer.terminate();
            _highResolutionTimer.terminate();
            _framePreProcess.terminate();
            _framePostProcess.terminate();
            _juggler.terminate();
        }
        
        public function get lowResolution():TimerLoop               { return _lowResolutionTimer; }
        public function get highResolution():TimerLoop              { return _highResolutionTimer; }
        public function get framePreProcess():FramePreProcessLoop   { return _framePreProcess; }
        public function get framePostProcess():FramePostProcessLoop { return _framePostProcess; }
        public function get juggler():JugglerLoop                   { return _juggler; }
    }
}