import WidgetKit
import SwiftUI
import HackerNewsKit

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> StoryEntry {
        let story = Story(id: 0, title: "This is a top story", text: "text", url: "", type: "", by: "Z Combinator", score: 100, descendants: 24, time: Int(Date().timeIntervalSince1970))
        return StoryEntry(date: Date(), story: story)
    }

    func getSnapshot(in context: Context, completion: @escaping (StoryEntry) -> ()) {
        Task {
            let ids = await StoriesRepository.shared.fetchStoryIds(from: .top)
            guard let first = ids.first else { return }
            let story = await StoriesRepository.shared.fetchStory(first)
            guard let story = story else { return }
            let entry = StoryEntry(date: Date(), story: story)
            completion(entry)
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        Task {
            let ids = await StoriesRepository.shared.fetchStoryIds(from: .top)
            guard let first = ids.first else { return }
            let story = await StoriesRepository.shared.fetchStory(first)
            guard let story = story else { return }
            let entry = StoryEntry(date: Date(), story: story)
            
            let timeline = Timeline(entries: [entry], policy: .atEnd)
            completion(timeline)
        }
    }
}

struct StoryEntry: TimelineEntry {
    let date: Date
    let story: Story
}

struct StoryWidgetView : View {
    @Environment(\.widgetFamily) var family
    var story: Story

    var body: some View {
        switch family {
        case .accessoryRectangular:
            VStack(alignment: .leading, spacing: 0) {
                Text(story.shortMetadata)
                    .font(.caption)
                Text(story.title.orEmpty)
                    .font(.caption).fontWeight(.bold)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                Spacer(minLength: 0)
            }
            .widgetURL(URL(string: "\(story.id)"))
        default:
            HStack {
                VStack {
                    Text(story.title.orEmpty)
                        .font(family == .systemSmall ? .caption : .body)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                        .padding([.horizontal, .top])
                    Spacer()
                    HStack {
                        if let url = story.readableUrl {
                            Text(url)
                                .font(family == .systemSmall ? .system(size: 10) : .footnote)
                                .foregroundColor(.orange)
                        } else if let text = story.text {
                            Text(text)
                                .font(.footnote)
                                .lineLimit(2)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    }.padding(.horizontal)
                    Divider().frame(maxWidth: .infinity)
                    HStack(alignment: .center) {
                        Text(story.metadata.orEmpty)
                            .font(family == .systemSmall ? .system(size: 12) : .caption)
                            .padding(.top, 6)
                            .padding(.leading)
                            .padding(.bottom, 12)
                        Spacer()
                    }
                }
            }
            .widgetURL(URL(string: "\(story.id)"))
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(16)
        }
    }
}

struct StoryWidget: Widget {
    let kind: String = "StoryWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            StoryWidgetView(story: entry.story)
        }
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular])
        .configurationDisplayName("Top Story")
        .description("Watch out. It's hot.")
    }
}
