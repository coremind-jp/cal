package jp.coremind.model
{
    public interface ITransactionLogParser
    {
        function updated(editableOrigin:*, order:Vector.<int>, diff:Diff):void;
        function added(editableOrigin:*, order:Vector.<int>, diff:Diff):void;
        function removed(editableOrigin:*, order:Vector.<int>, diff:Diff):void;
        function filtered(editableOrigin:*, order:Vector.<int>, diff:Diff):void;
    }
}