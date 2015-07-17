package jp.coremind.view.layout
{
    import flash.geom.Point;

    public class LiquidLayout
    {
        private var
            _layout:Array,
            _length:int,
            _margin:int,
            _point:Point;
            
        public function LiquidLayout(margin:int = 0, point:Point = null)
        {
            _length = 0;
            _layout = [];
            _margin = margin < 0 ? 0: margin;
            _point = point;
        }
        
        public function get visibleNumChildren():int
        {
            return 0;
        }
        
        public function updateVisibleNumChildren(elementWidth:Number, elementHeight:Number, clipW:Number, clipH:Number):void
        {
        }
        
        public function pushLine(column:Array):LiquidLayout
        {
            var total:Number = 0;
            var perList:Array = [];
            
            for (var i:int = 0; i < column.length; i++) 
                total += int(column[i]);
            
            for (var j:int = 0; j < column.length; j++) 
                perList[i] = Math.round(column[i] / total);
            
            _length += perList.length;
            _layout.push(column);
            
            return this;
        }
        
        public function spliceLine(columnIndex:int):LiquidLayout
        {
            if (0 <= columnIndex && columnIndex < _layout.length)
            {
                var splicedColumn:Array = _layout.splice(columnIndex, 1)[0];
                _length -= splicedColumn.length;
            }
            
            return this;
        }
        
        private function _getColumn(columnIndex:int):Array
        {
            return 0 <= columnIndex && columnIndex < _layout.length ? _layout[columnIndex]: null;
        }
        
        public function calcPosition(width:Number, height:Number, index:int, length:int = 0):Point
        {
            var cIndex:int = 0;
            var per:Number = 0;
            var n:int = 0;
            var column:Array = _getColumn(0);
            
            while (true)
            {
                if (n <= index && index < column.length)
                {
                    n = column.length - index;
                    break;
                }
                else
                {
                    column = _getColumn(cIndex++);
                    n     += column.length;
                }
            }
            
            var p:Point = _point || new Point();
            return p;
        }
    }
}