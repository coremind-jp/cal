package
{
    import Array;
    
    import flash.display.Sprite;
    
    import flexUnitTests.TestMultistageStatus;
    
    import flexunit.flexui.FlexUnitTestRunnerUIAS;
    
    import org.flexunit.runner.Request;
    
    public class FlexUnitApplication extends Sprite
    {
        public function FlexUnitApplication()
        {
            onCreationComplete();
        }
        
        private function onCreationComplete():void
        {
            var testRunner:FlexUnitTestRunnerUIAS=new FlexUnitTestRunnerUIAS();
            testRunner.portNumber=8765; 
            this.addChild(testRunner); 
            testRunner.runWithFlexUnit4Runner(currentRunTestSuite(), "cmal");
        }
        
        public function currentRunTestSuite():Array
        {
            var testsToRun:Array = new Array();
            testsToRun.push(Request.methods(flexUnitTests.TestMultistageStatus,["testEqual"]));
            
            return testsToRun;
        }
    }
}