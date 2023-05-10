import Foundation

class Settings: ObservableObject {
    static let shared = Settings()
    
    @Published var favList = Array<Int>()
    @Published var pinList = Array<Int>()

    private init() {
        if let favList = UserDefaults.standard.array(forKey: Constants.UserDefaults.favListKey) as? [Int] {
            self.favList = Array(favList)
        } else {
            UserDefaults.standard.set([Int](), forKey: Constants.UserDefaults.favListKey)
        }
        
        if let pinList = UserDefaults.standard.array(forKey: Constants.UserDefaults.pinListKey) as? [Int] {
            self.pinList = Array(pinList)
        } else {
            UserDefaults.standard.set([Int](), forKey: Constants.UserDefaults.pinListKey)
        }
    }
    
    func onFavToggle(_ id: Int) -> Void {
        if favList.contains(id) {
            favList.removeAll { $0 == id }
        } else {
            favList.append(id)
        }
        UserDefaults.standard.set(Array(favList), forKey: Constants.UserDefaults.favListKey)
    }
    
    func onPinToggle(_ id: Int) -> Void {
        if pinList.contains(id) {
            pinList.removeAll { $0 == id }
        } else {
            pinList.append(id)
        }
        UserDefaults.standard.set(Array(pinList), forKey: Constants.UserDefaults.pinListKey)
    }
}
