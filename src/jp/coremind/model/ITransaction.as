package jp.coremind.model
{
    public interface ITransaction
    {
        function destroy():void;
        function get transaction():Boolean;
        
        function beginTransaction(visualize:Boolean = true):void;
        function updateValue(value:*, key:*):void;
        function rollback(visualize:Boolean = true):void;
        function commit(visualize:Boolean = true):void;
    }
}