import SwiftUI
import HackerNewsKit

extension SubmissionView {
    @MainActor
    class SubmissionStore: ObservableObject {
        @Published var submitted = [any Item]()
        @Published var status: Status = .idle
        
        private var currentPage: Int = 0
        private let pageSize: Int = 10
        var ids: [Int] = [Int]()
        
        func fetchSubmissions(ids: [Int]) async {
            self.ids = ids
            self.status = .loading
            
            let startIndex = min(currentPage * pageSize, ids.count)
            let endIndex = min(startIndex + pageSize, ids.count)
            var items = [any Item]()
            
            await StoriesRepository.shared.fetchItems(ids: Array(ids[startIndex..<endIndex])) { item in
                items.append(item)
            }
            
            withAnimation {
                self.status = .loaded
                self.submitted.append(contentsOf: items)
            }
        }
        
        func loadMore() async {
            if submitted.count == ids.count {
                return
            }
            
            self.status = .loading
            
            currentPage = currentPage + 1
            
            let startIndex = min(currentPage * pageSize, ids.count)
            let endIndex = min(startIndex + pageSize, ids.count)
            var items = [any Item]()
            
            await StoriesRepository.shared.fetchItems(ids: Array(ids[startIndex..<endIndex])) { item in
                items.append(item)
            }
            
            withAnimation {
                self.status = .loaded
                self.submitted.append(contentsOf: items)
            }
        }
        
        func onItemRowAppear(_ item: any Item) {
            if let last = submitted.last, last.id == item.id {
                Task {
                    await loadMore()
                }
            }
        }
    }
}
