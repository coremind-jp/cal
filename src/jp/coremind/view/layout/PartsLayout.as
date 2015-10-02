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
    import jp.coremind.view.abstract.IDisplayObject;
    import jp.coremind.view.abstract.IElement;
    import jp.coremind.view.abstract.component.Grid9;
    import jp.coremind.view.builder.IDisplayObjectBuilder;
    import jp.coremind.view.implement.starling.Container;

    public class PartsLayout
    {
        public static const TAG:String = "[PartsLayout]";
        Log.addCustomTag(TAG);
        
        private var
            _element:IElement,
            _calculatorList:Dictionary;
        
        public function PartsLayout(element:IElement)
        {
            _element = element;
        }
        
        public function destroy():void
        {
            //Log.custom(TAG, "[destroy]", _element.storageId);
            for (var child:IBox in _calculatorList)
            {
                if (child is ICalSprite) (child as ICalSprite).destroy(true);
                
                (_calculatorList[child] as LayoutCalculator).destroy();
                
                delete _calculatorList[child];
            }
            
            _element = null;
        }
        
        public function buildParts():void
        {
            Log.custom(TAG, _element.storageId, "buildParts", _element);
            
            var element:String   = "jp.coremind.view.implement.starling.Element";
            var container:String = "jp.coremind.view.implement.starling.Container";
            var actual:String    = getQualifiedClassName(_element);
            var bluePrintKey:* = actual === element || actual === container ?
                _element.name:
                $.getClassByInstance(_element);
            
            _buildBuildinParts(bluePrintKey);
            
            if (_element is Container)
                _buildElementParts(bluePrintKey);
        }
        
        private function _buildBuildinParts(bluePrintKey:*):void
        {
            Log.custom(TAG, "[buildin]");
            
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
                
                _bindCalculator(child, builder.requestLayoutCalculator());
            }
        }
        
        private function _buildElementParts(bluePrintKey:*):void
        {
            Log.custom(TAG, "[Element]");
            
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
                
                _bindCalculator(child, builder.requestLayoutCalculator());
            }
        }
        
        public function isBuildedParts():Boolean
        {
            return Boolean(_calculatorList);
        }
        
        private function _bindCalculator(child:IBox, calculator:LayoutCalculator):void
        {
            if (!_calculatorList) _calculatorList = new Dictionary(false);
            _calculatorList[child] = calculator;
        }
        
        public function reset():void
        {
            Log.custom(TAG, "[reset]", _element.storageId);
            if (_calculatorList)
                for (var child:* in _calculatorList)
                    if (child is IRecycle) child.reset();
        }
        
        public function refresh():void
        {
            if (_calculatorList)
                for (var child:IBox in _calculatorList)
                    (_calculatorList[child] as LayoutCalculator).applyDisplayObject(
                        child,
                        _element.elementWidth,
                        _element.elementHeight);
        }
    }
}