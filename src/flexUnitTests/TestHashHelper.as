package flexUnitTests
{
    import flexunit.framework.Assert;
    
    import org.flexunit.asserts.assertFalse;
    import org.flexunit.asserts.assertTrue;
    
    public class TestHashHelper
    {		
        private var o:Object;
        
        [Before]
        public function setUp():void
        {
            o = {};
        }
        
        [After]
        public function tearDown():void
        {
            o = null;
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
        public function testCreatePropertyList():void
        {
            o.a = 0;
            o.b = 1;
            o.c = 2;
            
            //ハッシュ配列からキーを正しく取り出せる
            var _propList:Array = $.hash.createPropertyList(o);
            assertTrue(_propList.length == 3);
            assertTrue(_propList.indexOf("a") > -1);
            assertTrue(_propList.indexOf("b") > -1);
            assertTrue(_propList.indexOf("c") > -1);
        }
        
        [Test]
        public function testRead():void
        {
            var _ref:Object = { childA:{ childB:{ childC:"valueSample"} } };
            o.value = _ref;
            
            //第一引数にハッシュ以外のデータを渡しても停止せずにundefinedを返す
            assertTrue($.hash.read("valid param", "value") === undefined);
            
            //値が正しく読み取れる
            assertTrue($.hash.read(o, "value") === _ref);
            
            //多重構造のハッシュについても正しく値を読み取れる
            assertTrue($.hash.read(o, "value.childA.childB.childC") === "valueSample");
            
            //存在しないパスを指定しても停止せずにundefinedを返す
            assertTrue($.hash.read(o, "undefinedKey") === undefined);
            assertTrue($.hash.read(o, "value.childA.undefinedKeyA.undefinedKeyB") === undefined);
        }
        
        [Test]
        public function testWrite():void
        {
            var _newValue:Object = {};
            
            //値が正しく書き込める
            $.hash.write(o, "newKey", _newValue);
            assertTrue($.hash.read(o, "newKey") === _newValue);
            
            //多重構造のハッシュについても正しく値を書き込める
            $.hash.write(o, "newKey.childA", "childAValue");
            assertTrue($.hash.read(o, "newKey.childA") === "childAValue");
            
            //存在しないパスを指定しても生成し書き込める
            $.hash.write(o, "undefinedKey", "keep running");
            Assert.assertEquals($.hash.read(o, "undefinedKey"), "keep running");
            $.hash.write(o, "value.undefinedKey", "keep running");
            Assert.assertEquals($.hash.read(o, "value.undefinedKey"), "keep running");
            
            //既に存在するプロパティには書き込めない
            $.hash.write(o, "newKey", "override");
            assertTrue($.hash.read(o, "newKey") === _newValue);
        }
        
        [Test]
        public function testUpdate():void
        {
            o = { n:0, e:0, w:0, p:0, a:0, r:0, a2:0, m:0, s:0 };
            var _updateParams:Object = { n:0, e:1, w:2, p:3, a:4, r:5, a2:6, m:7, s:8, undefinedKey:9 };
            
            $.hash.update(o, _updateParams);
            //oのプロパティ値が_updateParamsの値になっている
            Assert.assertEquals(o.n, 0);
            Assert.assertEquals(o.e, 1);
            Assert.assertEquals(o.w, 2);
            Assert.assertEquals(o.p, 3);
            Assert.assertEquals(o.a, 4);
            Assert.assertEquals(o.r, 5);
            Assert.assertEquals(o.a2, 6);
            Assert.assertEquals(o.m, 7);
            Assert.assertEquals(o.s, 8);
            //但し、undefinedKeyはoに存在しないので無視される
            Assert.assertEquals(o.undefinedKey, undefined);
        }
        
        [Test]
        public function testMarge():void
        {
            o = { n:0, e:0, w:0, p:0, a:0, r:0, a2:0, m:0, s:0 };
            var _margeParams:Object = { n:0, e:1, w:2, p:3, a:4, r:5, a2:6, m:7, s:8, undefinedKey:9 };
            
            $.hash.marge(o, _margeParams);
            //oのプロパティ値が_updateParamsの値になっている
            Assert.assertEquals(o.n, 0);
            Assert.assertEquals(o.e, 1);
            Assert.assertEquals(o.w, 2);
            Assert.assertEquals(o.p, 3);
            Assert.assertEquals(o.a, 4);
            Assert.assertEquals(o.r, 5);
            Assert.assertEquals(o.a2, 6);
            Assert.assertEquals(o.m, 7);
            Assert.assertEquals(o.s, 8);
            //但し、updateと違い_margeParamsに含まれる全ての値が渡される
            Assert.assertEquals(o.undefinedKey, 9);
        }
    }
}