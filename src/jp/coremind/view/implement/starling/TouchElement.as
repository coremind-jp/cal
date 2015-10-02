package jp.coremind.view.implement.starling
{
    import flash.geom.Point;
    import flash.geom.Rectangle;
    
    import jp.coremind.model.module.StatusConfigure;
    import jp.coremind.model.module.StatusGroup;
    import jp.coremind.model.module.StatusModel;
    import jp.coremind.model.module.StatusModelConfigure;
    import jp.coremind.model.transaction.UpdateRule;
    import jp.coremind.utility.data.Status;
    import jp.coremind.view.builder.IBackgroundBuilder;
    import jp.coremind.view.layout.LayoutCalculator;

    public class TouchElement extends InteractiveElement
    {
        override protected function get _statusModelConfigureKey():Class { return TouchElement }
        
        StatusModelConfigure.registry(
            TouchElement,
            StatusModelConfigure.marge(
                InteractiveElement,
                    new StatusConfigure(StatusGroup.PRESS,   UpdateRule.ALWAYS, 75, Status.UP, false, [Status.CLICK, Status.UP]),
                    new StatusConfigure(StatusGroup.RELEASE, UpdateRule.LESS_THAN_PRIORITY, 25, Status.UP, true)
                ));
        
        protected static const _POINT_LOCAL:Point  = new Point();
        protected static const _POINT_GLOBAL:Point = new Point();
        protected static const _POINTER_RECT:Rectangle = new Rectangle(0, 0, 1, 1);
        
        protected var
            _triggerRect:Rectangle,
            _hold:Boolean;
            
        public function TouchElement(
            layoutCalculator:LayoutCalculator,
            backgroundBuilder:IBackgroundBuilder = null)
        {
            super(layoutCalculator, backgroundBuilder);
            
            touchHandling = true;
            
            _triggerRect = new Rectangle();
            inflateClickRange(6, 6);
            
            _hold = false;
        }
        
        override protected function _initializeStatus():void
        {
            super._initializeStatus();
            
            _elementModel.getModule(StatusModel).update(StatusGroup.RELEASE, Status.ROLL_OUT);
        }
        
        /**
         * マウスダウン(タッチダウン)した座標からダウン状態までのサイズを拡張する.
         * (デフォルトは6なのでダウン位置から少しずらすとタップ扱いにならなくなる仕様)
         * ボタンの表示領域全体をタッチ領域にするにはオブジェクトの横幅、高さの1/2の値を指定する。
         */
        public function inflateClickRange(w:Number, h:Number):void
        {
            _triggerRect.inflate(w, h);
        }
        
        override protected function began():void
        {
            _triggerRect.x = _touch.globalX - (_triggerRect.width  >> 1);
            _triggerRect.y = _touch.globalY - (_triggerRect.height >> 1);
            
            _hold = true;
            _elementModel.getModule(StatusModel).update(StatusGroup.PRESS, Status.DOWN);
        }
        
        override protected function moved():void
        {
            _POINTER_RECT.x = _touch.globalX;
            _POINTER_RECT.y = _touch.globalY;
            
            var bIntersects:Boolean = _triggerRect.intersects(_POINTER_RECT);
            var bHitTest:Boolean = hitTest(_touch.getLocation(this), true);
            
            _hold = bIntersects && bHitTest;
            _hold ?
                _elementModel.getModule(StatusModel).update(StatusGroup.PRESS, Status.DOWN):
                _elementModel.getModule(StatusModel).update(StatusGroup.PRESS, Status.UP);
        }
        
        override protected function ended():void
        {
            if (_hold)
                _elementModel.getModule(StatusModel).update(StatusGroup.PRESS, Status.CLICK);
        }
        
        override protected function _applyStatus(group:String, status:String):Boolean
        {
            switch (group)
            {
                case StatusGroup.RELEASE:
                    switch(status)
                    {
                        case Status.ROLL_OUT:
                        case Status.UP: _onUp(); return true;
                    }
                    break;
                
                case StatusGroup.PRESS:
                    switch(status)
                    {
                        case Status.DOWN : _onDown(); return true;
                        case Status.UP   : _onUp(); return true;
                        case Status.CLICK: _onClick();
                            return true;
                    }
                    break;
            }
            
            return super._applyStatus(group, status);
        }
        
        /**
         * statusオブジェクトが以下の状態に変わったときに呼び出されるメソッド.
         * group : GROUP_CTRL
         * value : Status.DOWN
         */
        protected function _onDown():void
        {
            //Log.info("_onDown");
        }
        
        /**
         * statusオブジェクトが以下の状態に変わったときに呼び出されるメソッド.
         * group : GROUP_CTRL
         * value : Status.UP
         */
        protected function _onUp():void
        {
            //Log.info("_onUp");
        }
        
        /**
         * statusオブジェクトが以下の状態に変わったときに呼び出されるメソッド.
         * group : GROUP_CTRL
         * value : Status.CLICK
         */
        protected function _onClick():void
        {
            controller.doClickHandler("clickHandler", _elementId);
            //Log.info("_onClick");
        }
    }
}