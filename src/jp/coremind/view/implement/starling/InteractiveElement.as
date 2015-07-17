package jp.coremind.view.implement.starling
{
    import flash.geom.Point;
    import flash.geom.Rectangle;
    
    import jp.coremind.utility.Log;
    import jp.coremind.utility.MultistageStatus;
    import jp.coremind.utility.Status;
    
    import starling.events.Touch;
    import starling.events.TouchEvent;
    import starling.events.TouchPhase;

    public class InteractiveElement extends Element
    {
        private static const _POINT_LOCAL:Point  = new Point();
        private static const _POINT_GLOBAL:Point = new Point();
        private static const _POINTER_RECT:Rectangle = new Rectangle(0, 0, 1, 1);
        
        public static const GROUP_LOCK:String = "groupLock";
        public static const GROUP_CTRL:String = "groupCtrl";
        
        public static const PRIORITY_LIST:Array = [
            { group: GROUP_LOCK, ignorePriority:false, priority: 100, initialStatus:Status.UNLOCK,   decrementCondition: [Status.UNLOCK] },
            { group: GROUP_CTRL, ignorePriority:true,  priority:   0, initialStatus:Status.ROLL_OUT, decrementCondition: [] },
        ];
        
        protected var
            _status:MultistageStatus;
        
        private var
            _triggerRect:Rectangle,
            _hold:Boolean,
            _hover:Boolean;
        
        public function InteractiveElement(inflateSize:Number = 6, multistageStatusConfig:Array = null)
        {
            super();
            
            _hold = _hover = false;
            
            _triggerRect = new Rectangle();
            
            inflateClickRange(inflateSize);
            
            _status = new MultistageStatus(multistageStatusConfig || PRIORITY_LIST);
            _status.forcedChangeGroup(GROUP_CTRL);
            
            enablePointerDeviceControl();
            enable();
            
            _updateStatus(GROUP_CTRL, Status.UP);
        }
        
        override public function destroy():void
        {
            _status.destroy();
            
            disablePointerDeviceControl();
            
            super.destroy();
        }
        
        /**
         * マウスダウン(タッチダウン)した座標からダウン状態までのサイズを拡張する.
         * (デフォルトは1なのでダウン位置から少しでもずらすとタップ扱いにならなくなる)
         * 良くあるボタン処理ではポインタの座標が表示オブジェクトから外れたらダウン状態が解除されるが、
         * このオブジェクトではこのメソッドで正方形の判定領域を設定しその領域を外れたら解除される。
         */
        public function inflateClickRange(n:Number):void
        {
            _triggerRect.inflate(n, n);
        }
        
        /**
         * このオブジェクトがステータス上でマウスやポインター操作を受け付けるようにする.
         * protectedメソッド(_onXXX系ハンドラ)への呼び出しを行うようになる。
         * このオブジェクトを継承するクラスインスタンスではこのメソッドでインタラクションのon/offを行う。
         */
        public function enable():void
        {
            _updateStatus(GROUP_LOCK, Status.UNLOCK);
        }
        
        /**
         * このオブジェクトがステータス上でマウスやポインター操作を受け付けるようにしない.
         * このメソッドを呼び出すとフレームワークからのタッチイベントは受け取るもののその後処理するprotectedメソッド(_onXXX系ハンドラ)への呼び出しは行わなくなる。
         * このオブジェクトを継承するクラスインスタンスではこのメソッドでインタラクションのon/offを行う。
         */
        public function disable():void
        {
            _updateStatus(GROUP_LOCK, Status.LOCK);
        }
        
        /**
         * このオブジェクトがステータス上、マウスやポインター操作を受け付けるかを示す値を返す.
         * touchableの値をリンクしているわけでは無いことを留意。
         * このオブジェクトではtouchableがtrueだとしてもprotectedメソッド(_onXXX系ハンドラ)への呼び出しは発生しない。
         * 有効・無効を切り替えるにはenableメソッド、disableメソッドを利用する。
         */
        public function isEnable():Boolean
        {
            return _status.equalGroup(GROUP_CTRL);
        }
        
        /**
         * フレームワークから発生するタッチイベントを適切なステータスへ変換する.
         */
        protected function _onTouch(e:TouchEvent):void
        {
            var t:Touch = e.getTouch(this);
            if (!t)
            {
                if (_hover)
                    _updateStatus(GROUP_CTRL, Status.ROLL_OUT, _onRollOut, t);
                
                _hover = false;
                return;
            }
            
            if (t.phase  === TouchPhase.HOVER && !_hover)
            {
                _hover = true;
               _updateStatus(GROUP_CTRL, Status.ROLL_OVER, _onRollOver, t);
            }
            else
            if (t.phase === TouchPhase.MOVED)
            {
                _POINTER_RECT.x = t.globalX;
                _POINTER_RECT.y = t.globalY;
                _hold = _triggerRect.intersects(_POINTER_RECT);
                _hold ?
                    _updateStatus(GROUP_CTRL, Status.MOVE,      _onMove,     t):
                    _updateStatus(GROUP_CTRL, Status.ROLL_OVER, _onRollOver, t);
            }
            else
            if (t.phase  === TouchPhase.BEGAN)
            {
                _triggerRect.x = t.globalX - (_triggerRect.width  >> 1);
                _triggerRect.y = t.globalY - (_triggerRect.height >> 1);
                _hold = true;
                _updateStatus(GROUP_CTRL, Status.DOWN, _onDown, t);
            }
            else
            if (t.phase === TouchPhase.ENDED)
            {
                _POINTER_RECT.x = t.globalX;
                _POINTER_RECT.y = t.globalY;
                _hold ?
                    _updateStatus(GROUP_CTRL, Status.CLICK, _onClick, t):
                    _intersects() ?
                        _updateStatus(GROUP_CTRL, Status.UP,       _onUp,      t):
                        _updateStatus(GROUP_CTRL, Status.ROLL_OUT, _onRollOut, t);
            }
        }
        
        /**
         * このオブジェクトの表示位置をグローバル座標で取得し現在のポインター座標がその中に含まれているかを示す値を返す.
         */
        protected function _intersects():Boolean
        {
            localToGlobal(_POINT_LOCAL, _POINT_GLOBAL);
            
            return new Rectangle(_POINT_GLOBAL.x, _POINT_GLOBAL.y, elementWidth, elementHeight)
                .intersects(_POINTER_RECT);
        }
        
        /**
         * 現在のMultistageStatus.group, valueをパラメータstatusGroupをstatusValueへ更新する.
         * この際に直前まで保持していたgroupとvalueいずれか一つでも異なっている場合、_applyStatusメソッドを呼び出す。
         * 例外としてGROUP_CTRLグループのStatus.MOVEステータスのみ常に_applyStatusを呼び出す。
         * ステータスの更新によって暗黙的にステータスグループに変更があった際に、そのハンドリングを正しく呼び出すためのメソッド。
         */
        protected function _updateStatus(statusGroup:String, statusValue:String, callback:Function = null, t:Touch = null):void
        {
            if (!statusValue) return;
            
            var _beforeGroup:String  = _status.group;
            var _beforeStatus:String = _status.value;
            _status.update(statusGroup, statusValue);
            
            var doReloadStatus:Boolean = !_status.equalGroup(_beforeGroup) || !_status.equal(_beforeStatus);
            if (doReloadStatus
            || !doReloadStatus && _status.equalGroup(GROUP_CTRL) && _status.equal(Status.MOVE))
                callback is Function ? callback(t): _applyStatus(t);
            else
            if (statusValue　=== Status.CLICK)//CLICKは暗黙的に常に呼び出す
                _onStealthClick(t);
        }
        
        /**
         * 現在のMultistageStatusオブジェクトが示すステータス値にしたがって対応したコールバックを呼び出す.
         */
        protected function _applyStatus(t:Touch = null):void
        {
            if (_status.equalGroup(GROUP_CTRL))
            {
                switch(_status.value)
                {
                    case Status.ROLL_OVER: _onRollOver(t); break;
                    case Status.DOWN     : _onDown(t); break;
                    case Status.MOVE     : _onMove(t); break;
                    case Status.UP       : _onUp(t); break;
                    case Status.CLICK    : _onClick(t); break;
                    case Status.ROLL_OUT : _onRollOut(t); break;
                }
            }
            else
            if (_status.equalGroup(GROUP_LOCK))
            {
                switch(_status.value)
                {
                    case Status.LOCK: _onDisable(); break;
                }
            }
        }
        
        /**
         * statusオブジェクトが以下の状態に変わったときに呼び出されるメソッド.
         * group : GROUP_LOCK
         * value : Status.UNLOCK
         */
        protected function _onEnable():void
        {
            //Log.info("_onEnable");
        }
        
        /**
         * statusオブジェクトが以下の状態に変わったときに呼び出されるメソッド.
         * group : GROUP_LOCK
         * value : Status.LOCK
         */
        protected function _onDisable():void
        {
            //Log.info("_onDisable");
        }
        
        /**
         * statusオブジェクトが以下の状態に変わったときに呼び出されるメソッド.
         * group : GROUP_CTRL
         * value : Status.ROLL_OVER
         */
        protected function _onRollOver(t:Touch):void
        {
            //Log.info("_onRollOver");
        }
        
        /**
         * statusオブジェクトが以下の状態に変わったときに呼び出されるメソッド.
         * group : GROUP_CTRL
         * value : Status.ROLL_OUT
         */
        protected function _onRollOut(t:Touch):void
        {
            //Log.info("_onRollOut");
        }
        
        /**
         * statusオブジェクトが以下の状態に変わったときに呼び出されるメソッド.
         * group : GROUP_CTRL
         * value : Status.ROLL_MOVE
         */
        protected function _onMove(t:Touch):void
        {
            //Log.info("_onMove");
        }
        
        /**
         * statusオブジェクトが以下の状態に変わったときに呼び出されるメソッド.
         * group : GROUP_CTRL
         * value : Status.DOWN
         */
        protected function _onDown(t:Touch):void
        {
            //Log.info("_onDown");
        }
        
        /**
         * statusオブジェクトが以下の状態に変わったときに呼び出されるメソッド.
         * group : GROUP_CTRL
         * value : Status.UP
         */
        protected function _onUp(t:Touch):void
        {
            //Log.info("_onUp");
        }
        
        /**
         * statusオブジェクトが以下の状態に変わったときに呼び出されるメソッド.
         * group : GROUP_CTRL
         * value : Status.CLICK
         */
        protected function _onClick(t:Touch):void
        {
            //Log.info("_onClick");
        }
        
        /**
         * statusオブジェクトが以下の状態に変わったときに呼び出されるメソッド.
         * group : 任意
         * value : Status.CLICK
         */
        protected function _onStealthClick(t:Touch):void
        {
            //Log.info("_onStealthClick");
        }
        
        /**
         * マウスやタップイベントのリスニングを有効にする.
         */
        override public function enablePointerDeviceControl():void
        {
            useHandCursor = touchable = true;
            addEventListener(TouchEvent.TOUCH, _onTouch);
        }
        
        /**
         * マウスやタップイベントのリスニングを無効にする.
         */
        override public function disablePointerDeviceControl():void
        {
            useHandCursor = touchable = false;
            removeEventListener(TouchEvent.TOUCH, _onTouch);
        }
    }
}