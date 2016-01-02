package jp.coremind.view.abstract
{
    import jp.coremind.core.Controller;
    import jp.coremind.utility.process.Routine;
    import jp.coremind.utility.process.Thread;

    public interface IView extends ICalSprite 
    {
        function getElement(path:String):IElement;
        
        function isFocus():Boolean;
        
        function initializeProcess(r:Routine, t:Thread):void;
        
        function focusInPreProcess(r:Routine, t:Thread):void;
        function focusInPostProcess(r:Routine, t:Thread):void;
        
        function focusOutPreProcess(r:Routine, t:Thread):void;
        function focusOutPostProcess(r:Routine, t:Thread):void;
        
        function destroyProcess(r:Routine, t:Thread):void;
    }
}