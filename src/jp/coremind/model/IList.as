package jp.coremind.model
{
    public interface IList
    {
        function get originRef():Array;
        function get originClone():Array;
        function rollback(diff:Diff):void
        function preview(diff:Diff):void;
        function commit(diff:Diff):void;
    }
}