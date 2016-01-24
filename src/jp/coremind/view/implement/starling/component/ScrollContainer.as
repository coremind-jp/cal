package jp.coremind.view.implement.starling.component
{
    import jp.coremind.asset.Grid3ImageAsset;
    import jp.coremind.module.ModuleList;
    import jp.coremind.module.ScrollbarModule;
    import jp.coremind.view.builder.parts.IBackgroundBuilder;
    import jp.coremind.view.implement.starling.Container;
    import jp.coremind.view.layout.Layout;
    
    public class ScrollContainer extends Container
    {
        /**
         * 任意の表示オブジェクトをスクロールさせるクラス.
         */
        public function ScrollContainer(
            layoutCalculator:Layout,
            backgroundBuilder:IBackgroundBuilder = null)
        {
            super(layoutCalculator, backgroundBuilder);
        }
        
        override protected function _initializeModules():void
        {
            super._initializeModules();
            
            var modules:ModuleList = elementInfo.modules;
            var scrollbar:ScrollbarModule;
            
            for (var i:int = 0, len:int = numChildren; i < len; i++) 
            {
                var  grid3:Grid3ImageAsset = getChildAt(i) as Grid3ImageAsset;
                if (!grid3) continue;
                
                if (!scrollbar)
                     scrollbar = (modules.isUndefined(ScrollbarModule) ?
                        modules.addModule(new ScrollbarModule()):
                        modules.getModule(ScrollbarModule)) as ScrollbarModule;
                
                grid3.width < grid3.height ?
                    scrollbar.initializeY(grid3, grid3.height, grid3.y):
                    scrollbar.initializeX(grid3, grid3.width,  grid3.x);
            }
        }
        
    }
}