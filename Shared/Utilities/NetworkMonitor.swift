import Network
import Combine

final class NetworkMonitor {
    let networkStatus = CurrentValueSubject<Bool, Never>(true)
    var onWifi = true
    var onCellular = true
    
    private let pathMonitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "NetworkMonitor")
    
    static let shared = NetworkMonitor()
    
    init() {
        pathMonitor.pathUpdateHandler = { [weak self] path in
            guard let self else { return }
            
            networkStatus.send(path.status == .satisfied)
            onWifi = path.usesInterfaceType(.wifi)
            onCellular = path.usesInterfaceType(.cellular)
        }
        
        pathMonitor.start(queue: monitorQueue)
    }
}
