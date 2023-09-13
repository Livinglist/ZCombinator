import WidgetKit
import HackerNewsKit
import Foundation

struct StoryEntry: TimelineEntry {
    let date: Date
    let story: Story
    
    static let errorPlaceholder: StoryEntry = StoryEntry(
        date: .now,
        story: .errorPlaceholder
    )
}
