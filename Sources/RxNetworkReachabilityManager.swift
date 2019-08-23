import RxSwift
import Alamofire

open class RxNetworkReachabilityManager {
    
    public typealias NetworkReachabilityStatus = NetworkReachabilityManager.NetworkReachabilityStatus
    
    private let reachabilityManager: NetworkReachabilityManager
    private let statusSubject: BehaviorSubject<NetworkReachabilityStatus>
    
    public init?(host: String) {
        guard let mgr = NetworkReachabilityManager(host: host) else { return nil }
        self.reachabilityManager = mgr
        self.statusSubject = .init(value: mgr.networkReachabilityStatus)
    }
    
    public init?() {
        guard let mgr = NetworkReachabilityManager() else { return nil }
        self.reachabilityManager = mgr
        self.statusSubject = .init(value: mgr.networkReachabilityStatus)
    }
    
    private func setupListener() {
        assert(self.reachabilityManager.listener == nil)
        let subject = self.statusSubject
        self.reachabilityManager.listener = {
            subject.onNext($0)
        }
    }
    
    private var reachabilityChanged: Observable<NetworkReachabilityStatus> {
        return self.statusSubject.asObserver()
    }
    
    /// Observes whether the network is currently reachable over the WWAN interface.
    public var isReachableOnWWAN: Observable<Bool> {
        return self.reachabilityChanged.map { $0 == .reachable(.wwan) }
    }
    
    /// Observes whether the network is currently reachable over Ethernet or WiFi interface.
    public var isReachableOnEthernetOrWiFi: Observable<Bool> {
        return self.reachabilityChanged.map { $0 == .reachable(.ethernetOrWiFi) }
    }
    
    /// Observes whether the network is currently reachable.
    public var isReachable: Observable<Bool> {
        return Observable.merge(self.isReachableOnWWAN, self.isReachableOnEthernetOrWiFi)
    }
    
    /// Observes the current network reachability status.
    public var networkReachabilityStatus: Observable<RxNetworkReachabilityManager.NetworkReachabilityStatus> {
        return self.reachabilityChanged
    }
    
    /// Alias for networkReachabilityStatus.
    public var status: Observable<RxNetworkReachabilityManager.NetworkReachabilityStatus> {
        return self.networkReachabilityStatus
    }
}
