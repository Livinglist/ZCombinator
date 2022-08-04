//
//  LoadingIndicator.swift
//  ZCombinator
//
//  Created by Jiaqi Feng on 8/4/22.
//

import SwiftUI

struct LoadingIndicator: View {
    @State private var shouldAnimate = false
    
    var body: some View {
        HStack {
            Circle()
                .fill(.orange)
                .frame(width: 20, height: 20)
                .scaleEffect(shouldAnimate ? 1.0 : 0.5)
                .animation(.easeInOut(duration: 0.5).repeatForever(), value: shouldAnimate)
            Circle()
                .fill(.orange)
                .frame(width: 20, height: 20)
                .scaleEffect(shouldAnimate ? 1.0 : 0.5)
                .animation(.easeInOut(duration: 0.5).repeatForever().delay(0.3), value: shouldAnimate)
            Circle()
                .fill(.orange)
                .frame(width: 20, height: 20)
                .scaleEffect(shouldAnimate ? 1.0 : 0.5)
                .animation(.easeInOut(duration: 0.5).repeatForever().delay(0.6), value: shouldAnimate)
        }
        .onAppear {
            self.shouldAnimate = true
        }
    }
    
}

struct LoadingIndicator_Previews: PreviewProvider {
    static var previews: some View {
        LoadingIndicator()
    }
}
