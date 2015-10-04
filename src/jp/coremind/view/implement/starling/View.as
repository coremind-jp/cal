package jp.coremind.view.implement.starling
{
    import jp.coremind.configure.IElementBluePrint;
    import jp.coremind.configure.IViewBluePrint;
    import jp.coremind.control.Controller;
    import jp.coremind.core.Application;
    import jp.coremind.core.TransitionTween;
    import jp.coremind.model.ViewModel;
    import jp.coremind.utility.Log;
    import jp.coremind.utility.process.Routine;
    import jp.coremind.utility.process.Thread;
    import jp.coremind.view.abstract.IDisplayObject;
    import jp.coremind.view.abstract.IElement;
    import jp.coremind.view.abstract.IView;
    
    import starling.core.Starling;
    
    public class View extends CalSprite implements IView
    {
        public static const TAG:String = "[StarlingView]";
        Log.addCustomTag(TAG);
        
        private var
            _controller:Controller;
        
        /**
         * 画面表示オブジェクトクラス.
         * 画面のルートでViewControllerから制御される。
         */
        public function View(name:String = null)
        {
            pivotX = Starling.current.stage.stageWidth  >> 1;
            pivotY = Starling.current.stage.stageHeight >> 1;
            x = pivotX;
            y = pivotY;
            
            name === null ? Log.error("[View] name is null.", this): this.name = name;
            
            _controller = Controller.getInstance(
                Application.configure.viewBluePrint.getControllerClass(name),
                new ViewModel(this));
        }
        
        override public function destroy(withReference:Boolean=false):void
        {
            super.destroy(withReference);
            
            _controller = null;
        }
        
        public function get controller():Controller { return _controller; }
        
        public function initializeProcess(r:Routine, t:Thread):void
        {
            Log.custom(TAG, name, "initializeProcess");
            
            var bluePrint:IViewBluePrint = Application.configure.viewBluePrint;
            var viewClass:Class = $.getClassByInstance(this);
            
            _buildElement(viewClass === View ?
                bluePrint.createContentListByCommonView(name):
                bluePrint.createContentListByUniqueView(viewClass));
            
            ready();
            r.scceeded();
        }
        
        public function ready():void
        {
            Log.custom(TAG, name, "ready");
        }
        
        protected function _buildElement(list:Array):void
        {
            var w:int = Application.configure.appViewPort.width;
            var h:int = Application.configure.appViewPort.height;
            var bluePrint:IElementBluePrint = Application.configure.elementBluePrint;
            
            for (var i:int = 0; i < list.length; i++) 
            {
                var name:String = list[i];
                addDisplay(bluePrint.createBuilder(name).build(name, w, h) as IDisplayObject);
            }
        }
        
        public function getElement(path:String):IElement
        {
            var pathList:Array = path.split(".");
            var child:IElement;
            
            for (var i:int, len:int = pathList.length; i < len; i++)
            {
                child = getDisplayByName(pathList[i]) as IElement;
                if (!child) Log.error(pathList[i], "not found.", path);
            }
            
            return child;
        }
        
        public function focusInPreProcess(r:Routine, t:Thread):void
        {
            Log.custom(TAG, name, "focusInPreProcess");
            r.scceeded();
        }
        
        public function get focusInTransition():Function
        {
            return TransitionTween.FAST_ADD;
        }
        
        public function focusInPostProcess(r:Routine, t:Thread):void
        {
            Log.custom(TAG, name, "focusInPostProcess");
            r.scceeded();
        }
        
        public function focusOutPreProcess(r:Routine, t:Thread):void
        {
            Log.custom(TAG, name, "focusOutPreProcess");
            r.scceeded();
        }
        
        public function get focusOutTransition():Function
        {
            return TransitionTween.SKIP;
        }
        
        public function focusOutPostProcess(r:Routine, t:Thread):void
        {
            Log.custom(TAG, name, "focusOutPostProcess");
            r.scceeded();
        }
        
        public function destroyProcess(r:Routine, t:Thread):void
        {
            destroy(true);
            r.scceeded(name + " destroyProcess");
        }
    }
}