import WidgetKit
import SwiftUI
import HackerNewsKit

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        let story = Story(id: 0, title: "This is a top story", text: "text", url: "", type: "", by: "Z Combinator", score: 100, descendants: 24, time: Int(Date().timeIntervalSince1970))
        return SimpleEntry(date: Date(), story: story)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        Task {
            let ids = await StoriesRepository.shared.fetchStoryIds(from: .top)
            guard let first = ids.first else { return }
            let story = await StoriesRepository.shared.fetchStory(first)
            guard let story = story else { return }
            let entry = SimpleEntry(date: Date(), story: story)
            completion(entry)
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        Task {
            let ids = await StoriesRepository.shared.fetchStoryIds(from: .top)
            guard let first = ids.first else { return }
            let story = await StoriesRepository.shared.fetchStory(first)
            guard let story = story else { return }
            let entry = SimpleEntry(date: Date(), story: story)
            
            let timeline = Timeline(entries: [entry], policy: .atEnd)
            completion(timeline)
        }
        
//        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
//        let currentDate = Date()
//        for hourOffset in 0 ..< 5 {
//            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
//            let entry = SimpleEntry(date: entryDate)
//            entries.append(entry)
//        }

    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let story: Story
}

struct StoryWidgetEntryView : View {
    var story: Story

    var body: some View {
        HStack {
            VStack {
                Text(story.title.orEmpty)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                    .padding([.horizontal, .top])
                Spacer()
                HStack {
                    if let url = story.readableUrl {
                        Text(url)
                            .font(.footnote)
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
                        .font(.caption)
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

struct StoryWidget: Widget {
    let kind: String = "StoryWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            StoryWidgetEntryView(story: entry.story)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}
