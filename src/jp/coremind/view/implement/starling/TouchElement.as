package jp.coremind.view.implement.starling
{
    import flash.geom.Point;
    import flash.geom.Rectangle;
    
    import jp.coremind.core.Application;
    import jp.coremind.core.StatusModelType;
    import jp.coremind.model.module.StatusGroup;
    import jp.coremind.model.module.StatusModel;
    import jp.coremind.utility.data.Status;
    import jp.coremind.view.builder.IBackgroundBuilder;
    import jp.coremind.view.layout.Layout;

    public class TouchElement extends InteractiveElement
    {
        protected static const _POINT_LOCAL:Point  = new Point();
        protected static const _POINT_GLOBAL:Point = new Point();
        protected static const _POINTER_RECT:Rectangle = new Rectangle(0, 0, 1, 1);
        
        protected var
            _triggerRect:Rectangle,
            _hold:Boolean;
            
        public function TouchElement(layoutCalculator:Layout, backgroundBuilder:IBackgroundBuilder = null)
        {
            super(layoutCalculator, backgroundBuilder);
            
            touchHandling = true;
            
            _triggerRect = new Rectangle();
            inflateClickRange(6, 6);
            
            _hold = false;
        }
        
        override protected function get statusModelType():String
        {
            return StatusModelType.TOUCH_ELEMENT;
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
                            _onUp();
                            Application.router.notify(_elementInfo, group, status);
                            return true;
                            
                        case Status.UP:
                            _onUp();
                            Application.router.notify(_elementInfo, group, status);
                            return true;
                    }
                    break;
                
                case StatusGroup.PRESS:
                    switch(status)
                    {
                        case Status.DOWN:
                            _onDown();
                            Application.router.notify(_elementInfo, group, status);
                            return true;
                            
                        case Status.UP:
                            _onUp();
                            Application.router.notify(_elementInfo, group, status);
                            return true;
                            
                        case Status.CLICK:
                            _onClick();
                            Application.router.notify(_elementInfo, group, status);
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
            //Log.info("_onClick");
        }
    }
}