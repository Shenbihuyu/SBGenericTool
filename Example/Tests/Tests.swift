import XCTest
import SBGenericTool

class Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testVersionModelnil() {
        // This is an example of a functional test case.
        UserDefaults.standard.removeObject(forKey: SBVersion.saveKey) // 清空本地缓存
        XCTAssert(SBVersion.anquan == false, "未请求数据时，版本状态为安全")
        XCTAssert(SBVersion.guanggao == false, "未请求数据时，版本状态为开启广告")
    }
    func testVersionModelzero() {
        let version = SBVersion(audit: 0, advert: 0) // 模拟网络请求
        version.save()
        XCTAssert(SBVersion.anquan == true, "")
        XCTAssert(SBVersion.guanggao == false, "")
    }
    
    func testVersionModelHasValue() {
        let version2 = SBVersion(audit: 1, advert: 5) // 模拟网络请求
        version2.save()
        XCTAssert(SBVersion.anquan == false, "")
        XCTAssert(SBVersion.guanggao == true, "")
    }
}
