import Foundation

class Settings: ObservableObject {
    static let shared = Settings()
    
    @Published var favList = Set<Int>()
    @Published var pinList = Set<Int>()

    private init() {
        if let favList = UserDefaults.standard.array(forKey: Constants.UserDefaults.favListKey) as? [Int] {
            self.favList = Set(favList)
        } else {
            UserDefaults.standard.set([Int](), forKey: Constants.UserDefaults.favListKey)
        }
        
        if let pinList = UserDefaults.standard.array(forKey: Constants.UserDefaults.pinListKey) as? [Int] {
            self.pinList = Set(pinList)
        } else {
            UserDefaults.standard.set([Int](), forKey: Constants.UserDefaults.pinListKey)
        }
    }
    
    func onFavToggle(_ id: Int) -> Void {
        if favList.contains(id) {
            favList.remove(id)
        } else {
            favList.insert(id)
        }
        UserDefaults.standard.set(Array(favList), forKey: Constants.UserDefaults.favListKey)
    }
    
    func onPinToggle(_ id: Int) -> Void {
        if pinList.contains(id) {
            pinList.remove(id)
        } else {
            pinList.insert(id)
        }
        UserDefaults.standard.set(Array(pinList), forKey: Constants.UserDefaults.pinListKey)
    }
}
