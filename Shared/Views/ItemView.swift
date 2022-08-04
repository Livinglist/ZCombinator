//
//  ItemVew.swift
//  ZCombinator
//
//  Created by Jiaqi Feng on 7/19/22.
//

import SwiftUI
import WebKit

struct ItemView<T : ItemProtocol>: View {
    @StateObject var vm: ItemViewViewModel<T> = ItemViewViewModel<T>()
    let level: Int
    let item: T
    
    init(item: T, level: Int = 0){
        self.level = level
        self.item = item
    }
    
    var body: some View {
        mainItemView.onAppear {
            if self.vm.item == nil {
                self.vm.item = item
            }
        }
    }
    
    @ViewBuilder
    var mainItemView: some View {
        if level == 0 {
            ScrollView{
                VStack {
                    if vm.item is Story {
                        Text("\(item.title.valueOrEmpty)").padding(EdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 0))
                    } else if vm.item is Comment {
                        Text("\(item.text.valueOrEmpty)").padding(EdgeInsets(top: 0, leading: Double(4 * (level - 1)), bottom: 0, trailing: 0))
                    }
                    if vm.status == .idle {
                        Button {
                            Task {
                                await vm.loadKids()
                            }
                        } label: {
                            Text("Load \(item.kids.countOrZero) \(item.kids.isMoreThanOne ? "replies":"reply")")
                        }
                    } else if vm.status == .loading {
                        LoadingIndicator()
                    }
                    VStack {
                        ForEach(vm.kids){ comment in
                            ItemView<Comment>(item: comment, level: level + 1 )
                                .listRowSeparator(.hidden).listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 12, trailing: 0))
                        }.id(UUID())
                    }.buttonStyle(PlainButtonStyle())
                }
            }.listStyle(.plain).listRowSeparator(.hidden)
        } else {
            ZStack {
                if level > 1 {
                    HStack {
                        getColor(level: level).frame(width: 1)
                        Spacer()
                    }
                }
                VStack {
                    HStack {
                        Text(vm.item?.by ?? "").foregroundColor(getColor(level: level))
                        Spacer()
                    }
                    if vm.item is Story {
                        Text("\(vm.item?.title ?? "")").padding(EdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 0))
                    } else if vm.item is Comment {
                        Text(item.text ?? "").fixedSize(horizontal: false, vertical: true).frame(maxWidth: .infinity, alignment: .leading).padding(EdgeInsets(top: 0, leading: Double(4 * (level - 1)), bottom: 0, trailing: 0))
                    }
                    if vm.status != Status.loaded && !(item.kids?.isEmpty ?? true) {
                        Button {
                            Task {
                                await vm.loadKids()
                            }
                        } label: {
                            Text("Load \(item.kids.countOrZero) \(item.kids.isMoreThanOne ? "replies":"reply")").font(.footnote).foregroundColor(.orange)
                        }
                    }
                    VStack {
                        ForEach(vm.kids){ comment in
                            ItemView<Comment>(item: comment, level: level + 1)
                                .listRowSeparator(.hidden).listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 12, trailing: 0))
                        }.id(UUID())
                    }.buttonStyle(PlainButtonStyle())
                    Spacer()
                }.frame(alignment: .leading).padding(EdgeInsets(top: 6, leading: 6, bottom: 12, trailing: 0))
            }
            .frame(maxWidth:.infinity)
            .frame(alignment: .leading)
        }
    }
    
    func getColor(level: Int) -> Color {
        var level = level
        let initialLevel = level
        
        if colors[initialLevel] != nil {
            return colors[initialLevel]!
        }
        
        while level >= 10 {
            level = level - 10
        }
        
        let r = 255
        var g = level * 40 < 255 ? 152 : (level * 20).clamped(to: 0...255)
        var b = (level * 40).clamped(to: 0...255)
        
        if (g == 255 && b == 255) {
            g = (level * 30 - 255).clamped(to: 0...255)
            b = (level * 40 - 255).clamped(to: 0...255)
        }
        
        let color = Color.init(
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: 1
        )
        
        colors[initialLevel] = color
        
        return color
    }
}

var colors = [Int: Color]()

struct ItemVew_Previews: PreviewProvider {
    static var previews: some View {
        //ItemView(item: Story())
        EmptyView()
    }
}
