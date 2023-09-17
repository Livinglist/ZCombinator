import Foundation
import SwiftUI
import Combine
import HackerNewsKit

extension HomeView {
    @MainActor
    class StoryStore: ObservableObject {
        @Published var storyType: StoryType = .top
        @Published var stories: [Story] = .init()
        @Published var status: Status = .idle
        @Published var isConnectedToNetwork: Bool = true

        private let pageSize: Int = 10
        private var currentPage: Int = 0
        private var storyIds: [Int] = .init()
        
        init() {
            print("\(NetworkMonitor.shared.networkStatus.values)")
            _ = NetworkMonitor.shared.networkStatus.sink { isConnected in
                self.isConnectedToNetwork = isConnected
            }
        }

        func fetchStories(status: Status = .inProgress) async {
            self.status = status
            self.currentPage = 0
            self.storyIds = await StoriesRepository.shared.fetchStoryIds(from: self.storyType)
            
            if isConnectedToNetwork {
                var stories = [Story]()
                let range = 0..<min(pageSize, storyIds.count)
                await StoriesRepository.shared.fetchStories(ids: Array(storyIds[range])) { story in
                    stories.append(story)
                }
                
                self.status = .completed
                withAnimation {
                    self.stories = stories
                }
            }
            else {
                let stories = OfflineRepository.shared.fetchAllStories(from: storyType)
                self.status = .completed
                withAnimation {
                    self.stories = stories
                }
            }
        }
        
        func refresh() async -> Void {
            if !isConnectedToNetwork { return }
            
            await fetchStories(status: .refreshing)
        }
        
        func loadMore() async {
            if !isConnectedToNetwork { return }
            
            if stories.count == storyIds.count {
                return
            }
            
            currentPage = currentPage + 1
            
            let startIndex = min(currentPage * pageSize, storyIds.count)
            let endIndex = min(startIndex + pageSize, storyIds.count)
            var stories = [Story]()
            
            await StoriesRepository.shared.fetchStories(ids: Array(storyIds[startIndex..<endIndex])) { story in
                stories.append(story)
            }
            
            DispatchQueue.main.async {
                withAnimation {
                    self.status = .completed
                    self.stories.append(contentsOf: stories)
                }
            }
        }
        
        func onStoryRowAppear(_ story: Story) {
            if let last = stories.last, last.id == story.id {
                Task {
                    await loadMore()
                }
            }
        }
    }
}
