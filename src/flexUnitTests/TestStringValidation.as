package flexUnitTests
{
    import org.flexunit.Assert;
    
    import jp.coremind.utility.validation.IValidation;
    import jp.coremind.utility.validation.StringValidation;

    public class TestStringValidation
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
            validation = new StringValidation(_validationDefine);
            
            //初期定義notNullはfalseなのでnullやundefinedを許容する
            Assert.assertEquals(validation.exec(null), true);
            Assert.assertEquals(validation.exec(undefined), true);
            //初期定義lengthは-1なので文字数制限がない
            var s:String = "";
            for (var i:int = 0; i < 1000000; i++)  s += "a";//文字列長100万
            Assert.assertEquals(validation.exec(s), true);
            //初期定義ruleは未定義なのでどの文字列にもマッチする
            Assert.assertEquals(validation.exec("any str match."), true);
            
            //notNullをtrueにするとnull, undefinedを許可しない
            _validationDefine.notNull = true;
            Assert.assertEquals(validation.exec(null), false);
            Assert.assertEquals(validation.exec(undefined), false);
            //lengthに指定した文字列長より多い文字列は許可しない
            _validationDefine.length = 5;
            Assert.assertEquals(validation.exec("12345"), true);
            Assert.assertEquals(validation.exec("123456"), false);
            //rule(正規表現)にマッチしない文字列は許可しない
            _validationDefine.rule = /^a.*z$/;
            Assert.assertEquals(validation.exec("a6efz"), true);
            Assert.assertEquals(validation.exec("z6efa"), false);
        }
    }
}