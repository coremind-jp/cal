package jp.coremind.view.abstract.component
{
    import jp.coremind.view.abstract.IBox;
    
    /**
     * Accordionクラスの可変長方向をX軸基準で実装したクラス.
     */
    public class AccordionX extends Accordion
    {
        public function AccordionX()
        {
            super();
        }
        
        override protected function _updateBox(child:IBox, childSize:Number, childPosition:Number):void
        {
            child.x = childPosition;
            child.width = childSize;
        }
    }
}