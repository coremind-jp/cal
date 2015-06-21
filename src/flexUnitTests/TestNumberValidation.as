package flexUnitTests
{
    import org.flexunit.Assert;
    
    import jp.coremind.utility.validation.IValidation;
    import jp.coremind.utility.validation.NumberValidation;
    
    public class TestNumberValidation
    {		
        var validation:IValidation;
        
        [Before]
        public function setUp():void
        {
        }
        
        [After]
        public function tearDown():void
        {
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
        public function testExec():void
        {
            var _validationDefine:Object = {};
            validation = new NumberValidation(_validationDefine);
            
            //初期定義notNullはfalseなのでnullやundefinedを許容する
            Assert.assertEquals(validation.exec(null), true);
            Assert.assertEquals(validation.exec(undefined), true);
            //初期定義ruleは未定義なのでどの文字列にもマッチする
            Assert.assertEquals(validation.exec(54), true);
            
            //notNullをtrueにするとnull, undefinedを許可しない
            _validationDefine.notNull = true;
            Assert.assertEquals(validation.exec(null), false);
            Assert.assertEquals(validation.exec(undefined), false);
            
            //ruleにマッチしない文字列は許可しない
            _validationDefine.rule = "54|20|.25|6.99|-5.02|100~101|-9~-8";
            Assert.assertEquals(validation.exec(54), true);
            Assert.assertEquals(validation.exec(20), true);
            
            Assert.assertEquals(validation.exec(.25), true);
            Assert.assertEquals(validation.exec(0.25), true);
            Assert.assertEquals(validation.exec(6.99), true);
            
            Assert.assertEquals(validation.exec(-5.02), true);
            
            Assert.assertEquals(validation.exec(99), false);
            Assert.assertEquals(validation.exec(100), true);
            Assert.assertEquals(validation.exec(101), true);
            Assert.assertEquals(validation.exec(102), false);
            
            Assert.assertEquals(validation.exec(-10), false);
            Assert.assertEquals(validation.exec(-9), true);
            Assert.assertEquals(validation.exec(-8), true);
            Assert.assertEquals(validation.exec(-7), false);
        }
    }
}