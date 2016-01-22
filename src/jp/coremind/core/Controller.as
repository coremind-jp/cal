package jp.coremind.core
{
    import flash.utils.Dictionary;
    
    import jp.coremind.event.ElementInfo;
    import jp.coremind.utility.Log;
    import jp.coremind.utility.process.Routine;
    import jp.coremind.utility.process.Thread;
    import jp.coremind.view.abstract.IElement;
    import jp.coremind.view.abstract.IView;

    public class Controller extends ViewAccessor
    {
        private static const _REFERENCE_COUNTER:Dictionary = new Dictionary(true);
        private static const _ENTITY_LIST:Dictionary = new Dictionary(true);
        private static const _BIND_LIST:Object = {};
        
        public static function bindView(viewId:String, controllerClass:Class):void
        {
            var controllerList:Array = _getControllerList(viewId);
            
            var i:int = controllerList.indexOf(controllerClass);
            if (i == -1) controllerList.push(controllerClass);
        }
        
        public static function notifyAddedView(r:Routine, t:Thread, viewId:String):void
        {
            var controllerList:Array = _getControllerList(viewId);
            
            for (var i:int, len:int = controllerList.length; i < len; i++)
                _instantiate(controllerList[i]);
            
            r.scceeded();
        }
        
        public static function notifyRemovedView(r:Routine, t:Thread, viewId:String):void
        {
            var controllerList:Array = _getControllerList(viewId);
            
            for (var i:int, len:int = controllerList.length; i < len; i++)
                _destroy(controllerList[i]);
            
            r.scceeded();
        }
        
        private static function _getControllerList(viewId:String):Array
        {
            return viewId in _BIND_LIST ?
                _BIND_LIST[viewId]:
                _BIND_LIST[viewId] = [];
        }
        
        private static function _instantiate(controllerClass:Class):void
        {
            if (_REFERENCE_COUNTER[controllerClass])
                _REFERENCE_COUNTER[controllerClass]++;
            else
            {
                var controller:* = new controllerClass();
                if (controller is Controller)
                {
                    _ENTITY_LIST[controllerClass] = controller;
                    _REFERENCE_COUNTER[controllerClass] = 1;
                }
                else Log.warning(controllerClass, "is not extended Controller.");
            }
        }
        
        private static function _destroy(controllerClass:Class):void
        {
            if (!(controllerClass in _REFERENCE_COUNTER))
                return;
            
            _REFERENCE_COUNTER[controllerClass]--;
            if (_REFERENCE_COUNTER[controllerClass] == 0)
            {
                var temp:Controller = _ENTITY_LIST[controllerClass];
                
                delete _REFERENCE_COUNTER[controllerClass];
                delete       _ENTITY_LIST[controllerClass];
                
                temp.destroy();
            }
        }
        
        public static function exec(controllerClass:Class, method:String, params:Array):*
        {
            return controllerClass in _REFERENCE_COUNTER ?
                (_ENTITY_LIST[controllerClass] as Controller).exec(method, params):
                Log.info("undefined controller", controllerClass);
        }
        
        public function destroy():void {}
        
        /**
         * ビューからの呼び出しを処理する.
         * @param   method       呼び出し先クラスに実装されているメソッド名
         * @param   ...params    呼び出し先クラスに実装されているメソッドへ渡すパラメータ
         */
        public function exec(method:String, params:Array):*
        {
            return method in this && this[method] is Function ?
                this[method].apply(null, params):
                Log.warning("undefined Controller method.", this,
                    "\n[undefined method]", method,
                    "\n[params]", params);
        }
        
        public function fetchElementInfo(layerId:String, viewId:String, path:String):ElementInfo
        {
            return starlingRoot.getLayerProcessor(layerId).getView(viewId).getElement(path).elementInfo;
        }
        
        /**
         * fの引数は次の通り
         * f(e:IElement):void
         */
        protected function each(func:Function, layerId:String, viewId:String, path:String):void
        {
            var  view:IView = starlingRoot.getLayerProcessor(layerId).getView(viewId);
            if (!view) return;
            
            var  element:IElement = view.getElement(path, true);
            if (!element) return;
            
            var list:Array = element.elementInfo.reader.read() as Array;
            if (list)
            {
                view.allocateElementCache();
                
                for (var i:int = 0, len:int = list.length; i < len; i++) 
                {
                    var listElement:IElement = view.getElement(path+"."+i, true);
                    if (listElement && func(listElement)) break;
                }
                
                view.freeElementCache();
            }
            else func(element);
        }
    }
}