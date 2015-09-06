package flexUnitTests
{
    import flexunit.framework.Assert;
    
    import jp.coremind.view.implement.flash.View;
    import jp.coremind.control.CpuViewController;
    
    public class TestViewControl
    {		
        private var ctrl:CpuViewController;
        [Before]
        public function setUp():void
        {
            View;
            ctrl = new CpuViewController();
        }
        
        [After]
        public function tearDown():void
        {
            ctrl = null;
        }
        
        [BeforeClass]
        public static function setUpBeforeClass():void
        {
        }
        
        [AfterClass]
        public static function tearDownAfterClass():void
        {
        }
        
        [Test]
        public function testPushAndPop():void
        {
            //1
            ctrl.push(0, "jp.coremind.view::View");
            //0
            ctrl.pop(0);
            //1
            ctrl.push(0, View);
            //2
            ctrl.push(0, View);
            //1
            ctrl.pop(0);
            //0
            ctrl.pop(0);
        }
        
        [Test]
        public function testReplace():void
        {
            Assert.fail("Test method Not yet implemented");
        }
    }
}