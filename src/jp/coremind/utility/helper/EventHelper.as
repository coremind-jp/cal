package jp.coremind.utility.helper
{
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	
	import jp.coremind.utility.Log;

	public class EventHelper
	{
        private static const TAG:String = "[EventHelper]";
        //Log.addCustomTag(TAG);
        
		/**
		 * 複数のリスナーを一度に追加します.
		 * このメソッドによって追加されたリスナーは追加したリスナーのいずれかがイベントをキャッチした時点で全て無効化されます。
		 * @param	target	送出対象オブジェクト
		 * @param	types	監視するイベントの配列
		 * @param	funcs	typesと対になるリスナー関数配列
		 */
		public function anyone(
			target:IEventDispatcher,
			types:Array,
			funcs:Array):void
		{
            var _removeEventListener:Function = function():void
            {
                Log.custom(TAG, "- anyone", target, types);
                for (var i:int = 0; i < types.length; i++) 
                    target.removeEventListener(types[i], funcs[i]);
            };
            
            for (var i:int = 0; i < funcs.length; i++) 
            {
                Log.custom(TAG, "+ anyone ", target, types);
                
                var func:Function = funcs[i];
                target.addEventListener(types[i], funcs[i] = function(e:Event):void
                {
                    _removeEventListener();
                    func(e);
                });
            }
		}
        
		public function createSamelistenerArray(listener:Function, num:int = 0):Array
		{
			var _result:Array = [];
			while (num > 0) _result[--num] = listener;
			return _result;
		}
	}
}