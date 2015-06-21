package jp.coremind.resource
{
    import flash.utils.ByteArray;

    public interface IByteArrayContent
    {
        function get fileExtention():String;
        function extract(f:Function, binary:ByteArray):void;
        function clone(source:*):*;
        function createFailedContent():*;
    }
}