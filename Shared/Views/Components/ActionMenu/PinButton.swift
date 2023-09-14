import SwiftUI

struct PinButton: View {
    @ObservedObject private var settings: Settings = .shared
    
    let id: Int
    let actionPerformed: Binding<Action>
    
    var body: some View {
        Button {
            onPin()
        } label: {
            if settings.pinList.contains(id) {
                Label("Unpin", systemImage: "pin.slash")
            } else {
                Label("Pin", systemImage: "pin")
            }
        }
    }
    
    private func onPin() {
        let isPinned = settings.pinList.contains(id)
        if isPinned {
            actionPerformed.wrappedValue = .unpin
        } else {
            actionPerformed.wrappedValue = .pin
        }
        HapticFeedbackService.shared.success()
        settings.onPinToggle(id)
    }
}
