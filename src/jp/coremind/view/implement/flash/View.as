package jp.coremind.view.implement.flash
{
    import jp.coremind.core.Application;
    import jp.coremind.utility.Log;
    import jp.coremind.utility.process.Routine;
    import jp.coremind.utility.process.Thread;
    import jp.coremind.view.abstract.IDisplayObject;
    import jp.coremind.view.abstract.IDisplayObjectContainer;
    import jp.coremind.view.abstract.IElement;
    import jp.coremind.view.abstract.IView;
    
    import org.hamcrest.object.nullValue;
    
    public class View extends CalSprite implements IView
    {
        public static const TAG:String = "[FlashView]";
        Log.addCustomTag(TAG);
        
        private var _isFocus:Boolean;
        
        /**
         * 画面表示オブジェクトクラス.
         * 画面のルートでViewControllerから制御される。
         */
        public function View()
        {
            _isFocus = false;
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
        
        private var _temporary:Object;
        public function allocateElementCache():void
        {
            _temporary = {};
        }
        public function freeElementCache():void
        {
            _temporary = $.hash.free(_temporary);
        }
        
        public function getElement(path:String, ignoreError:Boolean = false):IElement
        {
            var pathList:Array = path.split(".");
            
            return _temporary ?
                _getElementForCache(pathList, ignoreError):
                _getElement(pathList, ignoreError);
        }
        
        private function _getElement(pathList:Array, ignoreError:Boolean = false):IElement
        {
            var result:IElement = findChild(this, pathList[0]) as IElement;
            
            for (var i:int = 1, len:int = pathList.length; i < len && result; i++)
                result = findChild(result, pathList[i]) as IElement;
            
            if (!result)
                ignoreError ?
                    1://Log.custom(TAG, "element not found. path:", path, " suspendPosition:", pathList[i-1], " view:", name):
                    Log.error("element not found. path:", pathList.join("."), " suspendPosition:", pathList[i-1], " view:", name);
            
            return result;
        }
        
        private function _getElementForCache(pathList:Array, ignoreError:Boolean = false):IElement
        {
            var latestParentPathList:Array = pathList.slice();
            latestParentPathList.pop();
            
            var result:IElement;
            var latestParentPath:String = latestParentPathList.join(".");
            if (latestParentPath in _temporary)
            {
                Log.info("use Cache", latestParentPath);
                result = _temporary[latestParentPath];
            }
            else
            {
                //親が見つかったならキャッシュしておく
                result = _getElement(latestParentPathList, ignoreError);
                if (result) _temporary[latestParentPath] = result;
            }
            
            //最後に子を取得して返す
            if (result && pathList.length > 1)
                result = findChild(result, pathList[pathList.length - 1]) as IElement;
            
            return result;
        }
        
        private function findChild(parent:IDisplayObjectContainer, name:String):IDisplayObject
        {
            return null;
        }
        
        public function focusInPreProcess(r:Routine, t:Thread):void
        {
            r.scceeded(name + " focusInPreProcess");
            _isFocus = true;
        }
        
        public function focusInPostProcess(r:Routine, t:Thread):void
        {
            r.scceeded(name + " focusInPostProcess");
        }
        
        public function focusOutPreProcess(r:Routine, t:Thread):void
        {
            r.scceeded(name + " focusOutPreProcess");
            _isFocus = false;
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