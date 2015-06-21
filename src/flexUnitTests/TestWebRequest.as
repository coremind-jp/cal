package flexUnitTests
{
    import flash.net.URLRequestMethod;
    import flash.net.URLVariables;
    
    import jp.coremind.control.Routine;
    import jp.coremind.control.Thread;
    import jp.coremind.control.routine.WebRequest;
    import jp.coremind.data.HashList;
    import jp.coremind.network.RequestConfigure;
    import jp.coremind.resource.ContentParser;
    
    public class TestWebRequest
    {		
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
        public function testCreate():void
        {
            var r:RequestConfigure = new RequestConfigure({});
            r.method(URLRequestMethod.POST);
            r.contentParser(ContentParser.JSON);
            
            var url:String = "https://api.flickr.com/services/rest/?"
                + $.hash.marge(new URLVariables(),
                    {
                        method        : "flickr.photos.search",
                        api_key       : "323d9b367fd7ccccf1767cfad40f0153",
                        tags          : "手",
                        per_page      : 88,
                        page          : int(Math.random() * 10),
                        sort          : "interestingness-desc",
                        content_type  : 7,
                        format        : "json",
                        safe_search   : 3,
                        nojsoncallback:1
                    }).toString();
            
            var _photoList:HashList;
            
            new Thread("flickr api test")
                .pushRoutine(WebRequest.create("photosSearchResult", url, null, r))
                .pushRoutine(function(p:Routine, t:Thread):void
                {
                    var i:int = 0;
                    _photoList = new HashList($.hash.read(t.readData("photosSearchResult"), "photos.photo"));
                    
                    do
                    {
                        var o:Object = _photoList.headElement;
                        
                        new Thread(o.id+"_"+o.secret)
                            .pushRoutine(WebRequest.create("DLC", "http://farm"+o.farm+".staticflickr.com/"+o.server+"/"+o.id+"_"+o.secret+"_b.jpg"))
                            .pushRoutine(function(p:Routine, t:Thread):void { p.scceeded(); })
                            .oneShot();
                    }
                    while (_photoList.next());
                    
                    p.scceeded();
                }).oneShot();
            
            //setTimeout(_update, 15000);
        }
    }
}