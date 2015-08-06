package flexUnitTests
{
    import jp.coremind.utility.data.HashList;
    import jp.coremind.utility.data.ListFilter;
    
    import org.flexunit.Assert;
    import org.flexunit.asserts.assertTrue;
    
    public class TestHashList
    {		
        private var list:HashList;
        private var listEnabledTemp:HashList;
        
        [Before]
        public function setUp():void
        {
            listEnabledTemp = new HashList([
                { a: 0,  b: "dataA", c:{ d:"data0" } },
                { a: 5,  b: "dataB", c:{ d:"data1" } },
                { a: 10, b: "dataC", c:{ d:"data2" } },
                { a: 90, b: "dataD", c:{ d:"data3" } },
                { a: 45, b: "dataE", c:{ d:"data4" } },
                { a: 3,  b: "dataF", c:{ d:"data5" } },
                { a: 56, b: "dataG", c:{ d:"data6" } },
                { a: 19, b: "dataH", c:{ d:"data7" } }
            ], true);
            
            list = new HashList([
                { a: 0,  b: "dataA", c:{ d:"data0" } },
                { a: 5,  b: "dataB", c:{ d:"data1" } },
                { a: 10, b: "dataC", c:{ d:"data2" } },
                { a: 90, b: "dataD", c:{ d:"data3" } },
                { a: 45, b: "dataE", c:{ d:"data4" } },
                { a: 3,  b: "dataF", c:{ d:"data5" } },
                { a: 56, b: "dataG", c:{ d:"data6" } },
                { a: 19, b: "dataH", c:{ d:"data7" } }
            ]);
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
        public function testDestory():void
        {
            assertTrue(list.length == 8);
            
            list.destory();
            assertTrue(list.length == 0);
        }
        
        [Test]
        public function testFetch():void
        {
            var _aList:Array = list.fetch("a");
            var _bList:Array = list.fetch("b");
            var _cList:Array = listEnabledTemp.fetch("c.d");
            
            assertTrue(_aList.length == 8 && _bList.length == 8 && _cList.length == 8);
            trace("dumped. fetch aList", _aList);
            trace("dumped. fetch bList", _bList);
            trace("dumped. fetch cList", _cList);
            
            //temporaryInstanceがtrueの場合一度呼び出したら参照がなくなる
            assertTrue(listEnabledTemp.length == 0);
        }
        
        [Test]
        public function testFilter():void
        {
            trace("same filter dumped.", list.filter("a", ListFilter.SAME(90)));
            trace("different filter dumped.", list.filter("a", ListFilter.DIFFERENT(90)));
            
            trace("and less filter dumped.", list.filter("a", ListFilter.AND_LESS(45)));
            trace("less than filter dumped.", list.filter("a", ListFilter.LESS_THAN(45)));
            
            trace("and more filter dumped.", list.filter("a", ListFilter.AND_MORE(45)));
            trace("more than filter dumped.", listEnabledTemp.filter("a", ListFilter.MORE_THAN(45)));
            
            //temporaryInstanceがtrueの場合一度呼び出したら参照がなくなる
            assertTrue(listEnabledTemp.length == 0);
        }
        
        [Test]
        public function testFind():void
        {
            //正しくリストから要素を探し出せる
            var _element:* = list.find("a", 19);
            Assert.assertEquals(19, _element.a);
            Assert.assertEquals("dataH", _element.b);
            
            //値が存在しない場合undefinedを返す
            _element = list.find("a", 27);
            Assert.assertEquals(_element, undefined);
            
            //キーが存在しない場合undefinedを返す
            _element = listEnabledTemp.find("d", 90);
            Assert.assertEquals(_element, undefined);
            
            //temporaryInstanceがtrueの場合一度呼び出したら参照がなくなる
            assertTrue(listEnabledTemp.length == 0);
        }
        
        [Test]
        public function testFindIndex():void
        {
            //正しくリストから要素インデックスを探し出せる
            var i:int = list.findIndex("a", 10);
            Assert.assertEquals(i, 2);
            
            //値が存在しない場合-1を返す
            i = list.findIndex("a", 27);
            Assert.assertEquals(i, -1);
            
            //キーが存在しない場合-1を返す
            i = listEnabledTemp.findIndex("d", 90);
            Assert.assertEquals(i, -1);
            
            //temporaryInstanceがtrueの場合一度呼び出したら参照がなくなる
            assertTrue(listEnabledTemp.length == 0);
        }
        
        [Test]
        public function testGet_length():void
        {
            assertTrue(list.length == 8);
            
            list.destory();
            assertTrue(list.length == 0);
        }
    }
}