import SwiftUI
import HackerNewsKit

extension SearchView {
    @MainActor
    class SearchStore: ObservableObject {
        @Published var results = [any Item]()
        @Published var status: Status = .idle
        @Published var params: SearchParams = .init(page: 0, query: String(), sorted: Bool(), filters: Set<SearchFilter>())
        private var page: Int = 0
        
        func onTap(filter: SearchFilter) {
            var updatedFilters = Set(params.filters)
            
            if updatedFilters.contains(filter) {
                updatedFilters.remove(filter)
            } else {
                updatedFilters.insert(filter)
            }
   
            withAnimation {
                self.params = params.copyWith(filters: updatedFilters)
            }
        }
        
        func onSortTap() {
            self.params = params.copyWith(sorted: !(params.sorted))
        }
        
        func contains(_ filter: SearchFilter) -> Bool {
            return params.filters.contains(filter)
        }
        
        func containsDateRange() -> Bool {
            return params.filters.contains(where: { filter in
                if case .dateRange(_, _) = filter {
                    return true
                }
                return false
            })
        }

        func search(query: String) async {
            if query.isEmpty { return }
            self.status = .loading

            let searchParams = params.copyWith(query: query)
            var results = [any Item]()
            
            await SearchRepository.shared.search(params: searchParams) { item in
                results.append(item)
            }

            withAnimation {
                self.results = results
                self.status = .loaded
            }

            self.params = searchParams
        }

        func loadMore() async {
            let page = params.page
            let searchParams = params.copyWith(page: page + 1)
            var results = [any Item]()
            
            await SearchRepository.shared.search(params: searchParams) { item in
                results.append(item)
            }

            withAnimation {
                self.results.append(contentsOf: results)
            }

            self.params = searchParams
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
