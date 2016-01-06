package jp.coremind.model.module
{
    import flash.geom.Point;
    import flash.geom.Rectangle;
    
    import jp.coremind.core.Application;
    import jp.coremind.model.IElementModel;
    import jp.coremind.utility.Dispatcher;
    import jp.coremind.utility.Log;
    import jp.coremind.utility.data.NumberTracker;
    import jp.coremind.view.abstract.IContainer;
    import jp.coremind.view.interaction.Flick;
    
    public class ScrollModule extends Dispatcher implements IElementModel
    {
        //再利用インスタンス
        private static const _ZERO:Point = new Point();
        private static const _POINT:Point = new Point();
        private static const _OFFSET:Rectangle = new Rectangle();
        
        private var
            _container:IContainer,
            _before:Before,
            _scrollVolume:Point,
            _drugSize:Point,
            _flickArea:Rectangle,
            _flick:Flick;
        
        public function ScrollModule(container:IContainer)
        {
            _container    = container;
            _before       = new Before();
            _scrollVolume = new Point();
            _drugSize     = new Point();
            _flickArea    = new Rectangle();
            _flick        = new Flick();
        }
        
        override public function destroy():void
        {
            _container = null;
            _before = null;
            _drugSize = _scrollVolume = null;
            _flickArea = null;
            _flick.destory();
            _flick = null;
            
            super.destroy();
        }
        
        public function update(...params):void {}
        
        public function refreshContentSize():void
        {
            var resultX:Number = _container.x;
            var resultY:Number = _container.y;
            var delta:Number = 0;
            
            var w:Number = _container.x + _container.elementWidth;
            if (w < _container.maxWidth)
            {
                delta = _container.maxWidth - w;
                _drugSize.x += delta;
                resultX     += delta;
                
                if (0 < resultX)     resultX = 0;
                if (0 < _drugSize.x) _drugSize.x  = 0;
            }
            
            var h:Number  = _container.y + _container.elementHeight;
            if (h <= _container.maxHeight)
            {
                delta = _container.maxHeight - h;
                _drugSize.y += delta;
                resultY     += delta;
                
                if (0 < resultY)     resultY = 0;
                if (0 < _drugSize.y) _drugSize.y  = 0;
            }
            
            if (_container.x != resultX || _container.y != resultY)
                _container.updatePosition(resultX, resultY);
        }
        
        public function setScrollVolume(x:Number, y:Number):void
        {
            _scrollVolume.setTo(x, y);
        }
        
        public function createTracker(callback:Function):void
        {
            _initializePosition();
            _flick.createTracker(_OFFSET, _flickArea, callback);
        }
        
        public function beginPointerDeviceListening():void
        {
            _initializePosition();
            _setInitialPosition();
            
            _flick.fromPointerDevice = true;
            _flick.initialize(_OFFSET, _flickArea, _onFlickUpdate);
            _flick.beginPointerDeviceListening();
        }
        
        private function _initializePosition():void
        {
            _container.toLocalPoint(Application.pointer, _POINT);
            _OFFSET.setTo(_POINT.x, _POINT.y, _container.maxWidth, _container.maxHeight);
            _updateFlickArea();
        }
        
        private function _updateFlickArea():void
        {
            _container.toGlobalPoint(_ZERO, _POINT);
            
            _flickArea.setTo(
                _POINT.x - (_container.elementWidth  - _container.maxWidth  + _drugSize.x),
                _POINT.y - (_container.elementHeight - _container.maxHeight + _drugSize.y),
                _container.elementWidth,
                _container.elementHeight);
            
            _flickArea.x |= 0;
            _flickArea.y |= 0;
        }
        
        private function _setInitialPosition():void
        {
            _before.containerPosition.setTo(_container.x, _container.y);
            _before.flickAreaPosition.setTo(_flickArea.x, _flickArea.y);
            _before.drugSize.setTo(_drugSize.x, _drugSize.y);
        }
        
        private function _onFlickUpdate(x:NumberTracker, y:NumberTracker):void
        {
            var resultX:Number = _container.x;
            var trackerX:NumberTracker = null;
            if (_container.maxWidth < _container.elementWidth)
            {
                resultX      = _before.containerPosition.x + x.totalDelta;
                _drugSize.x  = _before.drugSize.x          + x.totalDelta;
                _flickArea.x = _before.flickAreaPosition.x - x.totalDelta;
                trackerX = x;
            }
            
            var resultY:Number = _container.y;
            var trackerY:NumberTracker = null;
            if (_container.maxHeight < _container.elementHeight)
            {
                resultY      = _before.containerPosition.y + y.totalDelta;
                _drugSize.y  = _before.drugSize.y          + y.totalDelta;
                _flickArea.y = _before.flickAreaPosition.y - y.totalDelta;
                trackerY = y;
            }
            
            _container.updatePosition(resultX, resultY);
            dispatch(trackerX, trackerY);
        }
        
        public function toHead(x:Boolean = true, y:Boolean = true):void
        {
            _moveTo(x ? int.MAX_VALUE: 0, y ? int.MAX_VALUE: 0);
        }
        
        public function toTail(x:Boolean = true, y:Boolean = true):void
        {
            _moveTo(x ? -int.MAX_VALUE: 0, y ? -int.MAX_VALUE: 0);
        }
        
        public function pixelTo(x:Number, y:Number):void
        {
            _moveTo(x, y);
        }
        
        public function gridTo(x:int, y:int):void
        {
            _moveTo(x * _scrollVolume.x, y * _scrollVolume.y);
        }
        
        private function _moveTo(x:Number, y:Number):void
        {
            _initializePosition();
            _setInitialPosition();
            
            _flick.fromPointerDevice = false;
            _flick.initialize(_OFFSET, _flickArea, _onFlickUpdate);
            _flick.moveTo(x, y);
            _flick.drop();
        }
    }
}

import flash.geom.Point;

class Before
{
    public var
    flickAreaPosition:Point,
    containerPosition:Point,
    drugSize:Point;
    
    public function Before()
    {
        flickAreaPosition = new Point();
        containerPosition = new Point();
        drugSize = new Point();
    }
}