package jp.coremind.view.starling
{
    public class RootView extends View
    {
        private static var INSTANCE:RootView;
        public static function get instance():RootView { return INSTANCE; }
        
        public function RootView()
        {
            if (INSTANCE) throw new Error("RootView is singleton.");
            INSTANCE = this;
        }
    }
}