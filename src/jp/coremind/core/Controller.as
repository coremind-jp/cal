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
                _instantiateController(controllerList[i]);
            
            r.scceeded();
        }
        
        public static function notifyRemovedView(r:Routine, t:Thread, viewId:String):void
        {
            var controllerList:Array = _getControllerList(viewId);
            
            for (var i:int, len:int = controllerList.length; i < len; i++)
                _destroyController(controllerList[i]);
            
            r.scceeded();
        }
        
        private static function _getControllerList(viewId:String):Array
        {
            return viewId in _BIND_LIST ?
                _BIND_LIST[viewId]:
                _BIND_LIST[viewId] = [];
        }
        
        private static function _instantiateController(controllerClass:Class):void
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
        
        private static function _destroyController(controllerClass:Class):void
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
        
        public static function exec(controllerClass:Class, method:String, params:Array):void
        {
            controllerClass in _REFERENCE_COUNTER ?
                (_ENTITY_LIST[controllerClass] as Controller).exec(method, params):
                Log.info("undefined controller", controllerClass);
        }
        
        public function destroy():void {}
        
        /**
         * ビューからの呼び出しを処理する.
         * @param   storageId       呼び出しもとのElementオブジェクトが保持するStorageModelReaderオブジェクトのStorageId
         * @param   elementId       呼び出しもとのElementオブジェクトが保持するElementModelIdオブジェクト
         * @param   ...params       拡張パラメータ
         */
        public function exec(method:String, params:Array):void
        {
            method in this && this[method] is Function ?
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
         * f(storageValue:*, elementModel:ElementModel)
         */
        protected function each(func:Function, layerId:String, viewId:String, path:String):void
        {
            var info:ElementInfo;
            var view:IView = starlingRoot.getLayerProcessor(layerId).getView(viewId);
            
            var element:IElement = view.getElement(path);
            if (!element) return;
            
            var eachTarget:* = element.elementInfo.reader.read();
            if ($.isArray(eachTarget))
            {
                var list:Array = eachTarget;
                for (var i:int = 0, len:int = list.length; i < len; i++) 
                {
                    var listElement:IElement = view.getElement(path+"."+i);
                    if (listElement)
                        func(
                            listElement.elementInfo.reader.read(),
                            listElement.elementInfo.elementModel
                        );
                }
            }
            else
            if ($.isHash(eachTarget))
            {
                var hash:Object = eachTarget;
                for (var p:String in hash) 
                {
                    var hashElement:IElement = view.getElement(path+"."+p);
                    if (hashElement)
                        func(
                            hashElement.elementInfo.reader.read(),
                            hashElement.elementInfo.elementModel
                        );
                }
            }
        }
    }
}