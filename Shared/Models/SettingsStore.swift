//
//  SettingsStore.swift
//  ZCombinator
//
//  Created by Jiaqi Feng on 5/2/23.
//

import Foundation

class SettingsStore: ObservableObject {
    @Published var favList: Set<Int> = Set<Int>()
    @Published var pinList: Set<Int> = Set<Int>()
    
    init() {
        if let favList = UserDefaults.standard.array(forKey: Constants.UserDefaults.favListKey),
           let pinList = UserDefaults.standard.array(forKey: Constants.UserDefaults.pinListKey) {
            self.favList = Set(favList as! [Int])
            self.pinList = Set(pinList as! [Int])
        } else {
            UserDefaults.standard.set([Int](), forKey: Constants.UserDefaults.favListKey)
            UserDefaults.standard.set([Int](), forKey: Constants.UserDefaults.pinListKey)
        }
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
