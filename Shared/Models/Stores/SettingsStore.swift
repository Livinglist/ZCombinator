import Foundation
import HackerNewsKit

fileprivate extension String {
    static let favListKey = "favList"
    static let pinListKey = "pinList"
    static let isAutomaticDownloadEnabledKey = "isAutomaticDownloadEnabled"
    static let useCellularDataKey = "useCellularData"
    static let downloadFrequencyKey = "downloadFrequency"
    static let defaultStoryTypeKey = "defaultStoryType"
}

enum DownloadFrequency: TimeInterval, Equatable, CaseIterable {
    case oneWeek = 604800
    case oneDay = 86400
    case halfDay = 43200
    case fourHours = 14400
    case oneHour = 3600

    var label: String {
        switch self {
        case .oneWeek: return "Every Week"
        case .oneDay: return "Every Day"
        case .halfDay: return "Every 12 Hours"
        case .fourHours: return "Every 4 Hours"
        case .oneHour: return "Every One Hours"
        }
    }
}

class SettingsStore: ObservableObject {
    @Published var favList: [Int] = .init()
    @Published var pinList: [Int] = .init()
    @Published var isAutomaticDownloadEnabled: Bool = .init() {
        didSet {
            UserDefaults.standard.set(isAutomaticDownloadEnabled, forKey: .isAutomaticDownloadEnabledKey)
        }
    }
    @Published var useCellularData: Bool = .init() {
        didSet {
            UserDefaults.standard.set(useCellularData, forKey: .useCellularDataKey)
        }
    }
    @Published var downloadFrequency: DownloadFrequency = .oneDay {
        didSet {
            UserDefaults.standard.setValue(downloadFrequency.rawValue, forKey: .downloadFrequencyKey)
        }
    }
    @Published var defaultStoryType: StoryType = .top {
        didSet {
            UserDefaults.standard.setValue(defaultStoryType.rawValue, forKey: .defaultStoryTypeKey)
        }
    }

    static let shared: SettingsStore = .init()

    private init() {
        if let favList = UserDefaults.standard.array(forKey: .favListKey) as? [Int] {
            self.favList = Array(favList)
        } else {
            UserDefaults.standard.set([Int](), forKey: .favListKey)
        }
        
        if let pinList = UserDefaults.standard.array(forKey: .pinListKey) as? [Int] {
            self.pinList = Array(pinList)
        } else {
            UserDefaults.standard.set([Int](), forKey: .pinListKey)
        }

        isAutomaticDownloadEnabled = UserDefaults.standard.bool(forKey: .isAutomaticDownloadEnabledKey)
        useCellularData = UserDefaults.standard.bool(forKey: .useCellularDataKey)

        let downloadFrequencyRawValue = UserDefaults.standard.double(forKey: .downloadFrequencyKey)
        if let downloadFrequency = DownloadFrequency(rawValue: downloadFrequencyRawValue) {
            self.downloadFrequency = downloadFrequency
        }

        if let defaultStoryTypeRawValue = UserDefaults.standard.string(forKey: .defaultStoryTypeKey),
           let defaultStoryType = StoryType(rawValue: defaultStoryTypeRawValue) {
            self.defaultStoryType = defaultStoryType
        }
    }
    
    func onFavToggle(_ id: Int) -> Void {
        if favList.contains(id) {
            favList.removeAll { $0 == id }
        } else {
            favList.append(id)
        }
        UserDefaults.standard.set(Array(favList), forKey: .favListKey)
    }
    
    func onPinToggle(_ id: Int) -> Void {
        if pinList.contains(id) {
            pinList.removeAll { $0 == id }
        } else {
            pinList.append(id)
        }
        UserDefaults.standard.set(Array(pinList), forKey: .pinListKey)
    }
}
