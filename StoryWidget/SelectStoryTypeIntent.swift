import AppIntents
import HackerNewsKit

enum StorySource: String, AppEnum {
    case top
    case best
    case new
    case ask
    case show
    case job
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Story Source"
    
    static var caseDisplayRepresentations: [StorySource : DisplayRepresentation] = [
        .top: "top",
        .best: "best",
        .new: "new",
        .ask: "ask",
        .show: "show",
        .job: "job"
    ]
}

struct SelectStoryTypeIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Select Story Type"
    static var description = IntentDescription("Select the type of story you want to see.")
    
    @Parameter(title: "Story Type", default: StorySource.top)
    var source: StorySource
    
    init(source: StorySource) {
        self.source = source
    }
    
    init() {
        self.source = .top
    }
}
