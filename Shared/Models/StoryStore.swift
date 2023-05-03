import Foundation
import SwiftUI
import Combine
import HackerNewsKit

extension HomeView {
    @MainActor
    class StoryStore: ObservableObject {
        @Published var storyType: StoryType = .top
        @Published var stories: [Story] = [Story]()
        @Published var pinnedStories: [Story] = [Story]()
        @Published var status: Status = .idle
        private let settings = Settings.shared
        private let pageSize: Int = 10
        private var currentPage: Int = 0
        private var storyIds: [Int] = [Int]()
        private var pinnedIds: [Int] = [Int]() {
            didSet {
                Task {
                    await fetchPinnedStories()
                }
            }
        }
        private var pinListCancellable: AnyCancellable?
        
        init() {
            pinListCancellable = settings.$pinList.sink(receiveValue: { ids in
                self.pinnedIds = Array<Int>(ids)
            })
        }

        func fetchStories() async {
            withAnimation {
                self.stories = [Story]()
                self.status = .loading
            }
            self.currentPage = 0
            self.storyIds = await StoriesRepository.shared.fetchStoryIds(from: self.storyType)
  
            var stories = [Story]()
            let range = 0..<min(10, storyIds.count)
            await StoriesRepository.shared.fetchStories(ids: Array(storyIds[range])) { story in
                stories.append(story)
            }
            
            DispatchQueue.main.async {
                withAnimation {
                    self.status = .loaded
                    self.stories = stories
                }
            }
        }
        
        func fetchPinnedStories() async {
            var stories = [Story]()

            await StoriesRepository.shared.fetchStories(ids: pinnedIds) { story in
                stories.append(story)
            }
            
            DispatchQueue.main.async {
                withAnimation {
                    self.pinnedStories = stories
                    self.stories = self.stories
                }
            }
        }
        
        func refresh() async -> Void {
            await fetchStories()
        }
        
        func loadMore() async {
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
                    self.status = .loaded
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
