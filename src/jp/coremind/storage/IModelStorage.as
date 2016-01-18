package jp.coremind.storage
{
    public interface IModelStorage
    {
        function isDefined(id:String):Boolean;
        function create(id:String, value:*):void;
        function read(id:String):*;
        function update(id:String, value:*):void;
        function de1ete(id:String):void;
        function reset():void;
    }
}