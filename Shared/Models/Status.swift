public enum Status {
    case idle
    // Loading with visible loading indicator.
    case loading
    // Loading with no loading indicator.
    case backgroundLoading
    case loaded
    case error
    
    var isLoading: Bool {
        switch self {
        case .loading, .backgroundLoading: return true
        default: return false
        }
    }
}
