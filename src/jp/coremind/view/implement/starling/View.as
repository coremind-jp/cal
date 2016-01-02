package jp.coremind.view.implement.starling
{
    import jp.coremind.utility.Log;
    import jp.coremind.utility.process.Routine;
    import jp.coremind.utility.process.Thread;
    import jp.coremind.view.abstract.IElement;
    import jp.coremind.view.abstract.IView;
    
    import starling.core.Starling;
    
    public class View extends CalSprite implements IView
    {
        public static const TAG:String = "[StarlingView]";
        Log.addCustomTag(TAG);
        
        private var _isFocus:Boolean;
        
        /**
         * 画面表示オブジェクトクラス.
         * 画面のルートでViewControllerから制御される。
         */
        public function View()
        {
            x = pivotX = Starling.current.stage.stageWidth  >> 1;
            y = pivotY = Starling.current.stage.stageHeight >> 1;
            
            _isFocus = touchable = false;
        }
        
        override public function destroy(withReference:Boolean=false):void
        {
            super.destroy(withReference);
        }
        
        public function isFocus():Boolean { return _isFocus; }
        
        public function initializeProcess(r:Routine, t:Thread):void
        {
            Log.custom(TAG, name, "initializeProcess");
            ready();
            r.scceeded();
        }
        
        public function ready():void
        {
            Log.custom(TAG, name, "ready");
        }
        
        public function getElement(path:String):IElement
        {
            var pathList:Array = path.split(".");
            var child:IElement = getDisplayByName(pathList.shift()) as IElement;
            
            for (var i:int, len:int = pathList.length; i < len && child; i++)
                child = child.getDisplayByName(pathList[i]) as IElement;
            
            if (!child)
                Log.error(pathList[i], "not found.", path);
            
            return child;
        }
        
        public function focusInPreProcess(r:Routine, t:Thread):void
        {
            Log.custom(TAG, name, "focusInPreProcess");
            _isFocus = true;
            r.scceeded();
        }
        
        public function focusInPostProcess(r:Routine, t:Thread):void
        {
            Log.custom(TAG, name, "focusInPostProcess");
            touchable = true;
            r.scceeded();
        }
        
        public function focusOutPreProcess(r:Routine, t:Thread):void
        {
            Log.custom(TAG, name, "focusOutPreProcess");
            _isFocus = false;
            r.scceeded();
        }
        
        public function focusOutPostProcess(r:Routine, t:Thread):void
        {
            Log.custom(TAG, name, "focusOutPostProcess");
            touchable = false;
            r.scceeded();
        }
        
        public function destroyProcess(r:Routine, t:Thread):void
        {
            destroy(true);
            r.scceeded(name + " destroyProcess");
        }
    }
}