package jp.coremind.view.layout
{
    import flash.geom.Point;
    import flash.geom.Rectangle;
    
    import jp.coremind.storage.transaction.Diff;
    import jp.coremind.storage.IModelStorageListener;
    import jp.coremind.storage.ModelReader;
    import jp.coremind.utility.Log;
    import jp.coremind.utility.process.Routine;
    import jp.coremind.view.abstract.IElement;
    import jp.coremind.view.builder.GridListElementFactory;
    
    public class GridLayout implements IListLayout, IModelStorageListener
    {
        private var
            _reader:ModelReader,
            _searchIndexList:Vector.<int>,
            _positionList:Vector.<int>,
            _headGridRect:Rectangle,
            
            _stack:int,
            _scrollDirection:String,
            
            _elementfactory:GridListElementFactory, 
            _rect:Rectangle,
            _horizontal:Calculator,
            _vertical:Calculator;
        
        /**
         * グリッド単位で表示オブジェクトをレイアウトするためのクラス.
         * @param   elementFactory  このレイアウトにおけるListElementFactory定義
         * @param   grid            このレイアウトにおけるGrid定義
         * @param   scrollDirection スクロール方向となる軸(Direction定数クラスで指定)
         * @param   stack           スクロール方向ではない軸の最大Grid数
         * @param   horizontalGap   水平グリッド間隔
         * @param   verticalGap     垂直グリッド間隔
         * @param   temporaryRect   座標やサイズを計算する際に再帰的に利用するRectangleオブジェクト(指定しない場合は各メソッドを呼ぶ度に都度生成される)
         * @param   horizontalLetterbox 水平方向のレターボックスサイズ
         * @param   verticalLetterbox   垂直方向のレターボックスサイズ
         */
        public function GridLayout(
            elementfactory:GridListElementFactory,
            scrollDirection:String = Direction.Y,
            stack:int = 1,
            temporaryRect:Rectangle = null)
        {
            _searchIndexList = new <int>[];
            _positionList   = new <int>[];
            _headGridRect   = new Rectangle();
            
            _elementfactory = elementfactory;
            
            _scrollDirection = scrollDirection;
            _stack = stack < 1 ? 1: stack;
            _rect  = temporaryRect;
        }
        
    //configure side
        public function horizontalLayout(letterbox:Size, grid:Size, gap:Size):GridLayout
        {
            _horizontal = new Calculator(letterbox, grid, gap);
            return this;
        }
        public function verticalLayout(letterbox:Size, grid:Size, gap:Size):GridLayout
        {
            _vertical = new Calculator(letterbox, grid, gap);
            return this;
        }
    //configure side
        
    //Alias Element Factory
        public function hasCache(modelData:*):Boolean { return _elementfactory.hasElement(modelData); }
        public function requestRecycle(modelData:*):void { _elementfactory.recycle(modelData); }
        public function refreshCacheKey():void { _elementfactory.refreshKey(); }
        public function requestElement(actualParentWidth:int, actualParentHeight:int, modelData:*, index:int = -1, length:int = -1):IElement { return _elementfactory.request(actualParentWidth, actualParentHeight, modelData, index, length); }
        public function createElement(actualParentWidth:int, actualParentHeight:int, modelData:*, index:int):IElement { return _elementfactory.create(actualParentWidth, actualParentHeight, modelData, index); }
    //Alias Element Factory
        
    //runtime side
        public function getScrollSizeX(actualParentWidth:Number):Number
        {
            return _horizontal.calcScrollSize(actualParentWidth);
        }
        
        public function getScrollSizeY(actualParentHeight:Number):Number
        {
            return _vertical.calcScrollSize(actualParentHeight);
        }
        
        public function calcElementRect(actualParentWidth:int, actualParentHeight:int, index:int, length:int = 0):Rectangle
        {
            var i:int = index << 1;
            var r:Rectangle = _rect || new Rectangle();
            
            r.setTo(-5000, -5000, 0, 0);
            if (0 <= i && i < _positionList.length)
            {
                _horizontal.calcElementLayout(actualParentWidth,  "x", _positionList[i]  , "width",  _elementfactory.densityList[i],   r);
                  _vertical.calcElementLayout(actualParentHeight, "y", _positionList[i+1], "height", _elementfactory.densityList[i+1], r);
            }
            //Log.info("calcElementRect", r);
            
            return r;
        }
        
        public function calcTotalRect(actualParentWidth:int, actualParentHeight:int, length:int = 0):Rectangle
        {
            var r:Rectangle = _rect || new Rectangle();
            
            length = length < _stack ? length: _stack;
            
            r.setEmpty();
            if (_scrollDirection == Direction.X)
            {
                _horizontal.calcContainerSize(actualParentWidth,  _calcMaxVariableGrid(), "x",  "width", r);
                  _vertical.calcContainerSize(actualParentHeight,                 length, "y", "height", r);
            }
            else
            {
                _horizontal.calcContainerSize(actualParentWidth,                   length, "x",  "width", r);
                  _vertical.calcContainerSize(actualParentHeight,  _calcMaxVariableGrid(), "y", "height", r);
            }
            //Log.info("calcTotalRect", r);
            
            return r;
        }
        
        public function initialize(reader:ModelReader):void
        {
            _reader = reader;
            _reader.addListener(this, ModelReader.LISTENER_PRIORITY_GRID_LAYOUT);
            
            _elementfactory.initialize(reader);
            
            _update();
        }
        
        public function destroy(withReference:Boolean = false):void
        {
            Log.info("GridLayout destroy", withReference);
            
            _reader.removeListener(this);
            _reader = null;
            
            _searchIndexList.length = 0;
            _positionList.length = 0;
            
            _rect = null;
            
            if (withReference)
                _elementfactory.destroy();
            
            _elementfactory = null;
        }
        
        public function preview(plainDiff:Diff):void
        {
            _update();
        }
        
        public function commit(plainDiff:Diff):void {}
        
        /** 現在のdencityListに基づいてレイアウトを更新する. */
        private function _update():void
        {
            var key:DirectionKey   = new DirectionKey(_scrollDirection);
            var tempRect:Rectangle = new Rectangle();
            var tempPoint:Point    = new Point();
            var flag:Boolean = false;
            
            _headGridRect.setEmpty();
            _positionList.length = 0;
            _searchIndexList.length = 0;
            
            for (var i:int, len:int = _elementfactory.densityList.length >> 1; i < len; i++)
            {
                var j:int = i << 1;
                
                //1, 1のグリッドで次の配置可能な位置を探す
                _headGridRect.width = _headGridRect.height = 1;
                _searchHeadGrid(tempRect, key, _headGridRect);
                
                //その位置を保持
                tempPoint.x = _headGridRect.x;
                tempPoint.y = _headGridRect.y;
                //Log.info(">>keep unit empty grid=", tempPoint);
                
                //その位置で配置予定のグリッドサイズに変える
                _headGridRect.width  = _elementfactory.densityList[j];
                _headGridRect.height = _elementfactory.densityList[j+1];
                
                //配置予定のグリッドがコンテナの固定長軸の最大グリッド数を越えていないかを調べる
                if (key.isTranscendFixedGridBySize(_headGridRect, _stack))
                {
                    Log.error("invalid grid size. (large relative to stack)", _headGridRect, _stack);
                    return;
                }
                
                //Log.info(">------[", i, "] size=", _headGridRect.width, _headGridRect.height);
                //ここで配置位置が一応決まる
                _searchHeadGrid(tempRect, key, _headGridRect);
                
                //_searchHeadGridでは配置位置グリッド+サイズグリッドがコンテナの固定長軸の最大グリッドを超えているかを判定できない為、それを確認する
                while (key.isTranscendFixedGridByTailPosition(_headGridRect, _stack))
                {
                    //超えている場合は可変長軸側に配置位置をずらす
                    key.lineBreakHeadGrid(_headGridRect);
                    //Log.info("transcend! line breaked =>", _headGridRect.x, _headGridRect.y);
                    //改めて配置位置を確認
                    _searchHeadGrid(tempRect, key, _headGridRect);
                }
                //ここで最終的名配置位置が確定
                _positionList[j]   = _headGridRect.x;
                _positionList[j+1] = _headGridRect.y;
                
                //Log.info("rollback first empty grid=", tempPoint);
                //次回走査する際の開始位置は1, 1の空きグリッドが見つかった場所にしなければならないので最初に保持した座標を走査ヘッドにする
                _headGridRect.x = tempPoint.x;
                _headGridRect.y = tempPoint.y;
                
                //Log.info("<------[", i, "]", _positionList[j], _positionList[j+1]);
                _searchIndexList[_searchIndexList.length] = j;
                _refreshSearchList(key, _headGridRect);
            }
        }
        
        /** 配置可能なグリッド座標を探し出す. */
        private function _searchHeadGrid(addedElementRect:Rectangle, key:DirectionKey, newElementRect:Rectangle):void
        {
            //Log.info("searchHeadGrid try", _headGridRect.x, _headGridRect.y);
            for (var i:int = _searchIndexList.length - 1; 0 <= i; i--) 
            {
                var j:int = _searchIndexList[i];
                var x:int = _positionList[j];
                var y:int = _positionList[j+1];
                var w:int = _elementfactory.densityList[j];
                var h:int = _elementfactory.densityList[j+1];
                addedElementRect.setTo(x, y, w, h);
                
                //Log.info("eval[", i, "]", addedElementRect);
                if (addedElementRect.intersects(newElementRect))
                {
                    key.incrementHeadGrid(newElementRect, _stack);
                    //Log.info("intersects! do increment");
                    
                    _searchHeadGrid(addedElementRect, key, newElementRect);
                    break;
                }
            }
        }
        
        /** 走査対象を更新する. */
        private function _refreshSearchList(key:DirectionKey, headGrid:Rectangle):void
        {
            //Log.info("refreshSearchList");
            var headPosition:Number = headGrid[key.variableHeadPosition];
            var n:int = key.variableIndexOffset;
            
            for (var i:int = 0, len:int = _searchIndexList.length; i < len; i++) 
            {
                var j:int = _searchIndexList[i];
                var p:int = _positionList[j+n];
                var s:int = _elementfactory.densityList[j+n];
                
                //Log.info("index", j >> 1, p + s, "<", headPosition);
                if (p + s <= headPosition)
                {
                    //Log.info("_refreshSearchList splice", i);
                    //可変長軸上で配置ヘッド走査対象を越えた場合、以降走査する必要は無いので対象から外す
                    _searchIndexList.splice(i, 1); len--; i--;
                }
            }
        }
        
        /** 可変長軸の最大グリッドを計算する. */
        private function _calcMaxVariableGrid():int
        {
            var indexOffset:int = _scrollDirection === Direction.X ? 0: 1;
            var result:int = 0;
            
            for (var i:int = 0, len:int = _searchIndexList.length; i < len; i++) 
            {
                var j:int = _searchIndexList[i];
                var n:int = _positionList[j+indexOffset] + _elementfactory.densityList[j+indexOffset];
                if (result < n) result = n;
            }
            
            return result;
        }
        
        public function getTweenRoutineByAddedStage(modelData:*):Function
        {
            return Routine.SKIP;
        }
        
        public function getTweenRoutineByMoved(modelData:*):Function
        {
            return Routine.SKIP;
        }
        
        public function getTweenRoutineByRemovedStage(modelData:*):Function
        {
            return Routine.SKIP;
        }
    }
}
import flash.geom.Rectangle;

import jp.coremind.view.layout.Direction;
import jp.coremind.view.layout.Size;

class Calculator
{
    private var
        _letterbox:Size,
        _grid:Size,
        _gap:Size;
    
    public function Calculator(letterbox:Size, grid:Size, gap:Size)
    {
        _letterbox = letterbox;
        _grid = grid;
        _gap  = gap;
    }
    
    public function calcElementLayout(actualBoxSize:int, position:String, positionDensity:int, size:String, sizeDensity:int, rect:Rectangle):void
    {
        var letterbox:Number = _letterbox.calc(actualBoxSize);
        var grid:Number      = _grid.calc(actualBoxSize);
        var gap:Number       = _gap.calc(actualBoxSize);
        var grid_gap:Number  = grid + gap;
        
        rect[position] = letterbox + grid_gap * positionDensity;
        rect[size]     = grid_gap * sizeDensity - gap;
    }
    
    public function calcScrollSize(actualBoxSize:int):Number
    {
        return _grid.calc(actualBoxSize) + _gap.calc(actualBoxSize);
    }
    
    public function calcContainerSize(actualBoxSize:int, density:int, position:String, size:String, rect:Rectangle):void
    {
        var letterbox:Number = _letterbox.calc(actualBoxSize);
        var grid:Number      = _grid.calc(actualBoxSize);
        var gap:Number       = _gap.calc(actualBoxSize);
        
        rect[position] = 0;
        rect[size] = (letterbox << 1) + (grid + gap) * density - gap;
    }
}
class DirectionKey
{
    public var
        //固定長軸
        fixedHeadPosition:String,       //座標取得キー
        fixedGridSize:String,           //サイズ取得キー
        fixedTailPosition:String,       //座標+サイズ取得キー
        fixedIndexOffset:int,           //配列アクセス時のオフセット量
        
        //可変長軸
        variableHeadPosition:String,    //座標取得キー
        variableGridSize:String,        //サイズ取得キー
        variableTailPosition:String,    //座標+サイズ取得キー
        variableIndexOffset:int;        //配列アクセス時のオフセット量
    
    /**
     * 座標をx, yではなく可変長軸、固定長軸で扱うためのクラス.
     * @param   direction   可変長軸をDirection定数で指定
     */
    public function DirectionKey(direction:String)
    {
        if (direction === Direction.X)
        {
            fixedHeadPosition = "y";
            fixedGridSize     = "height";
            fixedTailPosition = "bottom";
            fixedIndexOffset  = 1;
            
            variableHeadPosition = "x";
            variableGridSize     = "width";
            variableTailPosition = "right";
            variableIndexOffset  = 0;
        }
        else
        {
            fixedHeadPosition = "x";
            fixedGridSize     = "width";
            fixedTailPosition = "right";
            fixedIndexOffset  = 0;
            
            variableHeadPosition = "y";
            variableGridSize     = "height";
            variableTailPosition = "bottom";
            variableIndexOffset  = 1;
        }
    }
    
    /**
     * パラメータheadGridが示す座標をインクリメントする.
     * @param   headGrid    走査ヘッド
     * @param   stack       固定長軸の最大スタック数
     */
    public function incrementHeadGrid(headGrid:Rectangle, stack:int):void
    {
        headGrid[fixedHeadPosition]++;
        
        if (stack <= headGrid[fixedHeadPosition])
            lineBreakHeadGrid(headGrid);
    }
    
    /**
     * パラメータheadGridが示す座標を改行する.
     * @param   headGrid    走査ヘッド
     */
    public function lineBreakHeadGrid(headGrid:Rectangle):void
    {
        headGrid[fixedHeadPosition] = 0;
        headGrid[variableHeadPosition]++;
    }
    
    /**
     * パラメータelementGridのグリッドサイず(位置)が固定長軸の最大グリッド数を超えていないかを示す値を返す.
     * 超えている場合true, それ以外の場合false
     */
    public function isTranscendFixedGridBySize(elementGrid:Rectangle, stack:int):Boolean
    {
        return stack < elementGrid[fixedGridSize];
    }
    
    /**
     * パラメータelementGridのグリッドサイズ(位置+サイズ)が固定長軸の最大グリッド数を超えていないかを示す値を返す.
     * 超えている場合true, それ以外の場合false
     */
    public function isTranscendFixedGridByTailPosition(elementGrid:Rectangle, stack:int):Boolean
    {
        return stack < elementGrid[fixedTailPosition];
    }
}
