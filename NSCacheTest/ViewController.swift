import UIKit

class ViewController: UIViewController, NSCacheDelegate {

    static let kCacheFillCount = 5
    
    private var cache: NSCache!
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        cache = createCache()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        cache = createCache()
    }
    
    // MARK:- View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationDidBecomeActiveNotification, object: nil, queue: NSOperationQueue.mainQueue()) { [unowned self](_) -> Void in

            print("\nDid become active")
            self.checkCache()
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationDidEnterBackgroundNotification, object: nil, queue: NSOperationQueue.mainQueue()) { [unowned self](_) -> Void in
            
            print("\nDid enter background")
            self.checkCache()
        }
        
        fillCache()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        print("\ndidReceiveMemoryWarning")
        checkCache()
    }

    // MARK:- Protocols
    
    // MARK:- NSCacheDelegate
    
    func cache(cache: NSCache, willEvictObject obj: AnyObject) {
        print("Cache: \(cache.name) willEvictObject")
    }
    
    // MARK:- Privete Methods
    
    func createCache() -> NSCache {
        let cache = NSCache()
        cache.name = "Test Cache"
        cache.delegate = self
        cache.evictsObjectsWithDiscardedContent = true
        return cache
    }

    func fillCache() {
        
        guard let imageDataPath = NSBundle.mainBundle().pathForResource("img_0594", ofType: "jpg") else {
            print("Did not find resource path =(")
            return
        }
        
        print("\nWill fill cache: \(cache.name)")
        
        for i in 1...ViewController.kCacheFillCount {

//            guard let imageData = NSData(contentsOfFile: imageDataPath) else {
            guard let imageData = NSPurgeableData(contentsOfFile: imageDataPath) else {
                print("Could not load image data =(")
                continue
            }
            
            let key = "Cached_Image_№ \(i)"
            cache.setObject(imageData, forKey: key)
            
            print("Cached image data with key: \(key)")
            
            imageData.endContentAccess()
//
//            imageData.discardContentIfPossible()
        }
        
        print("Did fill cache: \(cache.name)\n")
    }
    
    func checkCache() {
        print("\nWill check cache: \(cache.name)")
        
        for i in 1...ViewController.kCacheFillCount {
            let key = "Cached_Image_№ \(i)"
//            if let cachedData = cache.objectForKey(key) as? NSData {
            if let cachedData = cache.objectForKey(key) as? NSPurgeableData {

                if cachedData.beginContentAccess() {
                    print("There IS a cached data with key: \(key) and size: \(Double(cachedData.length) / 1024.0)")
                    cachedData.endContentAccess()
                }
                else {
                    print("Data was discarded")
                }
            }
            else {
               print("There is NO cached data with key: \(key)")
            }
        }
        
        print("Did check cache: \(cache.name)\n")
    }
}

