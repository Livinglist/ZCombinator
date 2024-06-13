import Combine
import Foundation
import HackerNewsKit
import ActivityKit

public struct StoryAttributes: ActivityAttributes {

    public struct ContentState: Codable, Hashable {
        public enum OrderStatus: Float, Codable, Hashable {
            case inQueue = 0
            case aboutToTake
            case making
            case ready

            var description: String {
                switch self {
                case .inQueue:
                    return "Your order is in the queue"
                case .aboutToTake:
                    return "We're about to take your order"
                case .making:
                    return "We're preparing your order"
                case .ready:
                    return "Your order is ready to pick up!"
                }
            }
        }

        var comment: Comment?

        public init() {
            self.comment = nil
        }

        public init(comment: Comment) {
            self.comment = comment
        }
    }

    let orderNumber: Int
}

class LiveActivityManager {

    private let StoryAttributes: StoryAttributes
    private var orderActivity: Activity<StoryAttributes>?
    static let shared = LiveActivityManager()
    var cancellable: Cancellable? = nil
    var previousId: Int? = nil
    var parentId: Int? = nil

    private init() {
        StoryAttributes = .init(orderNumber: 8)
        setupActivity()
    }

    func startLiveActivity(for item: any Item) {
        if parentId == item.id {
            return
        } else {
            parentId = item.id
        }

        setupActivity()
        cancellable = DispatchQueue.global().schedule(after:.init(.now()), interval: .seconds(60), tolerance: .seconds(60), options: .init(qos: .userInitiated)) {
            Task {
                if let item = await StoryRepository.shared.fetchItem(item.id),
                   let latestId = item.kids?.sorted().last {
                    guard self.previousId != latestId else { return }
                    self.previousId = latestId
                    if let comment = await StoryRepository.shared.fetchComment(latestId) {
                        await self.updateActivity(to: .init(comment: comment))
                    }
                }
            }
        }
    }

    func setupActivity() {
        if orderActivity != nil {
            return
        }

        let initialState: StoryAttributes.ContentState = .init()
        let content = ActivityContent(state: initialState, staleDate: nil, relevanceScore: 1.0)



        orderActivity = try! Activity.request(
            attributes: StoryAttributes,
            content: content,
            pushType: nil
        )
    }

    func updateActivity(to state: StoryAttributes.ContentState) async {
        let alert = AlertConfiguration(
            title: "New comment from subscription.",
            body: "\(state.comment?.text ?? "")",
            sound: .default
        )
        await orderActivity?.update(
            ActivityContent<StoryAttributes.ContentState>(
                state: state,
                staleDate: nil
            ),
            alertConfiguration: alert
        )
    }

}
