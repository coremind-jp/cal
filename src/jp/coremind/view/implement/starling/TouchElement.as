package jp.coremind.view.implement.starling
{
    import flash.geom.Point;
    import flash.geom.Rectangle;
    
    import jp.coremind.configure.StatusConfigure;
    import jp.coremind.configure.UpdateRule;
    import jp.coremind.utility.MultistageStatus;
    import jp.coremind.utility.Status;

    public class TouchElement extends InteractiveElement
    {
        protected static const _POINT_LOCAL:Point  = new Point();
        protected static const _POINT_GLOBAL:Point = new Point();
        protected static const _POINTER_RECT:Rectangle = new Rectangle(0, 0, 1, 1);
        
        public static const GROUP_PRESS:String = "groupPress";
        public static const GROUP_RELEASE:String = "groupRelease";
        public static const CONFIG_LIST:Array = MultistageStatus.margePriorityList(
            InteractiveElement.CONFIG_LIST,
            new StatusConfigure(GROUP_PRESS,   UpdateRule.ALWAYS, 25, Status.UP, false, [Status.CLICK, Status.UP]),
            new StatusConfigure(GROUP_RELEASE, UpdateRule.LESS_THAN_PRIORITY, 0, Status.UP, true)
        );
        
        protected var
            _triggerRect:Rectangle,
            _hold:Boolean;
            
        public function TouchElement(inflateSize:Number = 6, multistageStatusConfig:Array = null)
        {
            super(multistageStatusConfig || CONFIG_LIST);
            
            _triggerRect = new Rectangle();
            inflateClickRange(inflateSize, inflateSize);
            
            _hold = false;
        }
        
        override protected function _initializeStatus():void
        {
            super._initializeStatus();
            
            _updateStatus(GROUP_PRESS, Status.UP);
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
            _updateStatus(GROUP_PRESS, Status.DOWN);
        }
        
        override protected function moved():void
        {
            _POINTER_RECT.x = _touch.globalX;
            _POINTER_RECT.y = _touch.globalY;
            
            var bIntersects:Boolean = _triggerRect.intersects(_POINTER_RECT);
            var bHitTest:Boolean = hitTest(_touch.getLocation(this), true);
            
            _hold = bIntersects && bHitTest;
            _hold ?
                _updateStatus(GROUP_PRESS, Status.DOWN):
                _updateStatus(GROUP_PRESS, Status.UP);
        }
        
        override protected function ended():void
        {
            if (_hold) _updateStatus(GROUP_PRESS, Status.CLICK);
        }
        
        override protected function _updateStatus(statusGroup:String, statusValue:String):Boolean
        {
            var doApplyStatus:Boolean = super._updateStatus(statusGroup, statusValue);
            
            if (!doApplyStatus && statusValue　=== Status.CLICK)
                _onStealthClick();
            
            return doApplyStatus;
        }
        
        override protected function _applyStatus(group:String, status:String):Boolean
        {
            switch (group)
            {
                case GROUP_RELEASE:
                    switch(status)
                    {
                        case Status.UP: _onUp(); return true;
                    }
                    break;
                
                case GROUP_PRESS:
                    switch(status)
                    {
                        case Status.DOWN : _onDown(); return true;
                        case Status.UP   : _onUp(); return true;
                        case Status.CLICK: _onClick(); return true;
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
            //Log.info("_onClick");
        }
        
        /**
         * statusオブジェクトが以下の状態に変わったときに呼び出されるメソッド.
         * group : 任意
         * value : Status.CLICK
         */
        protected function _onStealthClick():void
        {
            //Log.info("_onStealthClick");
        }
    }
}