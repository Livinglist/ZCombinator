import SwiftUI

struct PinButton: View {
    @ObservedObject private var settings = Settings.shared
    
    let id: Int
    
    var body: some View {
        Button {
            onPin()
        } label: {
            if settings.pinList.contains(id) {
                Label("Unpin", systemImage: "pin.slash")
            } else {
                Label("Favorite", systemImage: "pin")
            }
        }
    }
    
    private func onPin() {
        settings.onPinToggle(id)
    }
}
