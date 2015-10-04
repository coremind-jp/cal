package jp.coremind.view.layout
{
    import flash.utils.Dictionary;
    import flash.utils.getQualifiedClassName;
    
    import jp.coremind.configure.IElementBluePrint;
    import jp.coremind.configure.IPartsBluePrint;
    import jp.coremind.core.Application;
    import jp.coremind.utility.IRecycle;
    import jp.coremind.utility.Log;
    import jp.coremind.view.abstract.IBox;
    import jp.coremind.view.abstract.ICalSprite;
    import jp.coremind.view.abstract.IContainer;
    import jp.coremind.view.abstract.IDisplayObject;
    import jp.coremind.view.abstract.IElement;
    import jp.coremind.view.abstract.component.Grid9;
    import jp.coremind.view.builder.IDisplayObjectBuilder;

    public class PartsLayout
    {
        private static const _PLAIN_ELEMENT_CLASS:Array = [
            "jp.coremind.view.implement.starling::Container",
            "jp.coremind.view.implement.starling::Element",
            "jp.coremind.view.implement.starling::InteractiveElement",
            "jp.coremind.view.implement.starling::MouseElement",
            "jp.coremind.view.implement.starling::StatefulElement",
            "jp.coremind.view.implement.starling::TouchElement",
            "jp.coremind.view.implement.starling.component::ListContainer",
            "jp.coremind.view.implement.starling.component::MouseSwitch",
            "jp.coremind.view.implement.starling.component::ScrollContainer",
            "jp.coremind.view.implement.starling.component::TouchSwitch"
        ];
        
        public static const TAG:String = "[PartsLayout]";
        Log.addCustomTag(TAG);
        
        private var
            _element:IElement,
            _layoutList:Dictionary;
        
        public function PartsLayout(element:IElement)
        {
            _element = element;
        }
        
        public function destroy():void
        {
            //Log.custom(TAG, "[destroy]", _element.storageId);
            for (var child:IBox in _layoutList)
            {
                if (child is ICalSprite) (child as ICalSprite).destroy(true);
                delete _layoutList[child];
            }
            
            _element = null;
        }
        
        public function buildParts():void
        {
            var actual:String  = getQualifiedClassName(_element);
            var bluePrintKey:* = _PLAIN_ELEMENT_CLASS.indexOf(actual) == -1 ? $.getClassByInstance(_element): _element.name;
            
            Log.custom(TAG, "buildParts", _element.name, bluePrintKey);
            
            _buildBuildinParts(bluePrintKey);
            
            if (_element is IContainer)
                _buildElementParts(bluePrintKey);
        }
        
        private function _buildBuildinParts(bluePrintKey:*):void
        {
            Log.custom(TAG, " >[buildin]");
            
            var builder:IDisplayObjectBuilder;
            var child:IBox;
            var bluePrint:IPartsBluePrint = Application.configure.partsBluePrint;
            var partsList:Array = bluePrintKey is String ?
                bluePrint.createPartsListByName(bluePrintKey):
                bluePrint.createPartsListByClass(bluePrintKey);
            
            for (var i:int, len:int = partsList.length; i < len; i++) 
            {
                builder = bluePrint.createBuilder(partsList[i]);
                child   = builder.build(partsList[i], _element.elementWidth, _element.elementHeight);
                _element.addDisplay(child is Grid9 ? (child as Grid9).asset: child as IDisplayObject);
                
                _bindLayout(child, builder.layout);
            }
            
            Log.custom(TAG, " <[buildin]");
        }
        
        private function _buildElementParts(bluePrintKey:*):void
        {
            Log.custom(TAG, " >[Element]");
            
            var builder:IDisplayObjectBuilder;
            var child:IBox;
            var bluePrint:IElementBluePrint = Application.configure.elementBluePrint;
            var partsList:Array = bluePrintKey is String ?
                bluePrint.createPartsListByName(bluePrintKey):
                bluePrint.createPartsListByClass(bluePrintKey);
            
            for (var i:int, len:int = partsList.length; i < len; i++) 
            {
                builder = bluePrint.createBuilder(partsList[i]);
                child   = builder.build(partsList[i], _element.elementWidth, _element.elementHeight);
                _element.addDisplay(child as IDisplayObject);
                
                _bindLayout(child, builder.layout);
            }
            
            Log.custom(TAG, " <[Element]");
        }
        
        public function isBuildedParts():Boolean
        {
            return Boolean(_layoutList);
        }
        
        private function _bindLayout(child:IBox, layout:Layout):void
        {
            if (!_layoutList) _layoutList = new Dictionary(false);
            _layoutList[child] = layout;
        }
        
        public function reset():void
        {
            Log.custom(TAG, "[reset]", _element.name);
            if (_layoutList)
                for (var child:* in _layoutList)
                    if (child is IRecycle) child.reset();
        }
        
        public function refresh():void
        {
            Log.custom(TAG, "[refresh]", _element.name);
            if (_layoutList)
                for (var child:IBox in _layoutList)
                    (_layoutList[child] as Layout).applyDisplayObject(
                        child,
                        _element.elementWidth,
                        _element.elementHeight);
        }
    }
}