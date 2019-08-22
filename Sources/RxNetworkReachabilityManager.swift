import RxSwift
import Alamofire

open class RxNetworkReachabilityManager: NetworkReachabilityManager, ReactiveCompatible {
    
    public let subject = PublishSubject<NetworkReachabilityStatus>()
    private var underlyingListener: Listener?
    
    override open var listener: Listener? {
        get {
            return underlyingListener
        }
        set {
            underlyingListener = { [weak self] in
                newValue?($0)
                self?.subject.onNext($0)
            }
        }
    }
    
    public var reachabilityDidChange: Observable<NetworkReachabilityStatus> {
        return self.subject.asObserver()
    }
}


extension Reactive where Base: RxNetworkReachabilityManager {
    
    /// Whether the network is currently reachable.
    public var isReachable: Observable<Bool> {
        return self.isReachableOnWWAN.withLatestFrom(self.isReachableOnEthernetOrWiFi).asObservable()
    }
    
    /// Whether the network is currently reachable over the WWAN interface.
    public var isReachableOnWWAN: Observable<Bool> {
        return self.base.reachabilityDidChange.map { $0 == .reachable(.wwan) }
    }
    
    /// Whether the network is currently reachable over Ethernet or WiFi interface.
    public var isReachableOnEthernetOrWiFi: Observable<Bool> {
        return self.base.reachabilityDidChange.map { $0 == .reachable(.ethernetOrWiFi) }
    }
    
    /// The current network reachability status.
    public var networkReachabilityStatus: Observable<RxNetworkReachabilityManager.NetworkReachabilityStatus> {
        return self.base.reachabilityDidChange
    }
    
    /// Alias for networkReachabilityStatus.
    public var status: Observable<RxNetworkReachabilityManager.NetworkReachabilityStatus> {
        return self.networkReachabilityStatus
    }
}
