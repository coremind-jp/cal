package flexUnitTests
{
    import flexunit.framework.Assert;
    
    import jp.coremind.view.implement.flash.View;
    import jp.coremind.control.flash.ViewControl;
    
    public class TestViewControl
    {		
        private var ctrl:ViewControl;
        [Before]
        public function setUp():void
        {
            View;
            ctrl = new ViewControl();
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
            ctrl.push("jp.coremind.view::View");
            //0
            ctrl.pop();
            //1
            ctrl.push(View);
            //2
            ctrl.push(View);
            //1
            ctrl.pop();
            //0
            ctrl.pop();
        }
        
        [Test]
        public function testReplace():void
        {
            Assert.fail("Test method Not yet implemented");
        }
    }
}