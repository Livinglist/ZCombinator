import SwiftUI
import HackerNewsKit

class Router: ObservableObject {
    @Published var path = NavigationPath()
    
    static let shared = Router()
    
    private init() { }
    
    func to(_ destination: Destination) {
        path.append(destination)
    }
    
    func to(_ item: any Item) {
        path.append(item)
    }
}
