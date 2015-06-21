package flexUnitTests
{
    import jp.coremind.utility.validation.HashValidation;
    import jp.coremind.utility.validation.IValidation;
    
    import org.flexunit.Assert;
    
    public class TestHashValidation
    {		
        private var validation:IValidation;
        
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
            validation = new HashValidation(_validationDefine);
            
            //初期定義notNullはfalseなのでnullやundefinedを許容する
            Assert.assertEquals(validation.exec(null), true);
            Assert.assertEquals(validation.exec(undefined), true);
            //初期定義contextは未定義なのでなんでもマッチする
            Assert.assertEquals(validation.exec({}), true);
            
            //notNullをtrueにするとnull, undefinedを許可しない
            _validationDefine.notNull = true;
            Assert.assertEquals(validation.exec(null), false);
            Assert.assertEquals(validation.exec(undefined), false);
            
            //context内のtypeにあわせて適切にValidationが切り替わる
            _validationDefine.context = {
                optionMatcher : { type:String, req:false, def: { notNull: true, length: 8, rule: /optionValue/ } },
                stringMatcher : { type:String, req:true, def: { notNull: true, length: 8, rule: /^a.*z$/ } },
                numberMatcher1: { type:int,    req:true, def: { notNull: true, rule: "95756" } },
                numberMatcher2: { type:Number, req:true, def: { notNull: true, rule: ".5976" } },
                hashMatcher   : { type:Object, req:true, def: {
                    notNull: true,
                    context: {
                        stringMatcher : { type:String, req:true, def: { notNull: true, length: 13, rule: /^z.*a$/ } }
                    }
                },
                arrayMatcher  : { type:Array,  req:true, def: {
                    notNull: true,
                    context: {
                        stringMatcher : { type:String, req:true, def: { notNull: true, length: 5, rule: /^q.*q$/ } }
                    }
                }}}
            };
            
            var _hash:Object = {
                stringMatcher : "a688254z",
                numberMatcher1: 95756,
                numberMatcher2: .5976,
                hashMatcher   : {
                    stringMatcher: "z99888dggeeaa"
                },
                arrayMatcher  : ["q133q", "q6agq", "qdfeq"]
            };
            //req:falseのプロパティーはなくても許可される
            Assert.assertEquals(validation.exec(_hash), true);
            
            //reqをtrueにすると許可されなくなる
            _validationDefine.context.optionMatcher.req = true;
            Assert.assertEquals(validation.exec(_hash), false);
        }
    }
}