package jp.coremind.view.implement.flash
{
    import jp.coremind.view.abstract.INavigationView;
    
    public class NavigationView extends View implements INavigationView
    {
        public function NavigationView()
        {
            super();
        }
        
        override protected function get viewName():String
        {
            return "Navigation";
        }
        
        public function refresh(viewName:String):void
        {
        }
    }
}