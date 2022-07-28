//
//  HomeViewModel.swift
//  ZCombinator
//
//  Created by Jiaqi Feng on 7/19/22.
//

import Foundation

extension HomeView {
    class ViewModel: ObservableObject {
        @Published var stories = [Story]()
    }
}
