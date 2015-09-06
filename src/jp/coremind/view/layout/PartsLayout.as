package jp.coremind.view.layout
{
    import flash.utils.Dictionary;
    
    import jp.coremind.utility.IRecycle;
    import jp.coremind.view.abstract.IElement;
    
    import starling.display.DisplayObject;

    public class PartsLayout
    {
        private var
            _element:IElement,
            _children:Dictionary;
        
        public function PartsLayout(element:IElement)
        {
            _element = element;
        }
        
        public function destroy():void
        {
            _element = null;
            
            if (_children)
            {
                for (var p:DisplayObject in _children)
                {
                    var element:IElement = _children[p] as IElement;
                    if (element) element.destroy(true);
                    
                    delete _children[p];
                }
            }
        }
        
        public function setCalculator(child:*, calculator:LayoutCalculator):void
        {
            if (!_children)
                 _children = new Dictionary(true);
            
            child in _children ?
                _children[child]:
                _children[child] = calculator;
        }
        
        public function bindStorageId(storageId:String):void
        {
            if (_children)
                for (var child:* in _children)
                    if (child is IRecycle) child.initialize(storageId);
        }
        
        public function unbindStorageId():void
        {
            if (_children)
                for (var child:* in _children)
                    if (child is IRecycle) child.reset();
        }
        
        public function refresh():void
        {
            if (_children)
                for (var child:* in _children)
                    (_children[child] as LayoutCalculator).applyDisplayObject(
                        child,
                        _element.elementWidth,
                        _element.elementHeight);
        }
    }
}