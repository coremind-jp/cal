package jp.coremind.view.implement.starling
{
    import jp.coremind.utility.Log;
    import jp.coremind.utility.process.Routine;
    import jp.coremind.utility.process.Thread;
    import jp.coremind.view.abstract.IDisplayObject;
    import jp.coremind.view.abstract.IDisplayObjectContainer;
    import jp.coremind.view.abstract.IElement;
    import jp.coremind.view.abstract.IView;
    
    import starling.core.Starling;
    import starling.display.DisplayObjectContainer;
    
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
        
        private var _elementCache:Object;
        private var _counter:int = 0;
        public function allocateElementCache():void
        {
            if (_counter == 0)
            {
                Log.info(TAG, "allocateElement");
                _elementCache = {};
            }
            _counter++;
        }
        public function freeElementCache():void
        {
            _counter--;
            if (_counter == 0)
            {
                _elementCache = $.hash.free(_elementCache);
                Log.custom(TAG, "freeElementCache");
            }
        }
        
        public function getElement(path:String, ignoreError:Boolean = false):IElement
        {
            var pathList:Array = path.split(".");
            
            return _elementCache ?
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
            if (pathList.length > 1)
                latestParentPathList.pop();
            
            var result:IElement;
            var latestParentPath:String = latestParentPathList.join(".");
            if (latestParentPath in _elementCache)
                result = _elementCache[latestParentPath];
            else
            {
                //親が見つかったならキャッシュしておく
                result = _getElement(latestParentPathList, ignoreError);
                if (result) _elementCache[latestParentPath] = result;
            }
            
            //最後に子を取得して返す
            if (result && pathList.length > 1)
                result = findChild(result, pathList[pathList.length - 1]) as IElement;
            
            return result;
        }
        
        private function dumpChildrenNameList(container:DisplayObjectContainer):void
        {
            var r:Array = [];
            for (var i:int = 0; i < container.numChildren; i++) 
                r.push(container.getChildAt(i).name);
            
            Log.info(container.name, "children list:", r);
        }
        
        private function findChild(parent:IDisplayObjectContainer, name:String):IDisplayObject
        {
            var result:IDisplayObject = parent.getDisplayByName(name);
            return result ? result: null;
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