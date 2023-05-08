import AlertToast
import Foundation
import SwiftUI
import Combine
import HackerNewsKit

struct SubmissionView: View {
    @StateObject var submissionStore = SubmissionStore()
    @StateObject var debounceObject = DebounceObject()
    @State private var showFlagToast = Bool()
    @State private var showUpvoteToast = Bool()
    @State private var showDownvoteToast = Bool()
    @State private var showFavoriteToast = Bool()
    @State private var showUnfavoriteToast = Bool()
    
    let ids: [Int]
    
    var body: some View {
        List {
            ForEach(submissionStore.submitted, id: \.self.id) { item in
                ItemRow(item: item,
                        showFlagToast: $showFlagToast,
                        showUpvoteToast: $showUpvoteToast,
                        showDownvoteToast: $showDownvoteToast,
                        showFavoriteToast: $showFavoriteToast,
                        showUnfavoriteToast: $showUnfavoriteToast)
                .listRowInsets(EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12))
                .listRowSeparator(.hidden)
                .onAppear {
                    submissionStore.onItemRowAppear(item)
                }
            }
        }
        .listStyle(.plain)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Submissions")
        .onAppear {
            if submissionStore.status == .idle {
                Task {
                    await submissionStore.fetchSubmissions(ids: ids)
                }
            }
        }
        .toast(isPresenting: $showFlagToast) {
            AlertToast(type: .systemImage("flag.fill", .gray), title: "Flagged")
        }
        .toast(isPresenting: $showUpvoteToast) {
            AlertToast(type: .systemImage("hand.thumbsup.fill", .gray), title: "Upvoted")
        }
        .toast(isPresenting: $showDownvoteToast) {
            AlertToast(type: .systemImage("hand.thumbsdown.fill", .gray), title: "Downvoted")
        }
        .toast(isPresenting: $showUnfavoriteToast, alert: {
            AlertToast(type: .systemImage("heart.slash", .gray), title: "Removed")
        })
        .toast(isPresenting: $showFavoriteToast, alert: {
            AlertToast(type: .systemImage("heart.fill", .gray), title: "Added")
        })
    }
}
