import AppIntents

public enum StoryType: String, Equatable, CaseIterable, AppEnum {
    case top = "top"
    case best = "best"
    case new = "new"
    case ask = "ask"
    case show = "show"
    case jobs = "job"
    
    public var iconName: String {
        switch self {
        case .top:
            return "flame"
        case .best:
            return "triangle.tophalf.filled"
        case .new:
            return "rectangle.dashed"
        case .ask:
            return "person.fill.questionmark"
        case .show:
            return "sparkles.tv"
        case .jobs:
            return "briefcase"
        }
    }
    
    public var label: String {
        switch self {
        case .jobs:
            return "jobs"
        default:
            return self.rawValue
        }
    }
    
    public static var typeDisplayRepresentation: TypeDisplayRepresentation = "Story Type"
    public static var caseDisplayRepresentations: [StoryType : DisplayRepresentation] = [
        .top: "Top",
        .best: "Best",
        .new: "New",
        .ask: "Ask HN",
        .show: "Show HN",
        .jobs: "YC Jobs"
    ]
}
