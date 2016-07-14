package jp.coremind.controller
{
    import flash.geom.Point;
    import flash.geom.Rectangle;
    
    import jp.coremind.core.Application;
    import jp.coremind.event.ElementInfo;
    import jp.coremind.module.ScrollModule;
    import jp.coremind.storage.ModelWriter;
    import jp.coremind.storage.transaction.HashTransaction;
    import jp.coremind.utility.data.NumberTracker;
    import jp.coremind.view.abstract.IElement;
    import jp.coremind.view.interaction.Drag;
    
    public class SliderController extends Controller
    {
        private static const _TMP_POINT:Point    = new Point();
        private static const _TMP_RECT:Rectangle = new Rectangle();
        
        private static var _CONFIGURE_LIST:Vector.<SliderConfigure2D> = new <SliderConfigure2D>[];
        public static function addConfigure(configure:SliderConfigure2D):int
        {
            return _CONFIGURE_LIST.push(configure) - 1;
        }
        
        private var _currentConfigureId:int;
        
        private function get configure():SliderConfigure2D
        {
            return _CONFIGURE_LIST[_currentConfigureId];
        }
        
        public function beginSlide(info:ElementInfo, confId:int):void
        {
            var  dragElement:IElement = info.path.fetchElement(starlingRoot);
            if (!dragElement || confId < 0 && _CONFIGURE_LIST.length <= confId)
                return;
            
            _currentConfigureId = confId;
            
            //ドラッグ対象の親がScrollModuleを保持している場合停止させる.
            var parent:IElement  = dragElement.parentDisplay as IElement;
            var mod:ScrollModule;
            if (parent)
            {
                parent.elementInfo.path.fetchView(starlingRoot).allocateElementCache();
                
                mod = parent.elementInfo.modules.isUndefined(ScrollModule) ?
                    null:
                    parent.elementInfo.modules.getModule(ScrollModule) as ScrollModule;
                
                if (mod) mod.ignorePointerDevice(true);
            }
            
            //closure variable
            var storageId:String   = dragElement.elementInfo.reader.id;
            var writer:ModelWriter = storage.requestWriter(storageId);
            
            //closure
            var updater:Function = function(transaction:HashTransaction, target:SliderConfigure, tracker:NumberTracker):void
            {
                var min:Number = storage.requestReader(storageId+"."+target.storageIdByMin).read();
                var max:Number = storage.requestReader(storageId+"."+target.storageIdByMax).read();
                var range:Number = max - min;
                
                target.fractionsOmit ?
                    transaction.update(range * tracker.rate    , target.storageIdByCurrent):
                    transaction.update(range * tracker.rate | 0, target.storageIdByCurrent);
            };
            
            var updateStorageValue:Function = function(x:NumberTracker, y:NumberTracker):void
            {
                var transaction:HashTransaction = writer.requestTransactionByHash();
                
                if (configure.isEnabledHorizontalSlide()) updater(transaction, configure.horizontal, x);
                if (configure.isEnabledVerticalSlide())   updater(transaction, configure.vertical, y);
                
                writer.preview();
                writer.commit();
            };
            
            var onDrop:Function = function(x:NumberTracker, y:NumberTracker):void
            {
                updateStorageValue(x, y);
                
                if (parent)
                {
                    parent.elementInfo.path.fetchView(starlingRoot).freeElementCache();
                    if (mod) mod.ignorePointerDevice(false);
                }
            };
            
            //drag initialize
            dragElement.toLocalPoint(Application.pointer, _TMP_POINT);
            _TMP_RECT.setTo(_TMP_POINT.x, _TMP_POINT.y, dragElement.elementWidth, dragElement.elementHeight);
            
            var dragger:Drag = new Drag(0);
            dragger.initialize(_TMP_RECT, configure.slideArea, updateStorageValue, onDrop);
            dragger.beginPointerDeviceListening();
        }
    }
}