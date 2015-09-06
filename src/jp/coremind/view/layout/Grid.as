package jp.coremind.view.layout
{
    public class Grid
    {
        private var
            _width:int,
            _height:int;
        
        /**
         * GridLayoutで利用されるグリッドあたりのサイズを定義するクラス.
         */
        public function Grid(width:int, height:int)
        {
            _width  = width;
            _height = height;
        }
        
        /** グリッドあたりの横幅pixelを取得する. */
        public function get width():int { return _width; }
        /** グリッドあたりの高さpixelを取得する. */
        public function get height():int { return _height; }
        /** densityパラメータ(グリッド密度)を元に横幅pixelを計算する. */
        public function calcWidth(density:int):Number  { return _width  * density; }
        /** densityパラメータ(グリッド密度)を元に高さpixelを計算する. */
        public function calcHeight(density:int):Number { return _height * density; }
    }
}