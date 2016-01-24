package jp.coremind.module
{
    import jp.coremind.asset.GridAsset;
    import jp.coremind.utility.Dispatcher;
    import jp.coremind.utility.data.NumberTracker;
    import jp.coremind.view.abstract.component.Grid3X;
    import jp.coremind.view.abstract.component.Grid3Y;
    import jp.coremind.view.interaction.Scrollbar;
    
    public class ScrollbarModule extends Dispatcher implements IModule
    {
        private var _xScrollList:Vector.<Scrollbar>;
        private var _yScrollList:Vector.<Scrollbar>;
        
        public function ScrollbarModule()
        {
            super();
            _xScrollList = new <Scrollbar>[];
            _yScrollList = new <Scrollbar>[];
        }
        
        override public function destroy():void
        {
            while (_xScrollList.length > 0) _xScrollList.pop().destroy(true);
            while (_yScrollList.length > 0) _yScrollList.pop().destroy(true);
            
            _xScrollList = _yScrollList = null;
        }
        
        public function initializeX(parts:GridAsset, size:Number, position:Number):int
        {
            return _xScrollList.push(new Scrollbar(new Grid3X().setAsset(parts), size, position)) - 1;
        }
        
        public function initializeY(parts:GridAsset, size:Number, position:Number):int
        {
            return _yScrollList.push(new Scrollbar(new Grid3Y().setAsset(parts), size, position)) - 1;
        }
        
        public function updateWidth(pageSize:Number, containerSize:Number):void
        {
            for (var i:int = 0, len:int = _xScrollList.length; i < len; i++) 
                _xScrollList[i].setRange(pageSize, containerSize);
        }
        
        public function updateHeight(pageSize:Number, containerSize:Number):void
        {
            for (var i:int = 0, len:int = _yScrollList.length; i < len; i++) 
                _yScrollList[i].setRange(pageSize, containerSize);
        }
        
        public function update(...params):void
        {
            var x:NumberTracker = params[0];
            var y:NumberTracker = params[1];
            
            var i:int, len:int;
            
            if (x)
                for (i = 0, len = _xScrollList.length; i < len; i++)
                    _xScrollList[i].update(x.rate);
            
            if (y)
                for (i = 0, len = _yScrollList.length; i < len; i++)
                    _yScrollList[i].update(y.rate);
        }
    }
}