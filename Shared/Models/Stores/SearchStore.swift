import SwiftUI
import HackerNewsKit

extension SearchView {
    enum Filter: String, CaseIterable, Equatable {
        case story = "story"
        case comment = "comment"
        
        func toSearchFilter() -> any SearchFilter {
            switch self {
            case .story:
                return StoryFilter()
            case .comment:
                return CommentFilter()
            }
        }
    }

    @MainActor
    class SearchStore: ObservableObject {
        @Published var results = [any Item]()
        @Published var status: Status = .idle
        @Published var params: SearchParams? = nil
        private var page: Int = 0
        
        func onTap<Filter: SearchFilter>(filter: Filter) {
            var updatedFilters = Array(params?.filters ?? [any SearchFilter]())
            
            if let i = updatedFilters.firstIndex(where: { $0 is Filter }) {
                updatedFilters.remove(at: i)
            } else {
                updatedFilters.append(filter)
            }
   
            withAnimation {
                if params != nil {
                    self.params = params?.copyWith(filters: updatedFilters)
                } else {
                    self.params = SearchParams(page: 0, query: "", sorted: false, filters: updatedFilters)
                }
            }
        }
        
        func get<T: SearchFilter>() -> T? {
            let filter = params?.filters.first(where: { filter in
                filter is T
            })
            if let filter = filter as? T {
                return filter
            }
            return nil
        }

        func search(query: String, filter: Filter) async {
            self.status = .loading

            let searchParams = SearchParams(page: 0, query: query, sorted: false, filters: [filter.toSearchFilter()])
            var results = [any Item]()
            await SearchRepository.shared.search(params: searchParams) { item in
                results.append(item)
            }

            withAnimation {
                self.results = results
                self.status = .loaded
            }

            params = searchParams
        }

        func loadMore() async {
            guard let page = params?.page,
                let searchParams = params?.copyWith(page: page + 1)
                else { return }
            var results = [any Item]()
            await SearchRepository.shared.search(params: searchParams) { item in
                results.append(item)
            }

            withAnimation {
                self.results.append(contentsOf: results)
            }

            params = searchParams
        }

        func onItemRowAppear(_ item: any Item) {
            if let last = results.last, last.id == item.id {
                Task {
                    await loadMore()
                }
            }
        }
    }
}
