package jp.coremind.asset
{
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.geom.Rectangle;
    import flash.media.Sound;
    import flash.system.System;
    
    import jp.coremind.asset.painter.RuntimeTexturePainter;
    import jp.coremind.configure.IAssetConfigure;
    import jp.coremind.control.Controller;
    import jp.coremind.core.Application;
    import jp.coremind.core.routine.WebRequest;
    import jp.coremind.event.ViewTransitionEvent;
    import jp.coremind.utility.Log;
    import jp.coremind.utility.process.Routine;
    import jp.coremind.utility.process.Thread;

    public class Asset
    {
        private static const TAG:String = "[Asset]";
        Log.addCustomTag(TAG);
        
        private static const _REFERENCE_COUNTER:Object = {};
        private static const _CONTAINER:Object = {};
        
        public static function initialize():void
        {
            Application.globalEvent.addEventListener(ViewTransitionEvent.VIEW_DESTROY_AFTER, free);
        }
        
        public static function allocate(pId:String, viewName:String):void
        {
            var controller:Controller = Controller.getInstance();
            
            var fileList:Array = Application.configure.asset.getAllocateIdList(viewName);
            _UpdateReferenceCounterByAllocate(fileList);
            
            var loadThread:Thread = new Thread("AssetLoading ["+viewName+"]");
            for (var i:int = 0; i < fileList.length; i++) 
                loadThread.pushRoutine(WebRequest.create(fileList[i], fileList[i]));
            controller.syncProcess.pushThread(pId, loadThread, true, false);
            
            controller.syncProcess
                .pushThread(pId, new Thread("AssetAllocate ["+viewName+"]")
                .pushRoutine(function(r:Routine, t:Thread):void
                {
                    for (var i:int = 0; i < fileList.length; i++) 
                        fileList[i] in _CONTAINER ?
                            fileList.splice(i--, 1):
                            _CONTAINER[fileList[i]] = t.readData(fileList[i]);
                    
                    for (var j:int = 0; j < fileList.length; j++) 
                        if (_CONTAINER[fileList[j]] is Bitmap)
                            _CONTAINER[fileList[j]] = _CreateTexturePicker(fileList[j]);
                    
                    r.scceeded("\nalocated" + Log.toString(fileList)
                             + "\ndumpReferenceCounter" + Log.toString(_REFERENCE_COUNTER));
                }), true, false);
        }
        
        private static function _UpdateReferenceCounterByAllocate(fileList:Array):void
        {
            for (var i:int = 0; i < fileList.length; i++) 
            {
                var assetId:String = fileList[i];
                
                assetId in _REFERENCE_COUNTER ?
                    _REFERENCE_COUNTER[assetId]++:
                    _REFERENCE_COUNTER[assetId] = 1;
            }
        }
        
        private static function _CreateTexturePicker(assetId:String):TexturePicker
        {
            Log.custom(TAG, "createTexturePicker [", assetId, "]");
            var result:TexturePicker = new TexturePicker();
            
            var configure:IAssetConfigure = Application.configure.asset;
            var atlasId:String = configure.getAtlasId(assetId);
            var rect:Rectangle = configure.getPaintableArea(assetId);
            if (atlasId)
            {
                configure
                    .getPainterList(assetId)
                    .forEach(function(painter:RuntimeTexturePainter, i:int, arr:Array):void {
                        Log.custom(TAG, "addPainter", painter);
                        result.addPainter(painter);
                    });
                
                result.initialize(_BitmapData(assetId), xml(atlasId), rect);
                
                configure
                    .getBitmapFontConfigureList(assetId)
                    .forEach(function(bitmapFont:Object, i:int, arr:Array):void {
                        Log.custom(TAG, "createBitmapFont", bitmapFont);
                        result.createBitmapFont(bitmapFont.name, xml(bitmapFont.id));
                    });
            }
            else Log.warning("undefined atlasId. assetId:", assetId);
            
            return result;
        }
        
        public static function free(e:ViewTransitionEvent):void
        {
            Log.custom(TAG, "free [", e.name, "]");
            
            var fileList:Array = Application.configure.asset.getAllocateIdList(e.name);
            _UpdateReferenceCounterByFree(fileList);
            
            Log.custom(TAG, "free targets" , fileList, "\ndumpReferenceCounter", _REFERENCE_COUNTER);
            for (var i:int = 0; i < fileList.length; i++) 
            {
                var assetId:String = fileList[i];
                var asset:* = _CONTAINER[assetId];
                
                if (asset is TexturePicker) (asset as TexturePicker).destroy();
                else
                if (_CONTAINER[assetId] is XML) System.disposeXML(asset);
                
                delete _CONTAINER[assetId];
            }
        }
        
        private static function _UpdateReferenceCounterByFree(fileList:Array):void
        {
            for (var i:int = 0; i < fileList.length; i++) 
            {
                var assetId:String = fileList[i];
                if (assetId in _REFERENCE_COUNTER)
                    --_REFERENCE_COUNTER[assetId] > 0 ?
                        fileList.splice(i--, 1):
                        delete _REFERENCE_COUNTER[assetId];
            }
        }
        
        public static function _BitmapData(assetId:String):BitmapData
        {
            return _HasAsset(assetId, Bitmap) ? _CONTAINER[assetId].bitmapData: null;
        }
        
        public static function sound(assetId:String):Sound
        {
            return _HasAsset(assetId, Sound) ? _CONTAINER[assetId]: null;
        }
        
        public static function texture(assetId:String):TexturePicker
        {
            return _HasAsset(assetId, TexturePicker) ? _CONTAINER[assetId]: null;
        }
        
        public static function xml(assetId:String):XML
        {
            return _HasAsset(assetId, XML) ? _CONTAINER[assetId]: null;
        }
        
        private static function _HasAsset(assetId, klass:Class):Boolean
        {
            if (!(assetId in _CONTAINER))
            {
                Log.error("unallocated asset. assetId:", assetId);
                return false;
            }
            else
            if (!_CONTAINER[assetId] is klass)
            {
                Log.error("invalid asset reqeust. assetId:", assetId, "expect class:", klass, "actual class:", $.getClassByInstance(_CONTAINER[assetId]));
                return false;
            }
            else return true;
        }
    }
}