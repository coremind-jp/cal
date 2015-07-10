package jp.coremind.utility.helper
{
    public class ArrayHelper
    {
        public function swap(array:Array, index1:int, index2:int):void
        {
            if (array
            && 0 <=index1
            && 0 <=index2
            && index1 < array.length
            && index2 < array.length)
            {
                var temp:* = array[index1];
                array[index1] = array[index2];
                array[index2] = temp;
            }
        }
    }
}