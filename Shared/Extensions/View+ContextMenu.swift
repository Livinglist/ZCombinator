//
//  View+ContextMenu.swift
//  ZCombinator
//
//  Created by Jiaqi Feng on 8/4/22.
//

import Foundation
import SwiftUI

extension View {
    func contextMenu<Content: View>(_ menu: PreviewContextMenu<Content>) -> some View {
        self.modifier(PreviewContextViewModifier(menu: menu))
    }
}
