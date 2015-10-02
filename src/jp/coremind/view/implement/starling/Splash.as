package jp.coremind.view.implement.starling
{
    import flash.utils.clearInterval;
    import flash.utils.setInterval;
    
    import jp.coremind.utility.Log;
    import jp.coremind.utility.data.Status;
    import jp.coremind.utility.process.Process;
    
    import starling.core.Starling;
    import starling.display.Quad;
    import starling.display.Sprite;
    
    public class Splash extends Sprite
    {
        private var
            _id:uint,
            _loadingProcess:Process;
        
        public function Splash()
        {
            addChild(new Quad(
                Starling.current.stage.stageWidth,
                Starling.current.stage.stageHeight,
                0xff0000));
        }
        
        public function beginLoad(process:Process):void
        {
            if (process.phase !== Status.FINISHED)
            {
                _loadingProcess = process;
                _id = setInterval(function():void { onUodateProgress(_loadingProcess.progress) }, 18);
            }
        }
        
        protected function onUodateProgress(n:Number):void
        {
            Log.info(int(n * 100));
        }
        
        public function endLoad():void
        {
            clearInterval(_id);
            _loadingProcess = null;
        }
    }
}