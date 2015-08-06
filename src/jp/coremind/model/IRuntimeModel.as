package jp.coremind.model
{
    public interface IRuntimeModel
    {
        function destroy():void;
        function update(...params):void;
        function addListener(listener:Function):void;
        function removeListener(listener:Function):void;
    }
}