package jp.coremind.view.implement.flash
{
    import jp.coremind.control.Controller;
    import jp.coremind.core.Application;
    import jp.coremind.core.TransitionTween;
    import jp.coremind.model.ViewModel;
    import jp.coremind.utility.Log;
    import jp.coremind.utility.process.Routine;
    import jp.coremind.utility.process.Thread;
    import jp.coremind.view.abstract.IElement;
    import jp.coremind.view.abstract.IView;
    
    public class View extends CalSprite implements IView
    {
        public static const TAG:String = "[FlashView]";
        Log.addCustomTag(TAG);
        
        private var
            _controller:Controller;
        
        /**
         * 画面表示オブジェクトクラス.
         * 画面のルートでViewControllerから制御される。
         */
        public function View(name:String = null)
        {
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
            r.scceeded();
            /*
            if (viewName)
            {
                var bluePrint:IElementBluePrint = Application.configure.elementBluePrint;
                _buildBluePrint(bluePrint.createNavigationList(viewName));
                r.scceeded();
            }
            else r.failed("'viewName' is null. please set value.");
            */
        }
        
        protected function _buildBluePrint(list:Array):void
        {
            var w:int = Application.configure.appViewPort.width;
            var h:int = Application.configure.appViewPort.height;
            
            for (var i:int = 0; i < list.length; i++) 
            {
                var name:String = list[i];
                /** TODO FlashAPI用Builderがまだない */
                //addChild(Application.elementBuilder.createBuilder(name).build(name, w, h));
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
            r.scceeded(name + " focusInPreProcess");
        }
        
        public function get focusInTransition():Function
        {
            return TransitionTween.FAST_ADD;
        }
        
        public function focusInPostProcess(r:Routine, t:Thread):void
        {
            r.scceeded(name + " focusInPostProcess");
        }
        
        public function focusOutPreProcess(r:Routine, t:Thread):void
        {
            r.scceeded(name + " focusOutPreProcess");
        }
        
        public function get focusOutTransition():Function
        {
            return TransitionTween.SKIP;
        }
        
        public function focusOutPostProcess(r:Routine, t:Thread):void
        {
            r.scceeded(name + " focusOutPostProcess");
        }
        
        public function destroyProcess(r:Routine, t:Thread):void
        {
            destroy(true);
            r.scceeded(name + " destroyProcess");
        }
    }
}