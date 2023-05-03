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
        private var params: SearchParams? = nil
        private var page: Int = 0

        func search(query: String, filter: Filter) async {
            debugPrint(query)

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
