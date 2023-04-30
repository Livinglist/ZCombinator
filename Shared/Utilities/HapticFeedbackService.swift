import Foundation
import UIKit

class HapticFeedbackService {
    static let shared: HapticFeedbackService = HapticFeedbackService()
    
    private let generator = UINotificationFeedbackGenerator()
    
    private init() {}
    
    func success() -> Void {
        generator.notificationOccurred(.success)
    }
    
    func error() -> Void {
        generator.notificationOccurred(.error)
    }
    
    func warning() -> Void {
        generator.notificationOccurred(.warning)
    }
}
