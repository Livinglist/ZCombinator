import AppIntents
import HackerNewsKit

struct SelectStoryTypeIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Select Story Type"
    static var description = IntentDescription("Select the type of story you want to see.")
    
    @Parameter(title: "Story Type", default: "")
    var storyType: String
    
    init(storyType: String) {
        self.storyType = storyType
    }
    
    init() {
        self.storyType = ""
    }
}
