package jp.coremind.view.abstract
{
    import flash.geom.Point;

    //flash DisplayObject accessor
    public interface IDisplayObject extends IBox
    {
        function set name(s:String):void
        function get name():String
        
        function get alpha():Number;
        function set alpha(n:Number):void;
        
        function set visible(b:Boolean):void;
        function get visible():Boolean;
        
        /**
         * DisplayObject::parentアクセサーのエイリアス
         */
        function get parentDisplay():IDisplayObjectContainer;
        
        /**
         * DisplayObject::globalToLocalメソッドのエイリアス(starling踏襲)
         */
        function toLocalPoint(globalPoint:Point, resultPoint:Point = null):Point;
        
        /**
         * DisplayObject::localToGlobalメソッドのエイリアス(starling踏襲)
         */
        function toGlobalPoint(localPoint:Point, resultPoint:Point = null):Point;
        
        /**
         * ポインターデバイスがこの表示オブジェクトへの入力を有効にする抽象メソッド.
         */
        function enablePointerDeviceControl():void;
        
        /**
         * ポインターデバイスがこの表示オブジェクトへの入力を無効にする抽象メソッド.
         */
        function disablePointerDeviceControl():void;
    }
}