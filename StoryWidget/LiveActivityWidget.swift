import WidgetKit
import SwiftUI
import HackerNewsKit
import AppIntents
import ActivityKit

struct LiceActivityWidgetView : View {
    @Environment(\.widgetFamily) var family
    @Environment(\.showsWidgetContainerBackground) var showsWidgetContainerBackground
    var comment: Comment? = nil
    var source: StorySource

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("@\(comment?.by ?? "") from \(comment?.timeAgo ?? ""):")
                    .font(.system(size: 12))
                    .padding(.top, 4)
                    .padding(.leading)
                Spacer()
            }
            Text(comment?.text ?? "")
                .multilineTextAlignment(.leading)
                .font(.system(size: 14))
                .padding(.leading, 12)
                .padding(.trailing, 6)
                .frame(maxWidth: .infinity, alignment: .leading)
            Spacer()
        }
        .background(Color.orange.opacity(0.6))
    }
}

struct LiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: StoryAttributes.self) { context in
            LiceActivityWidgetView(comment: context.state.comment, source: .top)
                .widgetURL(URL(string: "\(context.state.comment?.id ?? 0)"))
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.bottom) {
                    VStack {
                        if let comment = context.state.comment {
                            Text("@\(comment.by.orEmpty) from \(comment.timeAgo):")
                                .font(.system(size: 12))
                                .padding(.bottom, 4)
                            Text(comment.text.orEmpty)
                                .font(.system(size: 14))
                                .multilineTextAlignment(.leading)
                                .padding(.horizontal, 12)
                        }
                    }
                }
            } compactLeading: {
                Image(systemName: "circle")
                    .foregroundColor(.orange)
            } compactTrailing: {
                Text("Hacki")
            } minimal: {
                Image(systemName: "circle")
                    .foregroundColor(.orange)
            }
            .widgetURL(URL(string: "\(context.state.comment?.id ?? 0)"))
        }
    }
}

extension StoryAttributes {
    fileprivate static var preview: StoryAttributes {
        return StoryAttributes(orderNumber: 1)
    }
}

struct Widget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            StoryAttributes.preview
                .previewContext(.init(), viewKind: .content)
        }
    }
}
