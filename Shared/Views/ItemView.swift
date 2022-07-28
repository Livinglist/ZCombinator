//
//  ItemVew.swift
//  ZCombinator
//
//  Created by Jiaqi Feng on 7/19/22.
//

import SwiftUI

struct ItemView<T : ItemProtocol>: View {
    let item: T
    
    var body: some View {
        Text("\(item.title ?? item.text ?? "")")
    }
}

struct ItemVew_Previews: PreviewProvider {
    static var previews: some View {
        ItemView(item: Story())
    }
}
