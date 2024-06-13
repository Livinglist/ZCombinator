import SwiftUI
import HackerNewsKit

struct SubscriptionButton: View {
    let item: any Item
    let actionPerformed: Binding<Action>

    var body: some View {
        Button {
            onPin()
        } label: {
            Label("Subscribe", systemImage: Action.subscribe.icon)
        }
    }

    private func onPin() {
        LiveActivityManager.shared.startLiveActivity(for: item)
        actionPerformed.wrappedValue = .subscribe
    }
}
