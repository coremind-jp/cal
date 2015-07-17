package jp.coremind.view.implement.starling.component
{
    import jp.coremind.view.implement.starling.InteractiveElement;
    
    import starling.display.Quad;
    import starling.events.Event;
    import starling.events.Touch;
    import starling.text.TextField;
    
    public class Button extends InteractiveElement
    {
        protected var
            _quad:Quad,
            _tf:TextField;
        
        public function Button(tapRange:Number=5, multistageStatusConfig:Array = null)
        {
            _quad = new Quad(100, 100, 0xffffff);
            _tf   = new TextField(100, 100, "init");
            
            super(tapRange, multistageStatusConfig);
            
            addChild(_quad);
            addChild(_tf);
        }
        
        override protected function _onEnable():void
        {
            _tf.text = ">>enabled";
            _quad.color = 0x0000ff;
        }
        
        override protected function _onDisable():void
        {
            _tf.text = ">>disabled";
            _quad.color = 0x808080;
        }
        
        override protected function _onDown(t:Touch):void
        {
            _tf.text = ">>down";
            _quad.color = 0x00ff00;
        }
        
        override protected function _onMove(t:Touch):void
        {
            _tf.text = ">>move";
            _quad.color = 0xff00ff;
        }
        
        override protected function _onRollOut(t:Touch):void
        {
            _tf.text = ">>out";
            _quad.color = 0x0000ff;
        }
        
        override protected function _onRollOver(t:Touch):void
        {
            _tf.text = ">>over";
            _quad.color = 0xff0000;
        }
        
        override protected function _onUp(t:Touch):void
        {
            _tf.text = ">>up";
            _quad.color = 0x0000ff;
        }
        
        override protected function _onClick(t:Touch):void
        {
            _tf.text = ">>click";
            _quad.color = 0xff0000;
            dispatchEventWith(Event.CHANGE);
        }
    }
}